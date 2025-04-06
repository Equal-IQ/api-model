#!/bin/bash
set -e

# Usage info
usage() {
  echo "Generate Python and TypeScript types from OpenAPI definition"
  echo ""
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  -p, --python      Generate Python models (with Pydantic)"
  echo "  -t, --typescript  Generate TypeScript types"
  echo "  -a, --all         Generate both Python and TypeScript"
  echo "  -o, --output-dir  Output directory (default: ./output)"
  echo "  -h, --help        Show this help message"
  echo ""
  echo "Example: $0 --all --output-dir ./types"
  echo ""
  exit 1
}

# Default values
PYTHON=false
TYPESCRIPT=false
OUTPUT_DIR=""  # No default output directory since we have dedicated package directories
OPENAPI_FILE="build/smithyprojections/api-model/openapi/openapi/EqualIQ.openapi.json"

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -p|--python) PYTHON=true ;;
    -t|--typescript) TYPESCRIPT=true ;;
    -a|--all) PYTHON=true; TYPESCRIPT=true ;;
    -o|--output-dir) OUTPUT_DIR="$2"; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown parameter: $1"; usage ;;
  esac
  shift
done

# Define package directories
PYTHON_PACKAGE_DIR="./python/api_model/types"
TYPESCRIPT_PACKAGE_DIR="./typescript/src"

# Ensure we have something to generate
if [[ "$PYTHON" == "false" && "$TYPESCRIPT" == "false" ]]; then
  echo "Error: No output type specified. Use --python, --typescript, or --all"
  usage
fi

# Check if OpenAPI file exists, if not, run the build
if [[ ! -f "$OPENAPI_FILE" ]]; then
  echo "OpenAPI file not found. Running build-docker.sh first..."
  ./build-docker.sh
fi

# Check again, in case the build failed
if [[ ! -f "$OPENAPI_FILE" ]]; then
  echo "Error: OpenAPI file not found at $OPENAPI_FILE after build"
  exit 1
fi

# Create output directory if specified
if [[ -n "$OUTPUT_DIR" ]]; then
  mkdir -p "$OUTPUT_DIR"
fi

# Generate Python models with a dedicated container build
if [[ "$PYTHON" == "true" ]]; then
  echo "Generating Python models..."
  
  # Create a temporary directory for our Dockerfile and context
  TEMP_DIR=$(mktemp -d)
  
  # Copy the OpenAPI file to the temp directory
  cp "$OPENAPI_FILE" "$TEMP_DIR/api.json"
  
  # Create a Dockerfile for Python
  cat > "$TEMP_DIR/Dockerfile" << EOF
FROM python:3.9-slim

WORKDIR /app

# Install dependencies
RUN pip install --no-cache-dir datamodel-code-generator

# Copy the OpenAPI file
COPY api.json /app/api.json

# Generate the models
RUN datamodel-codegen --input api.json --input-file-type openapi --output /app/models.py

CMD ["cat", "/app/models.py"]
EOF
  
  # Build and run the container, capturing the output directly
  (cd "$TEMP_DIR" && docker build -t equaliq-python-codegen .)
  
  # Ensure the python package directory exists
  mkdir -p "$PYTHON_PACKAGE_DIR"
  
  # Always write to the python package directory
  docker run --rm equaliq-python-codegen > "$PYTHON_PACKAGE_DIR/models.py"
  
  # Write to additional output directory if specified
  if [[ -n "$OUTPUT_DIR" ]]; then
    mkdir -p "$OUTPUT_DIR"
    docker run --rm equaliq-python-codegen > "$OUTPUT_DIR/models.py"
  fi
  
  # Clean up
  docker rmi equaliq-python-codegen >/dev/null 2>&1
  rm -rf "$TEMP_DIR"
  
  echo "✅ Python models generated in $PYTHON_PACKAGE_DIR/ package"
  if [[ -n "$OUTPUT_DIR" ]]; then
    echo "   - Additional output written to $OUTPUT_DIR/models.py"
  fi
fi

# Generate TypeScript types with a dedicated container build
if [[ "$TYPESCRIPT" == "true" ]]; then
  echo "Generating TypeScript types..."
  
  # Create a temporary directory for our Dockerfile and context
  TEMP_DIR=$(mktemp -d)
  
  # Copy the OpenAPI file to the temp directory
  cp "$OPENAPI_FILE" "$TEMP_DIR/api.json"
  
  # Create a typescript generator script
  cat > "$TEMP_DIR/generate.js" << EOF
const fs = require('fs');
const { exec } = require('child_process');

// Generate the base TypeScript file from OpenAPI
exec('npx openapi-typescript /app/api.json -o /app/models.ts', (error, stdout, stderr) => {
  if (error) {
    console.error('Error generating TypeScript types:', error);
    console.error(stderr);
    process.exit(1);
  }
  console.log(stdout);
  console.log('TypeScript base models generated successfully');
  
  // Now create an index.ts file that exports all the components.schemas
  const indexContent = \`// Auto-generated index file
// Export all schemas from the OpenAPI specification
export * from './models';
export { components } from './models';

// Re-export schemas as top-level types for easier importing
import { components } from './models';
export type Schemas = components['schemas'];

// Make each schema available as a top-level export
type SchemaNames = keyof components['schemas'];
type ExtractSchema<K extends SchemaNames> = components['schemas'][K];

\${Object.keys(require('/app/api.json').components.schemas)
  .map(schemaName => \`export type \${schemaName} = ExtractSchema<'\${schemaName}'>\`)
  .join('\\n')
}
\`;

  fs.writeFileSync('/app/index.ts', indexContent);
  console.log('TypeScript index with type exports generated successfully');
});
EOF
  
  # Create a Dockerfile for TypeScript
  cat > "$TEMP_DIR/Dockerfile" << EOF
FROM node:18-slim

WORKDIR /app

# Install dependencies
RUN npm install openapi-typescript

# Copy files
COPY api.json /app/api.json
COPY generate.js /app/generate.js

# Generate the models
RUN node generate.js

CMD ["cat", "/app/models.ts"]
EOF
  
  # Build and run the container, capturing the output directly
  (cd "$TEMP_DIR" && docker build -t equaliq-ts-codegen .)
  
  # Ensure the typescript package directory exists
  mkdir -p "$TYPESCRIPT_PACKAGE_DIR"
  
  # Always write to the typescript package directory
  docker run --rm equaliq-ts-codegen cat /app/models.ts > "$TYPESCRIPT_PACKAGE_DIR/models.ts"
  docker run --rm equaliq-ts-codegen cat /app/index.ts > "$TYPESCRIPT_PACKAGE_DIR/index.ts"
  
  # Write to additional output directory if specified
  if [[ -n "$OUTPUT_DIR" ]]; then
    mkdir -p "$OUTPUT_DIR"
    docker run --rm equaliq-ts-codegen cat /app/models.ts > "$OUTPUT_DIR/models.ts"
    docker run --rm equaliq-ts-codegen cat /app/index.ts > "$OUTPUT_DIR/index.ts"
  fi
  
  # Clean up
  docker rmi equaliq-ts-codegen >/dev/null 2>&1
  rm -rf "$TEMP_DIR"
  
  echo "✅ TypeScript types generated in $TYPESCRIPT_PACKAGE_DIR/ package"
  if [[ -n "$OUTPUT_DIR" ]]; then
    echo "   - Additional output written to $OUTPUT_DIR/"
  fi
  echo "   - All schema types are automatically exported as top-level types"
fi

if [[ -n "$OUTPUT_DIR" ]]; then
  echo "Done! Generated files are in $OUTPUT_DIR"
else
  echo "Done! Generated files are in python/ and typescript/ packages"
fi