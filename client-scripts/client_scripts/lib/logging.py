import sys

from loguru import logger as logging

logging.remove()
logging.add(sys.stdout, colorize=True, format="<green>{time:HH:mm:ss}</green> <level>{message}</level>")
logging.level("DEBUG", color="<dim>")