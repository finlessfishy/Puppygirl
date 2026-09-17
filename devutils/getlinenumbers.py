from pathlib import Path

line_count = 0

line_count += sum(1 for _ in open(Path(__file__).resolve().parent.parent / "main.lua", "r", encoding="utf-8"))
line_count += sum(1 for _ in open(Path(__file__).resolve().parent.parent / "interpreter.lua", "r", encoding="utf-8"))
line_count += sum(1 for _ in open(Path(__file__).resolve().parent.parent / "parser.lua", "r", encoding="utf-8"))
line_count += sum(1 for _ in open(Path(__file__).resolve().parent.parent / "utilities.lua", "r", encoding="utf-8"))
line_count += sum(1 for _ in open(Path(__file__).resolve().parent.parent / "runcode.py", "r", encoding="utf-8"))

print(f"Line count: {line_count}")