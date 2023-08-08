import os
import shutil
import subprocess
from pathlib import Path

import docx2pdf
from robocorp.tasks import task
from RPA.Word.Application import Application


APP = Application(autoexit=True)


def _rpa_doc_to_pdf(src, dest):
    try:
        APP.close_document()
    except Exception:
        pass
    APP.open_file(src)
    APP.export_to_pdf(dest)


def _libre_doc_to_pdf(src, dest):
    LOEXE = shutil.which("soffice")
    if not LOEXE:
        raise EnvironmentError("LibreOffice not found")

    cmd = [
        LOEXE, "--headless", "--convert-to", "pdf",
        "--outdir", str(Path(dest).parent), src
    ]
    subprocess.check_call(cmd, stderr=subprocess.STDOUT)


CONVERTERS = {
    "docx2pdf": docx2pdf.convert,
    "rpa-word": _rpa_doc_to_pdf,
    "libreoffice": _libre_doc_to_pdf,
}


def _get_document_paths():
    root = os.getenv("DOC_ROOT", "devdata")
    root = Path(root).expanduser().resolve()
    print(f"Collecting docs from directory: {root}")
    for candidate in root.iterdir():
        fname, ext = candidate.stem, candidate.suffix
        if "~" not in fname and ext.startswith(".doc"):
            yield candidate.resolve()


@task
def convert_doc_to_pdf():
    converter_str = os.getenv("DOC_CONVERTER", "libreoffice")
    print(f"Using converter: {converter_str}")
    converter = CONVERTERS[converter_str]
    if converter_str == "rpa-word":
        # No worries as the app will automatically close gracefully.
        APP.open_application()

    output_dir = Path("output").expanduser().resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    for src in _get_document_paths():
        dest = output_dir / f"{src.stem}.pdf"
        print(f"Converting {src} -> {dest}")
        converter(str(src), str(dest))
