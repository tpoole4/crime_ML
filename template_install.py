# -*- coding: utf-8 -*-

import subprocess

from pkg_resources import WorkingSet, DistributionNotFound
from setuptools.command.easy_install import main as install

working_set = WorkingSet()

# Detecting if module is installed
try:
    dep = working_set.require('nb_pdf_template')

except DistributionNotFound:
    print("Starting one-time install of templates for your PDF export.")
    install(['nb_pdf_template'])
    subprocess.Popen(["python", "-m", "nb_pdf_template.install", "--minted"])
