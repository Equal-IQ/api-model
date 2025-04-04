This package defines a Smithy model.

It's a description of the API that can generate validated types across a variety of languages,
including Python and TypeScript.

View the Smithy documentation:
https://smithy.io/2.0/index.html

Install the Smithy CLI:

wget https://repo1.maven.org/maven2/software/amazon/smithy/cli/0.5.3/cli-0.5.3.jar -O smithy-cli.jar

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

---
🛠️ Build and Validate:

Once the CLI is installed, run:

    smithy build

This will validate the model and run any configured projections.

---
🔁 Optional: Generate OpenAPI

To generate an OpenAPI spec from the model, download the plugin:

    wget https://repo1.maven.org/maven2/software/amazon/smithy/smithy-openapi/1.31.0/smithy-openapi-1.31.0.jar

Then run:

    smithy build --classpath smithy-openapi-1.31.0.jar

This will produce an OpenAPI file at:

    build/smithyprojections/openapi/source/openapi/<your-service>.openapi.json

---
🐍 Generate Python Types

Install code generator:

    pip install datamodel-code-generator

Then run:

    datamodel-codegen --input build/smithyprojections/openapi/source/openapi/<your-service>.openapi.json --input-file-type openapi --output models.py

---
🧾 Generate TypeScript Types

Install quicktype:

    npm install -g quicktype

Then run:

    quicktype -l ts -s schema build/smithyprojections/openapi/source/openapi/<your-service>.openapi.json -o models.ts

---
That's it! You now have a validated API model that can power typed code across multiple languages.
