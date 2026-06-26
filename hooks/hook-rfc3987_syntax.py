from PyInstaller.utils.hooks import collect_data_files

# rfc3987_syntax ships a Lark grammar (syntax_rfc3987.lark) that it loads at
# import time, so the data file must be collected or nbformat fails to import.
datas = collect_data_files("rfc3987_syntax")
