About
=====

This repository is used to build standalone 'single-file' versions of the glue
application. It uses the `pyinstaller <https://pypi.org/project/pyinstaller/>`_
package running on GitHub Actions.

Anytime a commit is made to this repository, the workflow in
`build_applications.yml
<https://github.com/glue-viz/glue-standalone-apps/blob/main/.github/workflows/build_applications.yml>`_
is run on all three main operating systems. The general workflow is as follows:

* Set up Python
* Install PyInstaller
* Install glue as well as all desired optional dependencies/plugins
* Run PyInstaller
* Post-process the executables, e.g. renaming to include the version number or making a dmg file
* Uploading to S3 bucket (http://glueviz.s3.amazonaws.com/installers)

Executables are created with the branch or tag name in the filename, so there
will always be installed with 'main' in the name which reflect the latest
version of the main branch, and we can create tags for any 'frozen' version in
time that we want. This allows us to also maintain different branches with
different set of dependencies. At the end of the day, we just need to ensure
that tag names are unique, so for instance ``v?.?.?`` will typically be used for
the primary installers that we create, but one could also push tags along the
lines of ``v?.?.?-project1` for a specific project which might include some
additional dependencies.

While we avoid using conda in the main branch and for the primary releases, it
may be possible to use it in branches to install more complex dependencies on
all platforms.

To run this locally, follow the same steps as in `build_applications.yml
<https://github.com/glue-viz/glue-standalone-apps/blob/main/.github/workflows/build_applications.yml>`_.
You should always do this in a clean virtual environment or conda environment as
otherwise PyInstaller might pull in unrelated dependencies. A simplified version
of running this locally would be::

    python3.9 -m venv test-app
    source test-app/bin/activate
    pip install git+https://github.com/pyinstaller/pyinstaller
    pip install glue-core glue-vispy-viewers glue-wwt PyQt5==5.14.2 PyQtWebEngine==5.14.0
    pyinstaller glue_app.spec

The resulting application will be in the ``dist/`` folder.
