import email
import logging

from htmldocx import HtmlToDocx
from tidylib import tidy_document


# ---- BEGIN part of future changes in rpaframework library ---- 

def _get_part_filename(msg):
    filename = msg.get_filename()
    if filename and decode_header(filename)[0][1] is not None:
        filename = decode_header(filename)[0][0].decode(decode_header(filename)[0][1])
    if filename:
        filename = filename.replace("\r", "").replace("\n", "")
    return filename


def _get_decoded_email_body(message, html_first=False):
        """Decode email body.

        :param message_body: Raw 7-bit message body input e.g. from imaplib. Double
            encoded in quoted-printable and latin-1
        :return: Message body as unicode string and information if message has
            attachments

        Detect character set if the header is not set.
        We try to get text/plain, but if there is not one then fallback to text/html.
        """
        if not message.is_multipart():
            content_charset = message.get_content_charset()
            text = str(
                message.get_payload(decode=True),
                content_charset or "utf-8",
                "ignore",
            )
            return text.strip(), False
        
        text = ""
        html = None
        has_attachments = False
        
        for part in message.walk():
            content_filename = _get_part_filename(part)
            if content_filename:
                has_attachments = True
                continue

            content_charset = part.get_content_charset()
            if not content_charset:
                # We cannot know the character set, so return decoded "something"
                text = part.get_payload(decode=True)
                continue

            content_type = part.get_content_type()
            data = str(part.get_payload(decode=True), str(content_charset), "ignore")
            if content_type == "text/plain":
                text = data
            elif content_type == "text/html":
                html = data

        if html_first:
            data = html or text
        else:
            data = text or html
        return (
            (data.strip(), has_attachments) if data else ("", has_attachments)
        )

# ---- END part of future changes in rpaframework library ---- 


def _validate_html(content: str) -> str:
    document, errors = tidy_document(content, options={"numeric-entities": 1})
    logging.debug("HTML validation errors: %s", errors)
    return document


def email_to_dictionary(raw_email: str, validate: bool = True) -> dict:
    message = email.message_from_string(raw_email)
    message_dict = dict(message.items())
    body, _ = _get_decoded_email_body(message, html_first=True)  # need to add this support in the library
    message_dict["Body"] = _validate_html(body) if validate else body
    return message_dict


def html_to_docx(content: str, path):
    h2d_parser = HtmlToDocx()
    docx = h2d_parser.parse_html_string(content)
    docx.save(path)
