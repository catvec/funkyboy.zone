class bcolors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def print_diff(lines: str):
    """ Output a multi-line diff to sysout
    """
    for line in lines.split("\n"):
        color = ""
        if len(line) == 0:
            pass
        elif line[0] == "+":
            color = bcolors.GREEN
        elif line[0] == "-":
            color = bcolors.FAIL

        print(color + line + bcolors.ENDC)
            
