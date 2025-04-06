from setuptools import setup, find_packages

setup(
    name="api_model",
    version="0.1.0",
    packages=["api_model"],
    package_dir={"api_model": "."},  # Root directory is the package
    description="EqualIQ API models generated from Smithy",
    author="EqualIQ Team",
    install_requires=[
        "pydantic<2.0.0",  # Use Pydantic v1 which supports regex in constr
    ],
)