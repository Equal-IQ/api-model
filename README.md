# 🧬 EqualIQ API – Smithy Model

This package defines the EqualIQ API using [Smithy](https://smithy.io/) — a strongly typed interface modeling language. It enables consistent, validated types and OpenAPI documentation for the EqualIQ APIs

View the Smithy documentation:
https://smithy.io/2.0/index.html


---

## 🚀 Quickstart: Generate OpenAPI + Type Definitions

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
├── Dockerfile               # For containerized builds
├── build-docker.sh          # Run Smithy build in Docker
├── build-types.sh           # Generate Python/TypeScript in Docker
```

---

## Build the Project

### Containerized Build (Recommended)

For a completely containerized build without requiring local installations:

```bash
# Make scripts executable (first time only)
chmod +x build-docker.sh build-types.sh

# Run the Smithy build in Docker
./build-docker.sh
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
# Generate both Python and TypeScript
./build-types.sh --all --output-dir ./types

# Or generate just Python
./build-types.sh --python --output-dir ./types

# Or generate just TypeScript
./build-types.sh --typescript --output-dir ./types
```

This will:
- Run the Smithy build first if needed
- Use Docker containers to generate the types
- Output the files to the specified directory

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
