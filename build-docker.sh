#!/bin/bash
set -e

IMAGE_NAME="equaliq-api-model"
CONTAINER_NAME="equaliq-api-model-build-$(date +%s)"

# Clean up previous build directory
rm -rf "$(pwd)/build"
mkdir -p "$(pwd)/build"

# Clean up any existing containers with similar names (from previous runs)
docker ps -a | grep 'equaliq-api-model-build' | awk '{print $1}' | xargs -r docker rm -f

echo "🔨 Building Docker image..."
docker build -t $IMAGE_NAME .

echo "🚀 Running build in container..."
# Run the container with unique name 
docker run --name $CONTAINER_NAME $IMAGE_NAME

# Copy build artifacts from container to host
echo "📦 Copying build artifacts from container..."
docker cp $CONTAINER_NAME:/app/build/. "$(pwd)/build/"

# Remove the container now that we're done
echo "🧹 Cleaning up container..."
docker rm $CONTAINER_NAME > /dev/null

# Output success message
echo "✅ Build completed. Output files in $(pwd)/build"

# Check for the OpenAPI output file
OPENAPI_PATH="smithyprojections/api-model/openapi/openapi/EqualIQ.openapi.json"
OPENAPI_FILE="$(pwd)/build/$OPENAPI_PATH"

if [ -f "$OPENAPI_FILE" ]; then
  echo "✅ OpenAPI file successfully generated!"
  echo "  -> $OPENAPI_FILE"
  echo "  Size: $(du -h "$OPENAPI_FILE" | cut -f1)"
else
  echo "❌ OpenAPI file not found at expected path: $OPENAPI_PATH"
  echo "Contents of build directory:"
  find "$(pwd)/build" -name "*.json" | sort
fi