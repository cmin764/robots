from openpyxl.cell import _writer as cell_writer
from openpyxl.cell._writer import lxml_write_cell
from openpyxl.worksheet import _writer as worksheet_writer


def extended_lxml_write_cell(xf, worksheet, cell, styled=False):
    if cell.data_type == 's':
        cell._value = cell._value.strip()
    return lxml_write_cell(xf, worksheet, cell, styled=styled)


cell_writer.whitespace = lambda node: None
if worksheet_writer.write_cell.__name__ == "lxml_write_cell":
    worksheet_writer.write_cell = extended_lxml_write_cell


from RPA.Excel.Files import Files


class ExtendedExcelFiles(Files):

    pass
