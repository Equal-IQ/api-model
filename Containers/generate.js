const fs = require('fs');
const { exec } = require('child_process');

// Generate the base TypeScript file from OpenAPI using the --enum flag and --transform to flatten refs
exec('npx openapi-typescript /app/api.json -o /app/models.ts --enum --root-types --root-types-no-schema-prefix --export-type', (error, stdout, stderr) => {
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
`;

  fs.writeFileSync('/app/index.ts', indexContent);
  console.log('TypeScript index with type exports generated successfully');
});