# Document converter to PDF

Simple robot example demonstrating how to convert DOC[X] files to PDF.

## How to run

- VSCode: "Cmd/Ctrl+Shift+P" -> "Run Robot" -> "Convert Doc To PDF"
- rcc: `rcc run -e devdata/env.json -t "Convert Doc To PDF"`
- Control Room: Create Process with Step **Convert Doc To PDF** from uploaded robot.

## Environment configuration

The robot can convert in different ways from custom sources, therefore please set the
following env vars:

- `DOC_ROOT`: The root directory from where the _*.doc[x]_ files are collected for
  conversion.
- `DOC_CONVERTER`: Should specify in which way the documents should be converted to
  PDFs:

  - `rpa-word`: Make use of `RPA.Word.Application` from **rpaframework**. (Windows)
  - `docx2pdf`: Use `convert` from **docx2pdf**. (Windows, Mac)
  - `libreoffice`: Run a
    [LibreOffice](https://www.libreoffice.org/download/download-libreoffice/) process.
    (Linux (Cloud Container), Mac, Windows)
