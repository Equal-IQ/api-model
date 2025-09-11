const fs = require('fs');
const { exec } = require('child_process');
const path = require('path');

// Discover all OpenAPI specs in /app directory
const apiSpecs = [];
const files = fs.readdirSync('/app');

files.forEach(file => {
  if (file.endsWith('.json') && file.includes('api')) {
    const specPath = path.join('/app', file);
    try {
      const spec = require(specPath);
      if (spec.openapi && spec.info && spec.components) {
        // Extract projection name from filename (e.g., 'orgs-api.json' -> 'orgs', 'api.json' -> 'main')
        const projectionName = file === 'api.json' ? 'main' : file.replace('-api.json', '');
        apiSpecs.push({
          name: projectionName,
          file: file,
          path: specPath,
          spec: spec,
          outputFile: projectionName === 'main' ? 'models.ts' : `${projectionName}-models.ts`
        });
      }
    } catch (e) {
      console.warn(`Skipping ${file}: not a valid OpenAPI spec`);
    }
  }
});

console.log(`Found ${apiSpecs.length} OpenAPI specifications:`, apiSpecs.map(s => s.name));

// Generate TypeScript for each spec
let completedSpecs = 0;
apiSpecs.forEach(specInfo => {
  exec(`npx openapi-typescript ${specInfo.path} -o /app/${specInfo.outputFile} --enum`, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error generating TypeScript types for ${specInfo.name}:`, error);
      console.error(stderr);
      process.exit(1);
    }
    console.log(`TypeScript base models generated successfully for ${specInfo.name}`);
    
    completedSpecs++;
    if (completedSpecs === apiSpecs.length) {
      generateIndexFiles();
    }
  });
});

function generateIndexFiles() {
  // Generate index files for each spec
  apiSpecs.forEach(specInfo => {
    generateIndexForSpec(specInfo);
  });
  
  // Generate master index that exports all namespaces
  generateMasterIndex();
}

function generateIndexForSpec(specInfo) {
  const apiSpec = specInfo.spec;
  
  // Function to convert OpenAPI schema to TypeScript type string
  function convertSchemaToTypeScript(schema, schemaName) {
    // Handle references first
    if (schema.$ref) {
      return schema.$ref.split('/').pop();
    }
    
    if (schema.enum) {
      // Handle enum types - keep them as string literal unions
      return `"${schema.enum.join('" | "')}"`;
    }
    
    if (schema.type === 'object' && schema.properties) {
      // Handle object types - unwrap to interface definitions
      const properties = Object.entries(schema.properties)
        .map(([propName, propSchema]) => {
          const optional = !schema.required?.includes(propName) ? '?' : '';
          let propType;
          
          // Handle references to other schemas
          if (propSchema.$ref) {
            propType = propSchema.$ref.split('/').pop();
          }
          // Handle arrays
          else if (propSchema.type === 'array' && propSchema.items) {
            if (propSchema.items.$ref) {
              const itemSchemaName = propSchema.items.$ref.split('/').pop();
              propType = `${itemSchemaName}[]`;
            } else {
              propType = `${convertSchemaToTypeScript(propSchema.items, `${schemaName}_${propName}_Item`)}[]`;
            }
          }
          // Handle additionalProperties (Record types)
          else if (propSchema.type === 'object' && propSchema.additionalProperties) {
            if (propSchema.additionalProperties.$ref) {
              const valueSchemaName = propSchema.additionalProperties.$ref.split('/').pop();
              propType = `{ [key: string]: ${valueSchemaName} }`;
            } else if (propSchema.additionalProperties === true) {
              propType = `{ [key: string]: unknown }`;
            } else {
              const valueType = convertSchemaToTypeScript(propSchema.additionalProperties, `${schemaName}_${propName}_Value`);
              propType = `{ [key: string]: ${valueType} }`;
            }
          }
          // Handle basic types
          else if (propSchema.type === 'string') {
            propType = 'string';
          }
          else if (propSchema.type === 'number' || propSchema.format === 'double' || propSchema.format === 'float') {
            propType = 'number';
          }
          else if (propSchema.type === 'boolean') {
            propType = 'boolean';
          }
          else {
            propType = convertSchemaToTypeScript(propSchema, `${schemaName}_${propName}`);
          }
          
          return `  ${propName}${optional}: ${propType};`;
        })
        .join('\n');
      
      return `{\n${properties}\n}`;
    }
    
    // Handle additionalProperties at the root level (Record types)
    if (schema.type === 'object' && schema.additionalProperties) {
      if (schema.additionalProperties.$ref) {
        const valueSchemaName = schema.additionalProperties.$ref.split('/').pop();
        return `{ [key: string]: ${valueSchemaName} }`;
      } else if (schema.additionalProperties === true) {
        return `{ [key: string]: unknown }`;
      } else {
        const valueType = convertSchemaToTypeScript(schema.additionalProperties, `${schemaName}_Value`);
        return `{ [key: string]: ${valueType} }`;
      }
    }
    
    // Handle union types (oneOf)
    if (schema.oneOf) {
      return schema.oneOf.map(subSchema => {
        if (subSchema.$ref) {
          return subSchema.$ref.split('/').pop();
        }
        return convertSchemaToTypeScript(subSchema, schemaName);
      }).join(' | ');
    }
    
    // Handle arrays
    if (schema.type === 'array' && schema.items) {
      if (schema.items.$ref) {
        return `${schema.items.$ref.split('/').pop()}[]`;
      }
      return `${convertSchemaToTypeScript(schema.items, `${schemaName}_Item`)}[]`;
    }
    
    // Handle basic types
    if (schema.type === 'string') return 'string';
    if (schema.type === 'number' || schema.format === 'double' || schema.format === 'float') return 'number';
    if (schema.type === 'boolean') return 'boolean';
    
    return 'unknown';
  }
  
  // Generate unwrapped type definitions for non-enum types
  const typeDefinitions = Object.entries(apiSpec.components.schemas)
    .filter(([, schema]) => {
      // Skip enum types as they are handled separately
      return !(schema.type === 'string' && schema.enum);
    })
    .map(([schemaName, schema]) => {
      const typeString = convertSchemaToTypeScript(schema, schemaName);
      return `export type ${schemaName} = ${typeString};`;
    })
    .join('\n\n');
  
  // Generate enum type definitions
  const enumDefinitions = Object.entries(apiSpec.components.schemas)
    .filter(([, schema]) => {
      // Only include enum types
      return schema.type === 'string' && schema.enum;
    })
    .map(([schemaName, schema]) => {
      const enumValues = schema.enum.map(value => `  ${value} = "${value}"`).join(',\n');
      return `export enum ${schemaName} {\n${enumValues}\n}`;
    })
    .join('\n\n');
  
  const modelsImport = specInfo.name === 'main' ? './models' : `./${specInfo.name}-models`;
  const indexFileName = specInfo.name === 'main' ? 'index.ts' : `${specInfo.name}-index.ts`;
  
  const indexContent = `// Auto-generated index file with unwrapped types for ${specInfo.name} API
// Export all schemas from the OpenAPI specification
export * from '${modelsImport}';
export { components } from '${modelsImport}';

// Re-export schemas as top-level types for easier importing
import { components } from '${modelsImport}';
export type Schemas = components['schemas'];

// Unwrapped enum definitions
${enumDefinitions}

// Unwrapped type definitions (no aliases)
${typeDefinitions}
`;

  fs.writeFileSync(`/app/${indexFileName}`, indexContent);
  console.log(`TypeScript index generated successfully for ${specInfo.name} API`);
}

function generateMasterIndex() {
  const namespaceExports = apiSpecs.map(specInfo => {
    const importName = specInfo.name === 'main' ? 'Main' : 
      specInfo.name.charAt(0).toUpperCase() + specInfo.name.slice(1);
    const indexFile = specInfo.name === 'main' ? './index' : `./${specInfo.name}-index`;
    
    return {
      namespace: importName,
      import: `import * as ${importName} from '${indexFile}';`
    };
  });

  const masterIndexContent = `// Auto-generated master index file
// Exports all API namespaces
${namespaceExports.map(n => n.import).join('\n')}

// Export namespaced APIs
${namespaceExports.map(n => `export { ${n.namespace} };`).join('\n')}

// Export main API at root level for backwards compatibility
${apiSpecs.find(s => s.name === 'main') ? "export * from './index';" : ''}
`;

  fs.writeFileSync('/app/all.ts', masterIndexContent);
  console.log('Master index file generated successfully');
}