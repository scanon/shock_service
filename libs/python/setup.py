#!/usr/bin/env python

from distutils.core import setup
import biokbase.shock

setup(name='biokbase.shock',
      version=biokbase.shock.__version__,
      author=biokbase.shock.__author__,
      license=biokbase.shock.__licence__,
      packages=['biokbase.shock'],
     )