# -- Project information -----------------------------------------------------
project = "Polaris"
copyright = "2021, ItsMyCargo ApS"
author = ""

# -- General configuration ---------------------------------------------------
extensions = [
    "myst_parser",
    "sphinxcontrib.confluencebuilder",
    "sphinxcontrib.plantuml",
]

# UML
plantuml_output_format = "svg"

# Confluence
confluence_publish = True
confluence_page_hierarchy = True
confluence_purge = True
confluence_space_name = "DEV"
confluence_parent_page = "Documentation"
