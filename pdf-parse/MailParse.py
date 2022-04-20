import email
import sys

from htmldocx import HtmlToDocx
# from tidylib import tidy_document
from RPA.Email.ImapSmtp import ImapSmtp


def validate_html(content: str) -> str:
    return content
    document, errors = tidy_document(content, options={"numeric-entities": 1})
    print("Errors: ", errors)
    return document


def email_to_dictionary(raw_email: str) -> dict:
    message = email.message_from_string(raw_email)
    message_dict = dict(message.items())
    body, _ = ImapSmtp().get_decoded_email_body(message)
    message_dict["Body"] = validate_html(body)
    return message_dict


def html_to_docx(content: str, path):
    h2d_parser = HtmlToDocx()
    docx = h2d_parser.parse_html_string(content)
    docx.save(path)


def dummy_func():
    path = sys.path
    print(path)
