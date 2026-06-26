from PyInstaller.utils.hooks import collect_data_files, collect_submodules

# reproject's top-level __init__ only imports a handful of submodules
# (adaptive, healpix, interpolation, spherical_intersect), so PyInstaller never
# discovers reproject.hips or reproject.mosaicking, which are imported lazily
# when HiPS data is loaded. Collect every submodule so they end up in the
# bundle. Skip the test subpackages, which only pull in test-only dependencies.
hiddenimports = collect_submodules(
    "reproject", filter=lambda name: "tests" not in name.split(".")
)

# reproject.hips imports mocpy lazily inside functions; make sure it is bundled
# along with its compiled extension.
hiddenimports += ["mocpy"]

datas = collect_data_files("reproject")
