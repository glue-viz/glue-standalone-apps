import sys

print("start_glue.py called with arguments", sys.argv)

# Exit early if this was launched by multiprocessing
for arg in sys.argv:
    if 'multiprocessing' in arg:
        print('Killed forked process')
        sys.exit(0)

import os
import time

from pywwt import qt
from glue import load_plugins
from glue.logger import logger
from glue_qt.app import GlueApplication

qt.APP_LIVELINESS_DEADLINE = 60

os.environ["QTWEBENGINE_CHROMIUM_FLAGS"] = "--ignore-gpu-blacklist"

if __name__ == "__main__":

    print(sys.argv)

    #if os.path.exists('/tmp/gluelock'):
    #    raise Exception("glue lock already exists")

    #with open('/tmp/gluelock', 'w') as f:
    #    f.write('Denied!')

    if '--debug' in sys.argv or '--test' in sys.argv:
        logger.setLevel("INFO")

    load_plugins()

    if '--debug' in sys.argv:
        import faulthandler

        faulthandler.enable()

    for arg in sys.argv:
        if arg.endswith(".glu"):
            session = arg
            break
    else:
        session = None

    if session:
        ga = GlueApplication.restore_session(session)
        ga.app.exec_()

    else:
        ga = GlueApplication()

        if "--test" in sys.argv:
            ga.start(block=False)

            # Open a few viewers to test

            from glue_qt.viewers.image import ImageViewer

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
