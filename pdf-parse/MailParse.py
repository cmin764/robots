import email

from RPA.Email.ImapSmtp import ImapSmtp


def email_to_dictionary(raw_email: str) -> dict:
    message = email.message_from_string(raw_email)
    message_dict = dict(message.items())
    body, _ = ImapSmtp().get_decoded_email_body(message)
    message_dict["Body"] = body
    return message_dict
