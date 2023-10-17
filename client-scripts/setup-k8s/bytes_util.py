from typing import Optional


def decode_bytes(value: bytes) -> Optional[str]:
    """ Converts bytes into a string. If no value is stored in bytes then None is returned.
    """
    if value is None or len(value) == 0:
        return None

    return value.decode("utf-8")