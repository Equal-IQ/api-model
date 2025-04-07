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
  echo "  -i, --install     Install Python package in development mode"
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

# Default value for installation
INSTALL=false

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -p|--python) PYTHON=true ;;
    -t|--typescript) TYPESCRIPT=true ;;
    -a|--all) PYTHON=true; TYPESCRIPT=true ;;
    -o|--output-dir) OUTPUT_DIR="$2"; shift ;;
    -i|--install) INSTALL=true ;;
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
  
  # Create a temporary directory for our container context
  TEMP_DIR=$(mktemp -d)
  
  # Copy the OpenAPI file to the temp directory
  cp "$OPENAPI_FILE" "$TEMP_DIR/api.json"
  
  # Build and run the container using the external Containerfile
  docker build -t equaliq-python-codegen -f Containers/Containerfile-python-codegen "$TEMP_DIR"
  
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

# Install Python package if requested
if [[ "$PYTHON" == "true" && "$INSTALL" == "true" ]]; then
  echo "Installing Python package in development mode..."
  pip install -e "python/" > /dev/null
  echo "✅ Python package installation complete (from 'python/' subdirectory)"
fi

# Generate TypeScript types with a dedicated container build
if [[ "$TYPESCRIPT" == "true" ]]; then
  echo "Generating TypeScript types..."
  
  # Create a temporary directory for our container context
  TEMP_DIR=$(mktemp -d)
  
  # Copy the OpenAPI file to the temp directory
  cp "$OPENAPI_FILE" "$TEMP_DIR/api.json"
  
  # Copy the generate.js file to the temp directory
  cp "Containers/generate.js" "$TEMP_DIR/generate.js"
  
  # Build and run the container using the external Containerfile
  docker build -t equaliq-ts-codegen -f Containers/Containerfile-typescript-codegen "$TEMP_DIR"
  
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