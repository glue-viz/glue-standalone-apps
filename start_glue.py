from glue import qglue, load_plugins
from glue.logger import logger

logger.setLevel("INFO")

load_plugins()

if __name__ == "__main__":
    qglue()
