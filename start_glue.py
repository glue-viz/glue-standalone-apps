import sys
import time

from glue import load_plugins
from glue.logger import logger
from glue.app.qt import GlueApplication

logger.setLevel("INFO")

load_plugins()

if __name__ == "__main__":

    ga = GlueApplication()

    if '--nonblocking' in sys.argv:
        ga.start(block=False)
        start = time.time()
        print("Waiting 5 seconds before closing...")
        while time.time() - start < 5:
            ga.app.processEvents()
    else:
        ga.start()
