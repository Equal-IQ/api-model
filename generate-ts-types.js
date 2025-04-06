/**
 * TypeScript type generator for EqualIQ API.
 * This script converts OpenAPI definitions to TypeScript interfaces.
 */

const json2ts = require('json-schema-to-typescript');
const fs = require('fs');

async function main() {
  // Check if we have the right arguments
  if (process.argv.length < 4) {
    console.error('Usage: node generate-ts-types.js <input_openapi_json> <output_typescript_file>');
    process.exit(1);
  }

  const inputFile = process.argv[2];
  const outputFile = process.argv[3];

  // Check if the input file exists
  if (!fs.existsSync(inputFile)) {
    console.error(`Error: Input file not found: ${inputFile}`);
    process.exit(1);
  }

  try {
    // Read the OpenAPI specification
    const schema = JSON.parse(fs.readFileSync(inputFile, 'utf8'));
    
    // Generate TypeScript interfaces
    const ts = await json2ts.compile(schema, 'EqualIQAPI', {
      bannerComment: '/* EqualIQ API - Generated TypeScript interfaces */',
      style: {
        singleQuote: true,
      },
    });
    
    // Write the output
    fs.writeFileSync(outputFile, ts);
    console.log(`Successfully generated TypeScript types: ${outputFile}`);
  } catch (error) {
    console.error('Error generating TypeScript types:', error);
    process.exit(1);
  }
}

main();