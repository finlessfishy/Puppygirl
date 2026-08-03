import sys



try:
	exec(sys.argv[1])
except Exception as e:
	print(f"PYTHON ERROR: {e}")