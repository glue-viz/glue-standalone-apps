import os
import sys
import time

from glue import load_plugins
from glue.logger import logger
from glue.app.qt import GlueApplication

os.environ['QTWEBENGINE_CHROMIUM_FLAGS'] = '--ignore-gpu-blacklist'

logger.setLevel("INFO")

load_plugins()

if __name__ == "__main__":

    ga = GlueApplication()

    if '--test' in sys.argv:

        ga.start(block=False)

        # Open a few viewers to test

        from glue.viewers.image.qt import ImageViewer
        ga.new_data_viewer(ImageViewer)

        from glue_wwt.viewer.qt_data_viewer import WWTQtViewer
        ga.new_data_viewer(WWTQtViewer)

        from glue_vispy_viewers.scatter.scatter_viewer import VispyScatterViewer
        ga.new_data_viewer(VispyScatterViewer)

        start = time.time()
        print("Waiting 5 seconds before closing...")
        while time.time() - start < 5:
            ga.app.processEvents()
    else:
        ga.start()
