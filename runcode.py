import sys

def warningcheck(c):
    warnings = []
    if "open(" in c and "as" in c:
        warnings.append("Read file(s)")
    if ".remove(" in c:
        warnings.append("Delete file(s)")
    if ".rmdir(" in c:
        warnings.append("Delete folder(s)")
    if ".rename(" in c:
        warnings.append("Rename/Move file(s)")
    if ".rmtree(" in c:
        warnings.append("Delete folder(s) and everything in them")
    if ".system(" in c:
        warnings.append("Run system commands")
    return warnings

if __name__ == "__main__":
    mode = sys.argv[1]
    script_path = sys.argv[2]

    with open(script_path, "r") as f:
        code = f.read()

    if mode == "scan":
        for warning in warningcheck(code):
            print(warning)
    elif mode == "run":
        try:
            exec(code)
        except Exception as e:
            print(f"PYTHON ERROR: {e}")