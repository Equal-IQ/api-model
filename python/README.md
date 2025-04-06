# EqualIQ API Model - Python Package

This package contains the Python API models generated from Smithy definitions. These models can be used by both the backend API implementation and client applications.

## Installation

### For Local Development

To install the package for local development (with live reloading):

```bash
# From the cdk directory
pip install -e ../api-model/python
```

This creates an editable install that automatically reflects any changes made to the models.

### For Production or CI/CD

Add this to your requirements.txt:

```
git+https://github.com/Equal-IQ/api-model.git@main#subdirectory=python&egg=api_model
```

Or install directly:

```bash
pip install git+https://github.com/Equal-IQ/api-model.git@main#subdirectory=python
```

## Usage

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