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

# Generate Python models
if [[ "$PYTHON" == "true" ]]; then
  echo "Generating Python models..."
  
  # Run Python in a container with our script
  docker run --rm \
    -v "$(pwd)/$OPENAPI_FILE:/app/openapi.json:ro" \
    -v "$(pwd)/generate-python-types.py:/app/generate.py:ro" \
    -v "$(pwd)/$OUTPUT_DIR:/app/output" \
    -w /app \
    docker.io/python:3.9-slim \
    bash -c "pip install --no-cache-dir datamodel-code-generator && python generate.py openapi.json output/models.py"
  
  echo "✅ Python models generated in $OUTPUT_DIR/models.py"
fi

# Generate TypeScript types
if [[ "$TYPESCRIPT" == "true" ]]; then
  echo "Generating TypeScript types..."
  
  # Run Node.js in a container with our script
  docker run --rm \
    -v "$(pwd)/$OPENAPI_FILE:/app/openapi.json:ro" \
    -v "$(pwd)/generate-ts-types.js:/app/generate.js:ro" \
    -v "$(pwd)/$OUTPUT_DIR:/app/output" \
    -w /app \
    docker.io/node:18-slim \
    bash -c "npm install -g json-schema-to-typescript && node generate.js openapi.json output/models.ts"
  
  echo "✅ TypeScript types generated in $OUTPUT_DIR/models.ts"
fi

echo "Done! Generated files are in $OUTPUT_DIR"