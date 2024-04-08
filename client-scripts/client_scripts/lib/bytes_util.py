from typing import Optional, Tuple


def decode_bytes(value: bytes) -> Optional[str]:
    """ Converts bytes into a string. If no value is stored in bytes then None is returned.
    """
    if value is None or len(value) == 0:
        return None

    return value.decode("utf-8")

def decode_stdout_stderr(std_tuple: Tuple[bytes, bytes]) -> Tuple[Optional[str], Optional[str]]:
    """Converts (stdout, stderr) bytes tuple to strings.
    """
    return (decode_bytes(std_tuple[0]), decode_bytes(std_tuple[1]))