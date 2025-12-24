# 🧬 EqualIQ API – Smithy Model

This package defines the EqualIQ API using [Smithy](https://smithy.io/) — a strongly typed interface modeling language. It enables consistent, validated types and OpenAPI documentation for the EqualIQ APIs

View the Smithy documentation:
https://smithy.io/2.0/index.html


---

## 🚀 Quickstart: Generate OpenAPI + Type Definitions

Modify the model in ./smithy then run 

```bash
./build.sh
```


### 📦 Prerequisites

Only **Docker** is required for containerized builds. No need to install Java, Gradle, Python, or Node.js locally.

For manual builds:
- Java 11+
- Gradle 7+
- Python 3.9+ (for Python/Pydantic models)
- Node.js 18+ (for TypeScript types)

---

### 📁 Folder Structure

```
api-model/
├── model/                   # Your Smithy models go here
│   └── equaliq.smithy
├── smithy-build.json        # Projection configuration
├── build.gradle.kts         # Gradle config
├── settings.gradle.kts
├── build/                   # Auto-generated output
├── Containers               # For containerized builds
│   └── Containerfile-xxx
├── build-openapi.sh         # Generate OpenAPI types (Container)
├── build-types.sh           # Generate Python/TypeScript (Containers)
```

---

## Build the Project

### Containerized Build (Recommended)

For a completely containerized build without requiring local installations:

```bash
# Make scripts executable (first time only)
chmod +x build-docker.sh build-types.sh

# Run the Smithy build in Docker
./build-openapi.sh
```

This will:
- Build a Docker image with all necessary dependencies
- Run the Gradle build inside the container
- Copy the build results to your local `build/` directory

### Local Build (Alternative)

If you have Java and Gradle installed, you can run:

```bash
./gradlew clean build
```

Both methods will:
- Validate your Smithy model
- Generate OpenAPI in:
  ```
  build/smithyprojections/api-model/openapi/openapi/EqualIQ.openapi.json
  ```

---

## Generate Python/TypeScript Types

### Containerized Type Generation (Recommended)

Generate both Python and TypeScript types in one command without local dependencies:

```bash
# Generate both Python and TypeScript packages
./build-types.sh --all

# Or generate just Python package
./build-types.sh --python

# Or generate just TypeScript package
./build-types.sh --typescript
```

The generated files will be placed in the appropriate package directories:
- Python: `./python/api_model/types/models.py`
- TypeScript: `./typescript/src/models.ts` and `./typescript/src/index.ts`

You can optionally specify an additional output directory:
```bash
./build-types.sh --all --output-dir ./my-output-dir
```

This will:
- Run the Smithy build first if needed
- Use Docker containers to generate the types
- Output the files to the specified directory

### Cut Release ###
For TypeScript (Frontend, LLM) use, install directly from GitHub using commit hashes or branches.
After a commit is pushed to GitHub, you can update the reference in your package.json and run npm install.

### Manual Type Generation (Alternative)

#### 🐍 Python (Pydantic)

```bash
pip install datamodel-code-generator

datamodel-codegen \
  --input build/smithyprojections/api-model/openapi/openapi/EqualIQ.openapi.json \
  --input-file-type openapi \
  --output models.py
```

#### 🧠 TypeScript

```bash
npm install -g json-schema-to-typescript

json2ts -i build/smithyprojections/api-model/openapi/openapi/EqualIQ.openapi.json -o models.ts
```

---

## 🧠 Tips

- You must declare a **protocol** like `@restJson1` on the service.
- Each operation must have an `@http(method: ..., uri: ...)` to be included in OpenAPI.
- Optional fields = omit from `required: []` in your structures.

---

## 📚 Resources

- Smithy Docs: https://smithy.io/2.0/
- Smithy OpenAPI Plugin: https://github.com/awslabs/smithy-openapi
- Smithy CLI Guide: https://smithy.io/2.0/guides/smithy-cli/cli_installation.html

There are IDE extensions available for syntax highlighting and autocomplete.

---

## 🐍 Using the Python Models in Lambda Functions

The generated Python models have been packaged as a proper Python package in the `/python` directory. There are two ways to use them:

### 1. Local Development (with live reload)

From the cdk directory, install the models in editable mode:

```bash
pip install -e file://$MODEL_CODE_PATH/python
```

This creates an editable install that automatically reflects any changes made to the models without needing to reinstall.

### 2. Via GH

Add this to your requirements.txt:

```
git+https://$GITHUB_READ_TOKEN@github.com/Equal-IQ/api-model.git@main#subdirectory=python&egg=api_model
```

### Example Usage

```python
# Import specific models
from api_model.types.models import PingResponseContent, GetContractResponseContent

# Create model instances
ping_response = PingResponseContent(message="Pong!")

# Serialize to JSON
json_data = ping_response.json()

# Deserialize from dict
contract = GetContractResponseContent(**data_dict)
```

## 🧠 Using the TypeScript Models in Frontend / Tests

The generated TypeScript models have been packaged as a proper npm package in the `/typescript` directory:

### 1. Local Development

Add the package to your project using a local path:

```bash
# From your frontend or test directory
npm install --save ../api-model/typescript
```

Or using yarn:

```bash
yarn add ../api-model/typescript
```

### 2. For Production/CI/CD

Add the package to your project using the GitHub repository:

```bash
# Install from main branch
npm install --save github:Equal-IQ/api-model

# Install from specific commit (recommended for version locking)
npm install --save github:Equal-IQ/api-model#abc123f

# Install from specific branch
npm install --save github:Equal-IQ/api-model#feature-branch
```

Or in your package.json:

```json
"dependencies": {
  "@equaliq/api-model": "github:Equal-IQ/api-model#main"
}
```

For version locking to a specific commit:

```json
"dependencies": {
  "@equaliq/api-model": "github:Equal-IQ/api-model#abc123f"
}
```

### Example Usage

```typescript
// Import specific interfaces
import { PingResponseContent, GetContractResponseContent } from '@equaliq/api-model';

// Use the interfaces
const pingResponse: PingResponseContent = { message: "Pong!" };

// Type checking for API responses
function handleApiResponse(response: GetContractResponseContent) {
  console.log(`Contract ${response.contractId} loaded`);
}
```
