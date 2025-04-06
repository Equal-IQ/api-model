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
OUTPUT_DIR="./output"
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

# Create output directory
mkdir -p "$OUTPUT_DIR"

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
  docker run --rm equaliq-python-codegen > "$OUTPUT_DIR/models.py"
  
  # Clean up
  docker rmi equaliq-python-codegen >/dev/null 2>&1
  rm -rf "$TEMP_DIR"
  
  echo "✅ Python models generated in $OUTPUT_DIR/models.py"
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

// Use a simpler approach with the CLI tool
exec('npx openapi-typescript /app/api.json -o /app/models.ts', (error, stdout, stderr) => {
  if (error) {
    console.error('Error generating TypeScript types:', error);
    console.error(stderr);
    process.exit(1);
  }
  console.log(stdout);
  console.log('TypeScript types generated successfully');
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
  docker run --rm equaliq-ts-codegen > "$OUTPUT_DIR/models.ts"
  
  # Clean up
  docker rmi equaliq-ts-codegen >/dev/null 2>&1
  rm -rf "$TEMP_DIR"
  
  echo "✅ TypeScript types generated in $OUTPUT_DIR/models.ts"
fi

echo "Done! Generated files are in $OUTPUT_DIR"