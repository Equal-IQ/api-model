"""
Python Pydantic model generator for EqualIQ API.
This script converts OpenAPI definitions to Pydantic models.
"""

import sys
import json
import os
from datamodel_code_generator import InputFileType, generate

def main():
    # Check if we have the right arguments
    if len(sys.argv) < 3:
        print("Usage: python generate-python-types.py <input_openapi_json> <output_python_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    # Check if the input file exists
    if not os.path.exists(input_file):
        print(f"Error: Input file not found: {input_file}")
        sys.exit(1)
    
    # Generate the models
    generate(
        input_file,
        input_file_type=InputFileType.OpenAPI,
        output=output_file,
    )
    
    print(f"Successfully generated Python models: {output_file}")

if __name__ == "__main__":
    main()