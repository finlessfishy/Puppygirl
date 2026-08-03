import sys

try:
    with open(sys.argv[1], "r") as f:
        code = f.read()
    exec(code)
except Exception as e:
    print(f"PYTHON ERROR: {e}")