import sys


if sys.platform == "darwin":
    XRUN_EXE = "/usr/local/bin/xvfb-run"
    WK_EXE = "/usr/local/bin/wkhtmltopdf"
elif "linux" in sys.platform:
    XRUN_EXE = "/usr/bin/xvfb-run"
    WK_EXE = "/usr/bin/wkhtmltopdf"
elif "win" in sys.platform:
    # To be defined on Windows.
    XRUN_EXE = ""
    WK_EXE = ""
else:
    raise RuntimeError(f"Unknown platform: {sys.platform}")


WK_PATH = f"{XRUN_EXE} {WK_EXE}"
