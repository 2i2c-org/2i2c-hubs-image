#!/bin/bash -l

# Install jupyter-contrib-nbextensions
jupyter contrib nbextension install --sys-prefix --symlink

# Configure spellchecker and toc2
echo '{\n"load_extensions": {\n"spellchecker/main": true,\n"toc2/main": true,\n"nbextensions_configurator/config_menu/main": false,\n"contrib_nbextensions_help_item/main": false\n},\n"toc2": {\n"widenNotebook": false,\n"moveMenuLeft": false,\n"number_sections": false,\n"toc_window_display": false\n}\n}' > ~/.jupyter/nbconfig/notebook.json
