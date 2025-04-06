# This file marks the root directory as a Python package
import sys
import os

# Make the types directory accessible via 'from api_model.types import models'
current_dir = os.path.dirname(os.path.abspath(__file__))
types_dir = os.path.join(current_dir, 'types')
if types_dir not in sys.path:
    sys.path.insert(0, current_dir)