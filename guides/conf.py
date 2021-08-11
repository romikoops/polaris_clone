# -- Project information -----------------------------------------------------
project = "Polaris"
copyright = "2021, ItsMyCargo ApS"
author = ""

# -- General configuration ---------------------------------------------------
extensions = [
    "myst_parser",
    "sphinxcontrib.confluencebuilder",
]

# Confluence
confluence_publish = True
confluence_page_hierarchy = True
confluence_purge = True
confluence_space_name = "KB"
confluence_parent_page = "Guides"
