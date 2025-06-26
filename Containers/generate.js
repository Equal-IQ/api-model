const fs = require('fs');
const { exec } = require('child_process');

// Generate the base TypeScript file from OpenAPI using the --enum flag
exec('npx openapi-typescript /app/api.json -o /app/models.ts --enum', (error, stdout, stderr) => {
  if (error) {
    console.error('Error generating TypeScript types:', error);
    console.error(stderr);
    process.exit(1);
  }
  console.log(stdout);
  console.log('TypeScript base models generated successfully');
  
  // Now create an index.ts file that exports all the components.schemas
  const indexContent = `// Auto-generated index file
// Export all schemas from the OpenAPI specification
export * from './models';
export { components } from './models';

// Re-export schemas as top-level types for easier importing
import { components } from './models';
export type Schemas = components['schemas'];

// Make each schema available as a top-level export
type SchemaNames = keyof components['schemas'];
type ExtractSchema<K extends SchemaNames> = components['schemas'][K];

${Object.keys(require('/app/api.json').components.schemas)
  .filter(schemaName => {
    const schema = require('/app/api.json').components.schemas[schemaName];
    return schema.type !== 'string' || !schema.enum;
  })
  .map(schemaName => `export type ${schemaName} = ExtractSchema<'${schemaName}'>`)
  .join('\n')
}
`;

  fs.writeFileSync('/app/index.ts', indexContent);
  console.log('TypeScript index with type exports generated successfully');
});