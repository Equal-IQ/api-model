# 🧬 EqualIQ API – Smithy Model

This package defines the EqualIQ API using [Smithy](https://smithy.io/) — a strongly typed interface modeling language. It enables consistent, validated types and OpenAPI documentation for the EqualIQ APIs

View the Smithy documentation:
https://smithy.io/2.0/index.html


---

## 🚀 Quickstart: Generate OpenAPI + Type Definitions

### 📦 Prerequisites

- Java 11+
- Gradle 7+ (Install via `brew install gradle` or [Gradle install guide](https://gradle.org/install/))

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
```

---

## Build the Project

From the project root, run:

```bash
./gradlew clean build
```

This will:

- Validate your Smithy model
- Generate OpenAPI in:

```
build/smithyprojections/openapi/source/openapi/equaliq.openapi.json
```

---

## Generate Python/TypeScript Types

### 🐍 Python (Pydantic)

```bash
pip install datamodel-code-generator

datamodel-codegen \
  --input build/smithyprojections/openapi/source/openapi/equaliq.openapi.json \
  --input-file-type openapi \
  --output models.py
```

### 🧠 TypeScript

```bash
npm install -g json-schema-to-typescript

json2ts -i build/smithyprojections/openapi/source/openapi/equaliq.openapi.json -o models.ts
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
(Other option available, but you may need to install other dependencies to build)
https://smithy.io/2.0/guides/smithy-cli/cli_installation.html

You can also install it via:
- macOS (Homebrew):
    brew install smithy-cli
- Linux (yum-based):
    sudo yum install java-17-openjdk
    curl -o smithy-cli.zip https://software.amazon.com/smithy-cli/latest.zip
    unzip smithy-cli.zip
    chmod +x smithy
- Windows (via GitHub Releases):
    Download and unzip from https://github.com/awslabs/smithy-cli/releases

There are IDE extensions available for syntax highlighting and autocomplete.
