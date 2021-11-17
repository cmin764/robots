#! /usr/bin/env python3

import sys
import os

import pdfkit
from pdfkit.configuration import Configuration
from pdfkit.pdfkit import PDFKit


# On Mac
# XRUN_EXE = "/usr/local/bin/xvfb-run"
# WK_EXE = "/usr/local/bin/wkhtmltopdf"

# On Linux
XRUN_EXE = "/usr/bin/xvfb-run"
WK_EXE = "/usr/bin/wkhtmltopdf"


class CustomConfiguration(Configuration):

    def __init__(self, wkhtmltopdf='', meta_tag_prefix='pdfkit-', environ=''):
        self.meta_tag_prefix = meta_tag_prefix

        self.wkhtmltopdf = wkhtmltopdf

        try:
            lines = self.wkhtmltopdf.split()
            for line in lines:
                with open(line) as f:
                    pass
        except (IOError, FileNotFoundError) as e:
            raise IOError(f'No executable found: {line!r}\n'
                          'If this file exists please check that this process can '
                          'read it or you can pass path to it manually in method call, '
                          'check README. Otherwise please install wkhtmltopdf - '
                          'https://github.com/JazzCore/python-pdfkit/wiki/Installing-wkhtmltopdf')


        self.environ = environ

        if not self.environ:
            self.environ = os.environ

        for key in self.environ.keys():
            if not isinstance(self.environ[key], str):
                self.environ[key] = str(self.environ[key])


class CustomPDFKit(PDFKit):

    def _command(self, path=None):
        params = iter(super()._command(path=path))
        
        exe = next(params)
        for line in exe.split():
            yield line
        
        for param in params:
            yield param


pdfkit.api.PDFKit = CustomPDFKit


def Convert_HTML_To_PDF(html: str, pdfFileName: str, pdfConverter: str):
    config = CustomConfiguration(wkhtmltopdf=pdfConverter)
    pdfkit.from_string(html, pdfFileName, configuration=config)


def Convert_HTML_File_To_PDF(path: str, pdfFileName: str, pdfConverter: str):
    config = CustomConfiguration(wkhtmltopdf=pdfConverter)
    pdfkit.from_url(path, pdfFileName, configuration=config)


if __name__ == "__main__":
    # with open(sys.argv[1]) as stream:
    #     data = stream.read()  # reads HTML content from file path passed as CLI argument
    # Convert_HTML_To_PDF(data, sys.argv[2], pdfConverter=f"{XRUN_EXE} {WK_EXE}")
    Convert_HTML_File_To_PDF(sys.argv[1], sys.argv[2], pdfConverter=f"{XRUN_EXE} {WK_EXE}")
