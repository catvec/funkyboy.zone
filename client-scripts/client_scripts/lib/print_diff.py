from typing import Optional

COLOR_GREEN = "\033[92m"
COLOR_RED = "\033[91m"
COLOR_RESET = "\033[0m"


def print_diff(lines: Optional[str]):
    """ Output a multi-line diff to sysout
    """
    if lines is None:
        return
    for line in lines.split("\n"):
        color = ""
        if len(line) == 0:
            pass
        elif line[0] == "+":
            color = COLOR_GREEN
        elif line[0] == "-":
            color = COLOR_RED

        print(color + line + COLOR_RESET)
            
