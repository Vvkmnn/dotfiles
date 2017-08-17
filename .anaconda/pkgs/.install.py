# (c) 2012-2016 Continuum Analytics, Inc. / http://continuum.io
# All Rights Reserved
#
# conda is distributed under the terms of the BSD 3-clause license.
# Consult LICENSE.txt or http://opensource.org/licenses/BSD-3-Clause.
'''
We use the following conventions in this module:

    dist:        canonical package name, e.g. 'numpy-1.6.2-py26_0'

    ROOT_PREFIX: the prefix to the root environment, e.g. /opt/anaconda

    PKGS_DIR:    the "package cache directory", e.g. '/opt/anaconda/pkgs'
                 this is always equal to ROOT_PREFIX/pkgs

    prefix:      the prefix of a particular environment, which may also
                 be the root environment

Also, this module is directly invoked by the (self extracting) tarball
installer to create the initial environment, therefore it needs to be
standalone, i.e. not import any other parts of `conda` (only depend on
the standard library).
'''
import os
import re
import sys
import json
import shutil
import stat
from os.path import abspath, dirname, exists, isdir, isfile, islink, join
from optparse import OptionParser


on_win = bool(sys.platform == 'win32')
try:
    FORCE = bool(int(os.getenv('FORCE', 0)))
except ValueError:
    FORCE = False

LINK_HARD = 1
LINK_SOFT = 2  # never used during the install process
LINK_COPY = 3
link_name_map = {
    LINK_HARD: 'hard-link',
    LINK_SOFT: 'soft-link',
    LINK_COPY: 'copy',
}
SPECIAL_ASCII = '$!&\%^|{}[]<>~`"\':;?@*#'

# these may be changed in main()
ROOT_PREFIX = sys.prefix
PKGS_DIR = join(ROOT_PREFIX, 'pkgs')
SKIP_SCRIPTS = False
IDISTS = {
  "_license-1.1-py36_1": {
    "md5": "7b6fdd593f8115c6503b0f929136788a", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/_license-1.1-py36_1.tar.bz2"
  }, 
  "alabaster-0.7.10-py36_0": {
    "md5": "0b33f1a845af6c57c5af4240d434a3df", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/alabaster-0.7.10-py36_0.tar.bz2"
  }, 
  "anaconda-4.4.0-np112py36_0": {
    "md5": "d391c006a0d7eea5a8e794ccc6b94cf6", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/anaconda-4.4.0-np112py36_0.tar.bz2"
  }, 
  "anaconda-client-1.6.3-py36_0": {
    "md5": "cd2cf3d3b2e2f685390c78f260cdeb7b", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/anaconda-client-1.6.3-py36_0.tar.bz2"
  }, 
  "anaconda-navigator-1.6.2-py36_0": {
    "md5": "74418a6cb4ea29010b066c6bdc6804ac", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/anaconda-navigator-1.6.2-py36_0.tar.bz2"
  }, 
  "anaconda-project-0.6.0-py36_0": {
    "md5": "a4cfd8e5253dc229846fa6420a26e8a6", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/anaconda-project-0.6.0-py36_0.tar.bz2"
  }, 
  "appnope-0.1.0-py36_0": {
    "md5": "64cb3efe71361d2bad869bd255d4e305", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/appnope-0.1.0-py36_0.tar.bz2"
  }, 
  "appscript-1.0.1-py36_0": {
    "md5": "5ff52e4edff8a98ae8c7287959df834c", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/appscript-1.0.1-py36_0.tar.bz2"
  }, 
  "asn1crypto-0.22.0-py36_0": {
    "md5": "d0d40ea96886244eef38b08b7a308c57", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/asn1crypto-0.22.0-py36_0.tar.bz2"
  }, 
  "astroid-1.4.9-py36_0": {
    "md5": "9bef80a36f51a0ef2eb53a94dc6b733a", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/astroid-1.4.9-py36_0.tar.bz2"
  }, 
  "astropy-1.3.2-np112py36_0": {
    "md5": "6840b725b45f5b003f085f94e8bb79e7", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/astropy-1.3.2-np112py36_0.tar.bz2"
  }, 
  "babel-2.4.0-py36_0": {
    "md5": "dbac8b4b2b1442f59c57603289656ba3", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/babel-2.4.0-py36_0.tar.bz2"
  }, 
  "backports-1.0-py36_0": {
    "md5": "94f784b841a979b29c23821783446da2", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/backports-1.0-py36_0.tar.bz2"
  }, 
  "beautifulsoup4-4.6.0-py36_0": {
    "md5": "5d32b256ab0039edc5afd4ea808aa8f9", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/beautifulsoup4-4.6.0-py36_0.tar.bz2"
  }, 
  "bitarray-0.8.1-py36_0": {
    "md5": "1791e541b466f7daa72619ea2b4ab85b", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/bitarray-0.8.1-py36_0.tar.bz2"
  }, 
  "blaze-0.10.1-py36_0": {
    "md5": "4e1640411fa228305389ae5191c56a1c", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/blaze-0.10.1-py36_0.tar.bz2"
  }, 
  "bleach-1.5.0-py36_0": {
    "md5": "ad61b91975b0521eebb5d13a36171113", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/bleach-1.5.0-py36_0.tar.bz2"
  }, 
  "bokeh-0.12.5-py36_1": {
    "md5": "c20f31ab6c17ff6110b1bae3d721af22", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/bokeh-0.12.5-py36_1.tar.bz2"
  }, 
  "boto-2.46.1-py36_0": {
    "md5": "12e493410111ff3b9369a4e9cd31af94", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/boto-2.46.1-py36_0.tar.bz2"
  }, 
  "bottleneck-1.2.1-np112py36_0": {
    "md5": "37872ce36e6feaead7cf618a4c335141", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/bottleneck-1.2.1-np112py36_0.tar.bz2"
  }, 
  "cffi-1.10.0-py36_0": {
    "md5": "953df61a78f2d32aa66105d83497e6d8", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/cffi-1.10.0-py36_0.tar.bz2"
  }, 
  "chardet-3.0.3-py36_0": {
    "md5": "72b67594a3411aa92bbb4f042800c73c", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/chardet-3.0.3-py36_0.tar.bz2"
  }, 
  "click-6.7-py36_0": {
    "md5": "e6094f1f4833331bc4230b7d74c2f997", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/click-6.7-py36_0.tar.bz2"
  }, 
  "cloudpickle-0.2.2-py36_0": {
    "md5": "65fd4fddb41b6d90735ee3e71d1cccb2", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/cloudpickle-0.2.2-py36_0.tar.bz2"
  }, 
  "clyent-1.2.2-py36_0": {
    "md5": "ca0a59f7b1e87531aed5fa2f3e8b885a", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/clyent-1.2.2-py36_0.tar.bz2"
  }, 
  "colorama-0.3.9-py36_0": {
    "md5": "5a3cf33470b590f3905b25e15f6a45c1", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/colorama-0.3.9-py36_0.tar.bz2"
  }, 
  "conda-4.3.21-py36_0": {
    "md5": "970ed0ddca0e6815c9b5dbaf75b945d6", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/conda-4.3.21-py36_0.tar.bz2"
  }, 
  "conda-env-2.6.0-0": {
    "md5": "4bcba5618e1c70cbfb5107c3e61f2488", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/conda-env-2.6.0-0.tar.bz2"
  }, 
  "contextlib2-0.5.5-py36_0": {
    "md5": "2ade342ccac621b0045f3e9226fdb9b3", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/contextlib2-0.5.5-py36_0.tar.bz2"
  }, 
  "cryptography-1.8.1-py36_0": {
    "md5": "5778564819ec99649d790e3c0c9ddac9", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/cryptography-1.8.1-py36_0.tar.bz2"
  }, 
  "curl-7.52.1-0": {
    "md5": "d3ec98ab8d47c79644b235cb37cd46e6", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/curl-7.52.1-0.tar.bz2"
  }, 
  "cycler-0.10.0-py36_0": {
    "md5": "bbf54b185de9223f4bd3b646da46ff23", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/cycler-0.10.0-py36_0.tar.bz2"
  }, 
  "cython-0.25.2-py36_0": {
    "md5": "1d45bd42424358e16a54d8366fa6564d", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/cython-0.25.2-py36_0.tar.bz2"
  }, 
  "cytoolz-0.8.2-py36_0": {
    "md5": "cd6068b2389b1596147cc7218f0438fd", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/cytoolz-0.8.2-py36_0.tar.bz2"
  }, 
  "dask-0.14.3-py36_1": {
    "md5": "6c21d41b7844e52cb11a9da48252ad44", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/dask-0.14.3-py36_1.tar.bz2"
  }, 
  "datashape-0.5.4-py36_0": {
    "md5": "204284559b03a7e8df6b5eb6c3c0306f", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/datashape-0.5.4-py36_0.tar.bz2"
  }, 
  "decorator-4.0.11-py36_0": {
    "md5": "ca9a6c895357ee39bb0f23e66e73fe73", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/decorator-4.0.11-py36_0.tar.bz2"
  }, 
  "distributed-1.16.3-py36_0": {
    "md5": "8bce65c094bc9ac250200483245703ef", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/distributed-1.16.3-py36_0.tar.bz2"
  }, 
  "docutils-0.13.1-py36_0": {
    "md5": "c7706ef8aa7e3a54843a5c9e47017b50", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/docutils-0.13.1-py36_0.tar.bz2"
  }, 
  "entrypoints-0.2.2-py36_1": {
    "md5": "cff8161c99ede4b5cd69cc7f9b528d6b", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/entrypoints-0.2.2-py36_1.tar.bz2"
  }, 
  "et_xmlfile-1.0.1-py36_0": {
    "md5": "fd26bb01dacfb44efce2b12fa8fa1b01", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/et_xmlfile-1.0.1-py36_0.tar.bz2"
  }, 
  "fastcache-1.0.2-py36_1": {
    "md5": "77410beb8c6aa9070a5570e9a392aca4", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/fastcache-1.0.2-py36_1.tar.bz2"
  }, 
  "flask-0.12.2-py36_0": {
    "md5": "471ecb270a8fb8adbdd5c06aca802609", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/flask-0.12.2-py36_0.tar.bz2"
  }, 
  "flask-cors-3.0.2-py36_0": {
    "md5": "26101c41d492e94f4e0886784b8f907c", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/flask-cors-3.0.2-py36_0.tar.bz2"
  }, 
  "freetype-2.5.5-2": {
    "md5": "dde9e65b94586ffb83521a3ebb79583c", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/freetype-2.5.5-2.tar.bz2"
  }, 
  "get_terminal_size-1.0.0-py36_0": {
    "md5": "18e0d7b3a41cb06a5b4a6a7d902b76f6", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/get_terminal_size-1.0.0-py36_0.tar.bz2"
  }, 
  "gevent-1.2.1-py36_0": {
    "md5": "d7efb26580e1cdbfb124bbe2d1bc726b", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/gevent-1.2.1-py36_0.tar.bz2"
  }, 
  "greenlet-0.4.12-py36_0": {
    "md5": "c672b642627927fdefb9b53e04077131", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/greenlet-0.4.12-py36_0.tar.bz2"
  }, 
  "h5py-2.7.0-np112py36_0": {
    "md5": "ffba8ffe30a5a3b8237e88b39053095f", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/h5py-2.7.0-np112py36_0.tar.bz2"
  }, 
  "hdf5-1.8.17-1": {
    "md5": "6792a8a91a1dc1424eba2770526494b3", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/hdf5-1.8.17-1.tar.bz2"
  }, 
  "heapdict-1.0.0-py36_1": {
    "md5": "82998a74a66d5bda6c51d831fc72e96e", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/heapdict-1.0.0-py36_1.tar.bz2"
  }, 
  "html5lib-0.999-py36_0": {
    "md5": "bba56adb42aa664f5c682b6407b53b9c", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/html5lib-0.999-py36_0.tar.bz2"
  }, 
  "icu-54.1-0": {
    "md5": "a258fa9436d5d314b99c1776b523f3d5", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/icu-54.1-0.tar.bz2"
  }, 
  "idna-2.5-py36_0": {
    "md5": "3d12cb921c98d173c1f26a1f04c0407f", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/idna-2.5-py36_0.tar.bz2"
  }, 
  "imagesize-0.7.1-py36_0": {
    "md5": "f46d0495f865e32bfb0e4a93db558285", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/imagesize-0.7.1-py36_0.tar.bz2"
  }, 
  "ipykernel-4.6.1-py36_0": {
    "md5": "e2f5c1b30fa8558463528a7c8f48284c", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/ipykernel-4.6.1-py36_0.tar.bz2"
  }, 
  "ipython-5.3.0-py36_0": {
    "md5": "abdc6cd551ab3ed99c1e73a237c4c19b", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/ipython-5.3.0-py36_0.tar.bz2"
  }, 
  "ipython_genutils-0.2.0-py36_0": {
    "md5": "3f3e3fb9e3115c489cf1fcd0f8b1d497", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/ipython_genutils-0.2.0-py36_0.tar.bz2"
  }, 
  "ipywidgets-6.0.0-py36_0": {
    "md5": "811a7803a29abce640cd3302a7c5099e", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/ipywidgets-6.0.0-py36_0.tar.bz2"
  }, 
  "isort-4.2.5-py36_0": {
    "md5": "f3d30cb1445e3cb1fd2cfed8524b2965", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/isort-4.2.5-py36_0.tar.bz2"
  }, 
  "itsdangerous-0.24-py36_0": {
    "md5": "4c6447e987c385b1ff96d9dafeb73150", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/itsdangerous-0.24-py36_0.tar.bz2"
  }, 
  "jbig-2.1-0": {
    "md5": "14a3be6a622b2fed0b36430b4b4b544c", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/jbig-2.1-0.tar.bz2"
  }, 
  "jdcal-1.3-py36_0": {
    "md5": "55f66d135bc7ee1866b2048ccc13ca25", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/jdcal-1.3-py36_0.tar.bz2"
  }, 
  "jedi-0.10.2-py36_2": {
    "md5": "b83f85eca934970a15fa0cf488a8e88e", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/jedi-0.10.2-py36_2.tar.bz2"
  }, 
  "jinja2-2.9.6-py36_0": {
    "md5": "144eca5423f748cca10fdb4ff0b2d51d", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/jinja2-2.9.6-py36_0.tar.bz2"
  }, 
  "jpeg-9b-0": {
    "md5": "9430f9f41041e43672a4668e7225f6f3", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/jpeg-9b-0.tar.bz2"
  }, 
  "jsonschema-2.6.0-py36_0": {
    "md5": "65cb65e5589ce9f08b31513bce0680c6", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/jsonschema-2.6.0-py36_0.tar.bz2"
  }, 
  "jupyter-1.0.0-py36_3": {
    "md5": "1b0e9cede848f360f0f6b5920bcf003e", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/jupyter-1.0.0-py36_3.tar.bz2"
  }, 
  "jupyter_client-5.0.1-py36_0": {
    "md5": "88a0a671443c1e09aa49a409c488673b", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/jupyter_client-5.0.1-py36_0.tar.bz2"
  }, 
  "jupyter_console-5.1.0-py36_0": {
    "md5": "fd7d1990aa2a0b4e73dc68b1ee5bf7cd", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/jupyter_console-5.1.0-py36_0.tar.bz2"
  }, 
  "jupyter_core-4.3.0-py36_0": {
    "md5": "8d29c29108eb70f1fa57b8de92fd0aaf", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/jupyter_core-4.3.0-py36_0.tar.bz2"
  }, 
  "lazy-object-proxy-1.2.2-py36_0": {
    "md5": "8b95ca8fb9c87e8d919a1e05a15233c3", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/lazy-object-proxy-1.2.2-py36_0.tar.bz2"
  }, 
  "libiconv-1.14-0": {
    "md5": "7eece6c601d25120570bc50acc185439", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/libiconv-1.14-0.tar.bz2"
  }, 
  "libpng-1.6.27-0": {
    "md5": "f6b16c1a8b9a704fc691baf38256e9a8", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/libpng-1.6.27-0.tar.bz2"
  }, 
  "libtiff-4.0.6-3": {
    "md5": "6de126c5b033d5cf87fc01f7a0e033a1", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/libtiff-4.0.6-3.tar.bz2"
  }, 
  "libxml2-2.9.4-0": {
    "md5": "f1747fbea83ba808267c4ae1c94aa6e5", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/libxml2-2.9.4-0.tar.bz2"
  }, 
  "libxslt-1.1.29-0": {
    "md5": "473b9143e880e223a806f5c668a12dab", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/libxslt-1.1.29-0.tar.bz2"
  }, 
  "llvmlite-0.18.0-py36_0": {
    "md5": "0b24877fef135a30ca112cb4a34f8f0a", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/llvmlite-0.18.0-py36_0.tar.bz2"
  }, 
  "locket-0.2.0-py36_1": {
    "md5": "fd8516eecc07709856dd70f95d60d39b", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/locket-0.2.0-py36_1.tar.bz2"
  }, 
  "lxml-3.7.3-py36_0": {
    "md5": "a9c888eae877595d785f67fa04cac37f", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/lxml-3.7.3-py36_0.tar.bz2"
  }, 
  "markupsafe-0.23-py36_2": {
    "md5": "61a258635524ca412f09b35b1c55e0f4", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/markupsafe-0.23-py36_2.tar.bz2"
  }, 
  "matplotlib-2.0.2-np112py36_0": {
    "md5": "b0392a0e79062a8ac79314cce6258e47", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/matplotlib-2.0.2-np112py36_0.tar.bz2"
  }, 
  "mistune-0.7.4-py36_0": {
    "md5": "a798a0f8b917dfc8560809bcbbe64de8", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/mistune-0.7.4-py36_0.tar.bz2"
  }, 
  "mkl-2017.0.1-0": {
    "md5": "dbcfd6ad6dbde788f147db0093681206", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/mkl-2017.0.1-0.tar.bz2"
  }, 
  "mkl-service-1.1.2-py36_3": {
    "md5": "6f3a19dd8d922b1bf8b70166bf152926", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/mkl-service-1.1.2-py36_3.tar.bz2"
  }, 
  "mpmath-0.19-py36_1": {
    "md5": "d9282141759a639247567dd179489979", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/mpmath-0.19-py36_1.tar.bz2"
  }, 
  "msgpack-python-0.4.8-py36_0": {
    "md5": "12e2ecf41bbefc4aa53861d2d94015d9", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/msgpack-python-0.4.8-py36_0.tar.bz2"
  }, 
  "multipledispatch-0.4.9-py36_0": {
    "md5": "92a6b17d4378d8ebcfda82a2493974b9", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/multipledispatch-0.4.9-py36_0.tar.bz2"
  }, 
  "navigator-updater-0.1.0-py36_0": {
    "md5": "16f699de3000955eccc7893446230b1a", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/navigator-updater-0.1.0-py36_0.tar.bz2"
  }, 
  "nbconvert-5.1.1-py36_0": {
    "md5": "6f776f458e9cd651115ab034d51dda6c", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/nbconvert-5.1.1-py36_0.tar.bz2"
  }, 
  "nbformat-4.3.0-py36_0": {
    "md5": "182554c15f62fbe7a9ff13d0e32a6f9d", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/nbformat-4.3.0-py36_0.tar.bz2"
  }, 
  "networkx-1.11-py36_0": {
    "md5": "6a63f817ec99d93bcf9f49e3e87f5c4b", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/networkx-1.11-py36_0.tar.bz2"
  }, 
  "nltk-3.2.3-py36_0": {
    "md5": "95b28b534299cbd053267403d71069b4", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/nltk-3.2.3-py36_0.tar.bz2"
  }, 
  "nose-1.3.7-py36_1": {
    "md5": "000d05881390d878889499f289c5324a", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/nose-1.3.7-py36_1.tar.bz2"
  }, 
  "notebook-5.0.0-py36_0": {
    "md5": "0c40b4249440ade9f8e9407dec5f5c37", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/notebook-5.0.0-py36_0.tar.bz2"
  }, 
  "numba-0.33.0-np112py36_0": {
    "md5": "cba5102915d5a84e8aab993281272758", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/numba-0.33.0-np112py36_0.tar.bz2"
  }, 
  "numexpr-2.6.2-np112py36_0": {
    "md5": "3149cecaf81eb2ab6aafe9c05d8d3b92", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/numexpr-2.6.2-np112py36_0.tar.bz2"
  }, 
  "numpy-1.12.1-py36_0": {
    "md5": "08dfab31e8cf0676bec1c41a49659178", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/numpy-1.12.1-py36_0.tar.bz2"
  }, 
  "numpydoc-0.6.0-py36_0": {
    "md5": "aab916b29fd5c55f735853ce62a69495", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/numpydoc-0.6.0-py36_0.tar.bz2"
  }, 
  "odo-0.5.0-py36_1": {
    "md5": "dff5109289dcd5bf4e3eb253da32a5f1", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/odo-0.5.0-py36_1.tar.bz2"
  }, 
  "olefile-0.44-py36_0": {
    "md5": "884198509f36a156540a98bf70b0f1d6", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/olefile-0.44-py36_0.tar.bz2"
  }, 
  "openpyxl-2.4.7-py36_0": {
    "md5": "24318d92bc58e3f47359c3bf2825ea8c", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/openpyxl-2.4.7-py36_0.tar.bz2"
  }, 
  "openssl-1.0.2l-0": {
    "md5": "f821d9e9078c7f56becd5e22646110ca", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/openssl-1.0.2l-0.tar.bz2"
  }, 
  "packaging-16.8-py36_0": {
    "md5": "b0d9202f7a0296419c963508a63c2f16", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/packaging-16.8-py36_0.tar.bz2"
  }, 
  "pandas-0.20.1-np112py36_0": {
    "md5": "f0a1b146b92b2f8e8e499d65bf200599", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pandas-0.20.1-np112py36_0.tar.bz2"
  }, 
  "pandocfilters-1.4.1-py36_0": {
    "md5": "77bce8c2cbb1fe7b91821d8d5e5927bb", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pandocfilters-1.4.1-py36_0.tar.bz2"
  }, 
  "partd-0.3.8-py36_0": {
    "md5": "393162e74e5bfdb5d724c7a83e98686b", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/partd-0.3.8-py36_0.tar.bz2"
  }, 
  "path.py-10.3.1-py36_0": {
    "md5": "5ff32ba40aa35b3d81c38cb99b67f714", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/path.py-10.3.1-py36_0.tar.bz2"
  }, 
  "pathlib2-2.2.1-py36_0": {
    "md5": "abaf7133e30eabd338f8d00246eddbfb", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pathlib2-2.2.1-py36_0.tar.bz2"
  }, 
  "patsy-0.4.1-py36_0": {
    "md5": "aa8565d0fe1d1a8ad95b4417b67dfdfd", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/patsy-0.4.1-py36_0.tar.bz2"
  }, 
  "pep8-1.7.0-py36_0": {
    "md5": "ff883f5abdabc60e61a7a977fffac6b3", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pep8-1.7.0-py36_0.tar.bz2"
  }, 
  "pexpect-4.2.1-py36_0": {
    "md5": "a7bf151a202cd0ede1b19d84bfc7c4d2", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pexpect-4.2.1-py36_0.tar.bz2"
  }, 
  "pickleshare-0.7.4-py36_0": {
    "md5": "2daded0cc02ed2853a75c61f33d21509", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pickleshare-0.7.4-py36_0.tar.bz2"
  }, 
  "pillow-4.1.1-py36_0": {
    "md5": "2299636008395c5c9d4427250beae0e1", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pillow-4.1.1-py36_0.tar.bz2"
  }, 
  "pip-9.0.1-py36_1": {
    "md5": "fc57004131181a6cc00cd57eae5f910e", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pip-9.0.1-py36_1.tar.bz2"
  }, 
  "ply-3.10-py36_0": {
    "md5": "357f3cddb7b6b4bc3ce5f28758738b66", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/ply-3.10-py36_0.tar.bz2"
  }, 
  "prompt_toolkit-1.0.14-py36_0": {
    "md5": "dce3fe95281140a3d3157094335caa34", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/prompt_toolkit-1.0.14-py36_0.tar.bz2"
  }, 
  "psutil-5.2.2-py36_0": {
    "md5": "a8ae1a8bde9efb9e052c2499bc1796c3", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/psutil-5.2.2-py36_0.tar.bz2"
  }, 
  "ptyprocess-0.5.1-py36_0": {
    "md5": "673c5e3fae4724fd3d23c34ccee49348", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/ptyprocess-0.5.1-py36_0.tar.bz2"
  }, 
  "py-1.4.33-py36_0": {
    "md5": "9574dfa3021e2b142aa326a05a5eec8e", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/py-1.4.33-py36_0.tar.bz2"
  }, 
  "pycosat-0.6.2-py36_0": {
    "md5": "c0b4ed798707774332aa01a450a191e4", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pycosat-0.6.2-py36_0.tar.bz2"
  }, 
  "pycparser-2.17-py36_0": {
    "md5": "611ceb73cab44c6f9bed234bc243ec30", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pycparser-2.17-py36_0.tar.bz2"
  }, 
  "pycrypto-2.6.1-py36_6": {
    "md5": "3f53f108ce38bc9a5892ebafe8c09047", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pycrypto-2.6.1-py36_6.tar.bz2"
  }, 
  "pycurl-7.43.0-py36_2": {
    "md5": "dabb5be6269edc7c493956d4c88ab9b3", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pycurl-7.43.0-py36_2.tar.bz2"
  }, 
  "pyflakes-1.5.0-py36_0": {
    "md5": "1bbe4e8a4e902214f094e999bf26fe05", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pyflakes-1.5.0-py36_0.tar.bz2"
  }, 
  "pygments-2.2.0-py36_0": {
    "md5": "40dd477e69e8e1c8913830271cf8cf5b", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pygments-2.2.0-py36_0.tar.bz2"
  }, 
  "pylint-1.6.4-py36_1": {
    "md5": "e62d0ba85009b4996e1c2898bb4b3198", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pylint-1.6.4-py36_1.tar.bz2"
  }, 
  "pyodbc-4.0.16-py36_0": {
    "md5": "d7c2cede40f0cbd21d264552fbee3c72", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pyodbc-4.0.16-py36_0.tar.bz2"
  }, 
  "pyopenssl-17.0.0-py36_0": {
    "md5": "99e69f2a8394255a5e2d31bde8ebd565", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pyopenssl-17.0.0-py36_0.tar.bz2"
  }, 
  "pyparsing-2.1.4-py36_0": {
    "md5": "8083f97a06e9424a5886c6b71b302678", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pyparsing-2.1.4-py36_0.tar.bz2"
  }, 
  "pyqt-5.6.0-py36_1": {
    "md5": "7e9fcc27d4795860b39c06dda4478494", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pyqt-5.6.0-py36_1.tar.bz2"
  }, 
  "pytables-3.3.0-np112py36_0": {
    "md5": "e6d6e21d5ab8c7c39eca10065062f6e9", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pytables-3.3.0-np112py36_0.tar.bz2"
  }, 
  "pytest-3.0.7-py36_0": {
    "md5": "c3a717ed69b9eabdcf1c567277673ac7", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pytest-3.0.7-py36_0.tar.bz2"
  }, 
  "python-3.6.1-2": {
    "md5": "df11ede45634e212b66f0d90da522b94", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/python-3.6.1-2.tar.bz2"
  }, 
  "python-dateutil-2.6.0-py36_0": {
    "md5": "de10206457e415678ef1d87737e7fa0d", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/python-dateutil-2.6.0-py36_0.tar.bz2"
  }, 
  "python.app-1.2-py36_4": {
    "md5": "897dbfc6922479f3db3c51bc3a3aac07", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/python.app-1.2-py36_4.tar.bz2"
  }, 
  "pytz-2017.2-py36_0": {
    "md5": "a40869a80c64b0a5ea807f8f3a1a4595", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pytz-2017.2-py36_0.tar.bz2"
  }, 
  "pywavelets-0.5.2-np112py36_0": {
    "md5": "4a27aa9592d10bf8b818915385c5cee0", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pywavelets-0.5.2-np112py36_0.tar.bz2"
  }, 
  "pyyaml-3.12-py36_0": {
    "md5": "c315d54205c0412d97c1bd43852fe5c7", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pyyaml-3.12-py36_0.tar.bz2"
  }, 
  "pyzmq-16.0.2-py36_0": {
    "md5": "7ccea0d30b8f66c5baa1bacf1b3b2f8f", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/pyzmq-16.0.2-py36_0.tar.bz2"
  }, 
  "qt-5.6.2-2": {
    "md5": "74b0c33e0629a62e7b0f7ed528594285", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/qt-5.6.2-2.tar.bz2"
  }, 
  "qtawesome-0.4.4-py36_0": {
    "md5": "8904f2eeb06fbc2b4727cddcce394949", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/qtawesome-0.4.4-py36_0.tar.bz2"
  }, 
  "qtconsole-4.3.0-py36_0": {
    "md5": "445739e6cf5881ad5947b32e146b1f53", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/qtconsole-4.3.0-py36_0.tar.bz2"
  }, 
  "qtpy-1.2.1-py36_0": {
    "md5": "e5b6ad18669a2bff67d12660a7dd232d", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/qtpy-1.2.1-py36_0.tar.bz2"
  }, 
  "readline-6.2-2": {
    "md5": "0801e644bd0c1cd7f0923b56c52eb7f7", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/readline-6.2-2.tar.bz2"
  }, 
  "requests-2.14.2-py36_0": {
    "md5": "b3039c3e1cf6f5f8ff14d0e204266d55", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/requests-2.14.2-py36_0.tar.bz2"
  }, 
  "rope-0.9.4-py36_1": {
    "md5": "cdf91e8b64f16979e1dc642a5e6da192", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/rope-0.9.4-py36_1.tar.bz2"
  }, 
  "ruamel_yaml-0.11.14-py36_1": {
    "md5": "1ff3815ce6ca1fe88923c3341f892343", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/ruamel_yaml-0.11.14-py36_1.tar.bz2"
  }, 
  "scikit-image-0.13.0-np112py36_0": {
    "md5": "ac42d1a4595b4ea0c11990d8fee376b4", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/scikit-image-0.13.0-np112py36_0.tar.bz2"
  }, 
  "scikit-learn-0.18.1-np112py36_1": {
    "md5": "a089d777db74076c54c568df323fbb3d", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/scikit-learn-0.18.1-np112py36_1.tar.bz2"
  }, 
  "scipy-0.19.0-np112py36_0": {
    "md5": "1e131ffb6a89c525ca645e6726222f9b", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/scipy-0.19.0-np112py36_0.tar.bz2"
  }, 
  "seaborn-0.7.1-py36_0": {
    "md5": "4f78d8e577d99d1735b1e23168290acd", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/seaborn-0.7.1-py36_0.tar.bz2"
  }, 
  "setuptools-27.2.0-py36_0": {
    "md5": "33a5ca1ffb4a6ea4a4457f7e649bf37f", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/setuptools-27.2.0-py36_0.tar.bz2"
  }, 
  "simplegeneric-0.8.1-py36_1": {
    "md5": "8b3e390a7c81e7768d633ca405b002e8", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/simplegeneric-0.8.1-py36_1.tar.bz2"
  }, 
  "singledispatch-3.4.0.3-py36_0": {
    "md5": "914077f3b0b7bce77d2cfc83249a830e", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/singledispatch-3.4.0.3-py36_0.tar.bz2"
  }, 
  "sip-4.18-py36_0": {
    "md5": "3ea827d6e04e42d74a148210c4997946", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/sip-4.18-py36_0.tar.bz2"
  }, 
  "six-1.10.0-py36_0": {
    "md5": "be4b72c0d36adcd7dc2d79edeec639d2", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/six-1.10.0-py36_0.tar.bz2"
  }, 
  "snowballstemmer-1.2.1-py36_0": {
    "md5": "3ec13243aa03ee91538e9c4549be9ffa", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/snowballstemmer-1.2.1-py36_0.tar.bz2"
  }, 
  "sortedcollections-0.5.3-py36_0": {
    "md5": "2e05b2573a978c912964c25d01db111f", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/sortedcollections-0.5.3-py36_0.tar.bz2"
  }, 
  "sortedcontainers-1.5.7-py36_0": {
    "md5": "b100ed07d0eab19b515730a749c254ab", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/sortedcontainers-1.5.7-py36_0.tar.bz2"
  }, 
  "sphinx-1.5.6-py36_0": {
    "md5": "af8bc40992b74df94c7521f73ee36af8", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/sphinx-1.5.6-py36_0.tar.bz2"
  }, 
  "spyder-3.1.4-py36_0": {
    "md5": "d95d6278ad92142812415e84018eb0e6", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/spyder-3.1.4-py36_0.tar.bz2"
  }, 
  "sqlalchemy-1.1.9-py36_0": {
    "md5": "5c5168ab69a08317a9ff81ef50fcf919", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/sqlalchemy-1.1.9-py36_0.tar.bz2"
  }, 
  "sqlite-3.13.0-0": {
    "md5": "dacf9558b650e37c4ec9003fe7f6b405", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/sqlite-3.13.0-0.tar.bz2"
  }, 
  "statsmodels-0.8.0-np112py36_0": {
    "md5": "5d9387635c6e5c6a00f2b7466116b35d", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/statsmodels-0.8.0-np112py36_0.tar.bz2"
  }, 
  "sympy-1.0-py36_0": {
    "md5": "e5d679a577f7998b503f88a9de42394e", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/sympy-1.0-py36_0.tar.bz2"
  }, 
  "tblib-1.3.2-py36_0": {
    "md5": "bc155399236659c7680303e3b179eb19", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/tblib-1.3.2-py36_0.tar.bz2"
  }, 
  "terminado-0.6-py36_0": {
    "md5": "28ccd3e216ade3d95a9d2846d07aa333", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/terminado-0.6-py36_0.tar.bz2"
  }, 
  "testpath-0.3-py36_0": {
    "md5": "d0145e48ea126e2bfeab8d8323d40170", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/testpath-0.3-py36_0.tar.bz2"
  }, 
  "tk-8.5.18-0": {
    "md5": "6de7b2d4c4c9cc0f60150da541c0d843", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/tk-8.5.18-0.tar.bz2"
  }, 
  "toolz-0.8.2-py36_0": {
    "md5": "5ed42abaf08065a91b444d4d34b83633", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/toolz-0.8.2-py36_0.tar.bz2"
  }, 
  "tornado-4.5.1-py36_0": {
    "md5": "786c572af6a773b038312565879fc3d1", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/tornado-4.5.1-py36_0.tar.bz2"
  }, 
  "traitlets-4.3.2-py36_0": {
    "md5": "03cf7f90ab535af6047c37e9d8027f1d", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/traitlets-4.3.2-py36_0.tar.bz2"
  }, 
  "unicodecsv-0.14.1-py36_0": {
    "md5": "ad4be21e055d76713ed0931678a45d5d", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/unicodecsv-0.14.1-py36_0.tar.bz2"
  }, 
  "unixodbc-2.3.4-0": {
    "md5": "3e347e915a8a60db20c0b64b81c78d01", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/unixodbc-2.3.4-0.tar.bz2"
  }, 
  "wcwidth-0.1.7-py36_0": {
    "md5": "159f4f79e7a9f613dd0c2f526f5f2483", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/wcwidth-0.1.7-py36_0.tar.bz2"
  }, 
  "werkzeug-0.12.2-py36_0": {
    "md5": "5c6d2de3cb37e547a362d82f6607d05b", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/werkzeug-0.12.2-py36_0.tar.bz2"
  }, 
  "wheel-0.29.0-py36_0": {
    "md5": "c7e1bd872a1cd5f651addec7f17c711b", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/wheel-0.29.0-py36_0.tar.bz2"
  }, 
  "widgetsnbextension-2.0.0-py36_0": {
    "md5": "8ea0c23818580ee72d1d568ba1f80982", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/widgetsnbextension-2.0.0-py36_0.tar.bz2"
  }, 
  "wrapt-1.10.10-py36_0": {
    "md5": "923d8a0ede31b17b232f032523da68f3", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/wrapt-1.10.10-py36_0.tar.bz2"
  }, 
  "xlrd-1.0.0-py36_0": {
    "md5": "7aabdebad9c1813c2e728a839f5e9ac1", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/xlrd-1.0.0-py36_0.tar.bz2"
  }, 
  "xlsxwriter-0.9.6-py36_0": {
    "md5": "0f5546d6aa444117a8e5b3a8ac7d6639", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/xlsxwriter-0.9.6-py36_0.tar.bz2"
  }, 
  "xlwings-0.10.4-py36_0": {
    "md5": "b3fccca4a546277508d4ef98c4f94ad0", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/xlwings-0.10.4-py36_0.tar.bz2"
  }, 
  "xlwt-1.2.0-py36_0": {
    "md5": "50da46e05ba779b93eaf2f74941edc66", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/xlwt-1.2.0-py36_0.tar.bz2"
  }, 
  "xz-5.2.2-1": {
    "md5": "c8d5d3f406b5309e575c6848091f2fd2", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/xz-5.2.2-1.tar.bz2"
  }, 
  "yaml-0.1.6-0": {
    "md5": "7b1c018bf975c88fbe9df6292bf370b1", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/yaml-0.1.6-0.tar.bz2"
  }, 
  "zict-0.1.2-py36_0": {
    "md5": "c84fdd71022cd1a294c16fcef3f75d50", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/zict-0.1.2-py36_0.tar.bz2"
  }, 
  "zlib-1.2.8-3": {
    "md5": "49b15627e7048317806615d519a5b581", 
    "url": "https://repo.continuum.io/pkgs/free/osx-64/zlib-1.2.8-3.tar.bz2"
  }
}
C_ENVS = {
  "root": [
    "python-3.6.1-2", 
    "_license-1.1-py36_1", 
    "alabaster-0.7.10-py36_0", 
    "anaconda-client-1.6.3-py36_0", 
    "anaconda-navigator-1.6.2-py36_0", 
    "anaconda-project-0.6.0-py36_0", 
    "appnope-0.1.0-py36_0", 
    "appscript-1.0.1-py36_0", 
    "asn1crypto-0.22.0-py36_0", 
    "astroid-1.4.9-py36_0", 
    "astropy-1.3.2-np112py36_0", 
    "babel-2.4.0-py36_0", 
    "backports-1.0-py36_0", 
    "beautifulsoup4-4.6.0-py36_0", 
    "bitarray-0.8.1-py36_0", 
    "blaze-0.10.1-py36_0", 
    "bleach-1.5.0-py36_0", 
    "bokeh-0.12.5-py36_1", 
    "boto-2.46.1-py36_0", 
    "bottleneck-1.2.1-np112py36_0", 
    "cffi-1.10.0-py36_0", 
    "chardet-3.0.3-py36_0", 
    "click-6.7-py36_0", 
    "cloudpickle-0.2.2-py36_0", 
    "clyent-1.2.2-py36_0", 
    "colorama-0.3.9-py36_0", 
    "contextlib2-0.5.5-py36_0", 
    "cryptography-1.8.1-py36_0", 
    "curl-7.52.1-0", 
    "cycler-0.10.0-py36_0", 
    "cython-0.25.2-py36_0", 
    "cytoolz-0.8.2-py36_0", 
    "dask-0.14.3-py36_1", 
    "datashape-0.5.4-py36_0", 
    "decorator-4.0.11-py36_0", 
    "distributed-1.16.3-py36_0", 
    "docutils-0.13.1-py36_0", 
    "entrypoints-0.2.2-py36_1", 
    "et_xmlfile-1.0.1-py36_0", 
    "fastcache-1.0.2-py36_1", 
    "flask-0.12.2-py36_0", 
    "flask-cors-3.0.2-py36_0", 
    "freetype-2.5.5-2", 
    "get_terminal_size-1.0.0-py36_0", 
    "gevent-1.2.1-py36_0", 
    "greenlet-0.4.12-py36_0", 
    "h5py-2.7.0-np112py36_0", 
    "hdf5-1.8.17-1", 
    "heapdict-1.0.0-py36_1", 
    "html5lib-0.999-py36_0", 
    "icu-54.1-0", 
    "idna-2.5-py36_0", 
    "imagesize-0.7.1-py36_0", 
    "ipykernel-4.6.1-py36_0", 
    "ipython-5.3.0-py36_0", 
    "ipython_genutils-0.2.0-py36_0", 
    "ipywidgets-6.0.0-py36_0", 
    "isort-4.2.5-py36_0", 
    "itsdangerous-0.24-py36_0", 
    "jbig-2.1-0", 
    "jdcal-1.3-py36_0", 
    "jedi-0.10.2-py36_2", 
    "jinja2-2.9.6-py36_0", 
    "jpeg-9b-0", 
    "jsonschema-2.6.0-py36_0", 
    "jupyter-1.0.0-py36_3", 
    "jupyter_client-5.0.1-py36_0", 
    "jupyter_console-5.1.0-py36_0", 
    "jupyter_core-4.3.0-py36_0", 
    "lazy-object-proxy-1.2.2-py36_0", 
    "libiconv-1.14-0", 
    "libpng-1.6.27-0", 
    "libtiff-4.0.6-3", 
    "libxml2-2.9.4-0", 
    "libxslt-1.1.29-0", 
    "llvmlite-0.18.0-py36_0", 
    "locket-0.2.0-py36_1", 
    "lxml-3.7.3-py36_0", 
    "markupsafe-0.23-py36_2", 
    "matplotlib-2.0.2-np112py36_0", 
    "mistune-0.7.4-py36_0", 
    "mkl-2017.0.1-0", 
    "mkl-service-1.1.2-py36_3", 
    "mpmath-0.19-py36_1", 
    "msgpack-python-0.4.8-py36_0", 
    "multipledispatch-0.4.9-py36_0", 
    "navigator-updater-0.1.0-py36_0", 
    "nbconvert-5.1.1-py36_0", 
    "nbformat-4.3.0-py36_0", 
    "networkx-1.11-py36_0", 
    "nltk-3.2.3-py36_0", 
    "nose-1.3.7-py36_1", 
    "notebook-5.0.0-py36_0", 
    "numba-0.33.0-np112py36_0", 
    "numexpr-2.6.2-np112py36_0", 
    "numpy-1.12.1-py36_0", 
    "numpydoc-0.6.0-py36_0", 
    "odo-0.5.0-py36_1", 
    "olefile-0.44-py36_0", 
    "openpyxl-2.4.7-py36_0", 
    "openssl-1.0.2l-0", 
    "packaging-16.8-py36_0", 
    "pandas-0.20.1-np112py36_0", 
    "pandocfilters-1.4.1-py36_0", 
    "partd-0.3.8-py36_0", 
    "path.py-10.3.1-py36_0", 
    "pathlib2-2.2.1-py36_0", 
    "patsy-0.4.1-py36_0", 
    "pep8-1.7.0-py36_0", 
    "pexpect-4.2.1-py36_0", 
    "pickleshare-0.7.4-py36_0", 
    "pillow-4.1.1-py36_0", 
    "pip-9.0.1-py36_1", 
    "ply-3.10-py36_0", 
    "prompt_toolkit-1.0.14-py36_0", 
    "psutil-5.2.2-py36_0", 
    "ptyprocess-0.5.1-py36_0", 
    "py-1.4.33-py36_0", 
    "pycosat-0.6.2-py36_0", 
    "pycparser-2.17-py36_0", 
    "pycrypto-2.6.1-py36_6", 
    "pycurl-7.43.0-py36_2", 
    "pyflakes-1.5.0-py36_0", 
    "pygments-2.2.0-py36_0", 
    "pylint-1.6.4-py36_1", 
    "pyodbc-4.0.16-py36_0", 
    "pyopenssl-17.0.0-py36_0", 
    "pyparsing-2.1.4-py36_0", 
    "pyqt-5.6.0-py36_1", 
    "pytables-3.3.0-np112py36_0", 
    "pytest-3.0.7-py36_0", 
    "python-dateutil-2.6.0-py36_0", 
    "python.app-1.2-py36_4", 
    "pytz-2017.2-py36_0", 
    "pywavelets-0.5.2-np112py36_0", 
    "pyyaml-3.12-py36_0", 
    "pyzmq-16.0.2-py36_0", 
    "qt-5.6.2-2", 
    "qtawesome-0.4.4-py36_0", 
    "qtconsole-4.3.0-py36_0", 
    "qtpy-1.2.1-py36_0", 
    "readline-6.2-2", 
    "requests-2.14.2-py36_0", 
    "rope-0.9.4-py36_1", 
    "ruamel_yaml-0.11.14-py36_1", 
    "scikit-image-0.13.0-np112py36_0", 
    "scikit-learn-0.18.1-np112py36_1", 
    "scipy-0.19.0-np112py36_0", 
    "seaborn-0.7.1-py36_0", 
    "setuptools-27.2.0-py36_0", 
    "simplegeneric-0.8.1-py36_1", 
    "singledispatch-3.4.0.3-py36_0", 
    "sip-4.18-py36_0", 
    "six-1.10.0-py36_0", 
    "snowballstemmer-1.2.1-py36_0", 
    "sortedcollections-0.5.3-py36_0", 
    "sortedcontainers-1.5.7-py36_0", 
    "sphinx-1.5.6-py36_0", 
    "spyder-3.1.4-py36_0", 
    "sqlalchemy-1.1.9-py36_0", 
    "sqlite-3.13.0-0", 
    "statsmodels-0.8.0-np112py36_0", 
    "sympy-1.0-py36_0", 
    "tblib-1.3.2-py36_0", 
    "terminado-0.6-py36_0", 
    "testpath-0.3-py36_0", 
    "tk-8.5.18-0", 
    "toolz-0.8.2-py36_0", 
    "tornado-4.5.1-py36_0", 
    "traitlets-4.3.2-py36_0", 
    "unicodecsv-0.14.1-py36_0", 
    "unixodbc-2.3.4-0", 
    "wcwidth-0.1.7-py36_0", 
    "werkzeug-0.12.2-py36_0", 
    "wheel-0.29.0-py36_0", 
    "widgetsnbextension-2.0.0-py36_0", 
    "wrapt-1.10.10-py36_0", 
    "xlrd-1.0.0-py36_0", 
    "xlsxwriter-0.9.6-py36_0", 
    "xlwings-0.10.4-py36_0", 
    "xlwt-1.2.0-py36_0", 
    "xz-5.2.2-1", 
    "yaml-0.1.6-0", 
    "zict-0.1.2-py36_0", 
    "zlib-1.2.8-3", 
    "anaconda-4.4.0-np112py36_0", 
    "conda-4.3.21-py36_0", 
    "conda-env-2.6.0-0"
  ]
}



def _link(src, dst, linktype=LINK_HARD):
    if on_win:
        raise NotImplementedError

    if linktype == LINK_HARD:
        os.link(src, dst)
    elif linktype == LINK_COPY:
        # copy relative symlinks as symlinks
        if islink(src) and not os.readlink(src).startswith('/'):
            os.symlink(os.readlink(src), dst)
        else:
            shutil.copy2(src, dst)
    else:
        raise Exception("Did not expect linktype=%r" % linktype)


def rm_rf(path):
    """
    try to delete path, but never fail
    """
    try:
        if islink(path) or isfile(path):
            # Note that we have to check if the destination is a link because
            # exists('/path/to/dead-link') will return False, although
            # islink('/path/to/dead-link') is True.
            os.unlink(path)
        elif isdir(path):
            shutil.rmtree(path)
    except (OSError, IOError):
        pass


def yield_lines(path):
    for line in open(path):
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        yield line


prefix_placeholder = ('/opt/anaconda1anaconda2'
                      # this is intentionally split into parts,
                      # such that running this program on itself
                      # will leave it unchanged
                      'anaconda3')

def read_has_prefix(path):
    """
    reads `has_prefix` file and return dict mapping filenames to
    tuples(placeholder, mode)
    """
    import shlex

    res = {}
    try:
        for line in yield_lines(path):
            try:
                placeholder, mode, f = [x.strip('"\'') for x in
                                        shlex.split(line, posix=False)]
                res[f] = (placeholder, mode)
            except ValueError:
                res[line] = (prefix_placeholder, 'text')
    except IOError:
        pass
    return res


def exp_backoff_fn(fn, *args):
    """
    for retrying file operations that fail on Windows due to virus scanners
    """
    if not on_win:
        return fn(*args)

    import time
    import errno
    max_tries = 6  # max total time = 6.4 sec
    for n in range(max_tries):
        try:
            result = fn(*args)
        except (OSError, IOError) as e:
            if e.errno in (errno.EPERM, errno.EACCES):
                if n == max_tries - 1:
                    raise Exception("max_tries=%d reached" % max_tries)
                time.sleep(0.1 * (2 ** n))
            else:
                raise e
        else:
            return result


class PaddingError(Exception):
    pass


def binary_replace(data, a, b):
    """
    Perform a binary replacement of `data`, where the placeholder `a` is
    replaced with `b` and the remaining string is padded with null characters.
    All input arguments are expected to be bytes objects.
    """
    def replace(match):
        occurances = match.group().count(a)
        padding = (len(a) - len(b)) * occurances
        if padding < 0:
            raise PaddingError(a, b, padding)
        return match.group().replace(a, b) + b'\0' * padding

    pat = re.compile(re.escape(a) + b'([^\0]*?)\0')
    res = pat.sub(replace, data)
    assert len(res) == len(data)
    return res


def update_prefix(path, new_prefix, placeholder, mode):
    if on_win:
        # force all prefix replacements to forward slashes to simplify need
        # to escape backslashes - replace with unix-style path separators
        new_prefix = new_prefix.replace('\\', '/')

    path = os.path.realpath(path)
    with open(path, 'rb') as fi:
        data = fi.read()
    if mode == 'text':
        new_data = data.replace(placeholder.encode('utf-8'),
                                new_prefix.encode('utf-8'))
    elif mode == 'binary':
        if on_win:
            # anaconda-verify will not allow binary placeholder on Windows.
            # However, since some packages might be created wrong (and a
            # binary placeholder would break the package, we just skip here.
            return
        new_data = binary_replace(data, placeholder.encode('utf-8'),
                                  new_prefix.encode('utf-8'))
    else:
        sys.exit("Invalid mode:" % mode)

    if new_data == data:
        return
    st = os.lstat(path)
    # unlink in case the file is memory mapped
    exp_backoff_fn(os.unlink, path)
    with open(path, 'wb') as fo:
        fo.write(new_data)
    os.chmod(path, stat.S_IMODE(st.st_mode))


def name_dist(dist):
    return dist.rsplit('-', 2)[0]


def create_meta(prefix, dist, info_dir, extra_info):
    """
    Create the conda metadata, in a given prefix, for a given package.
    """
    # read info/index.json first
    with open(join(info_dir, 'index.json')) as fi:
        meta = json.load(fi)
    # add extra info
    meta.update(extra_info)
    # write into <prefix>/conda-meta/<dist>.json
    meta_dir = join(prefix, 'conda-meta')
    if not isdir(meta_dir):
        os.makedirs(meta_dir)
        with open(join(meta_dir, 'history'), 'w') as fo:
            fo.write('')
    with open(join(meta_dir, dist + '.json'), 'w') as fo:
        json.dump(meta, fo, indent=2, sort_keys=True)


def run_script(prefix, dist, action='post-link'):
    """
    call the post-link (or pre-unlink) script, and return True on success,
    False on failure
    """
    path = join(prefix, 'Scripts' if on_win else 'bin', '.%s-%s.%s' % (
            name_dist(dist),
            action,
            'bat' if on_win else 'sh'))
    if not isfile(path):
        return True
    if SKIP_SCRIPTS:
        print("WARNING: skipping %s script by user request" % action)
        return True

    if on_win:
        try:
            args = [os.environ['COMSPEC'], '/c', path]
        except KeyError:
            return False
    else:
        shell_path = '/bin/sh' if 'bsd' in sys.platform else '/bin/bash'
        args = [shell_path, path]

    env = os.environ
    env['PREFIX'] = prefix

    import subprocess
    try:
        subprocess.check_call(args, env=env)
    except subprocess.CalledProcessError:
        return False
    return True


url_pat = re.compile(r'''
(?P<baseurl>\S+/)                 # base URL
(?P<fn>[^\s#/]+)                  # filename
([#](?P<md5>[0-9a-f]{32}))?       # optional MD5
$                                 # EOL
''', re.VERBOSE)

def read_urls(dist):
    try:
        data = open(join(PKGS_DIR, 'urls')).read()
        for line in data.split()[::-1]:
            m = url_pat.match(line)
            if m is None:
                continue
            if m.group('fn') == '%s.tar.bz2' % dist:
                return {'url': m.group('baseurl') + m.group('fn'),
                        'md5': m.group('md5')}
    except IOError:
        pass
    return {}


def read_no_link(info_dir):
    res = set()
    for fn in 'no_link', 'no_softlink':
        try:
            res.update(set(yield_lines(join(info_dir, fn))))
        except IOError:
            pass
    return res


def linked(prefix):
    """
    Return the (set of canonical names) of linked packages in prefix.
    """
    meta_dir = join(prefix, 'conda-meta')
    if not isdir(meta_dir):
        return set()
    return set(fn[:-5] for fn in os.listdir(meta_dir) if fn.endswith('.json'))


def link(prefix, dist, linktype=LINK_HARD):
    '''
    Link a package in a specified prefix.  We assume that the packacge has
    been extra_info in either
      - <PKGS_DIR>/dist
      - <ROOT_PREFIX>/ (when the linktype is None)
    '''
    if linktype:
        source_dir = join(PKGS_DIR, dist)
        info_dir = join(source_dir, 'info')
        no_link = read_no_link(info_dir)
    else:
        info_dir = join(prefix, 'info')

    files = list(yield_lines(join(info_dir, 'files')))
    has_prefix_files = read_has_prefix(join(info_dir, 'has_prefix'))

    if linktype:
        for f in files:
            src = join(source_dir, f)
            dst = join(prefix, f)
            dst_dir = dirname(dst)
            if not isdir(dst_dir):
                os.makedirs(dst_dir)
            if exists(dst):
                if FORCE:
                    rm_rf(dst)
                else:
                    raise Exception("dst exists: %r" % dst)
            lt = linktype
            if f in has_prefix_files or f in no_link or islink(src):
                lt = LINK_COPY
            try:
                _link(src, dst, lt)
            except OSError:
                pass

    for f in sorted(has_prefix_files):
        placeholder, mode = has_prefix_files[f]
        try:
            update_prefix(join(prefix, f), prefix, placeholder, mode)
        except PaddingError:
            sys.exit("ERROR: placeholder '%s' too short in: %s\n" %
                     (placeholder, dist))

    if not run_script(prefix, dist, 'post-link'):
        sys.exit("Error: post-link failed for: %s" % dist)

    meta = {
        'files': files,
        'link': ({'source': source_dir,
                  'type': link_name_map.get(linktype)}
                 if linktype else None),
    }
    try:    # add URL and MD5
        meta.update(IDISTS[dist])
    except KeyError:
        meta.update(read_urls(dist))
    meta['installed_by'] = 'Anaconda3-4.4.0-MacOSX-x86_64'
    create_meta(prefix, dist, info_dir, meta)


def duplicates_to_remove(linked_dists, keep_dists):
    """
    Returns the (sorted) list of distributions to be removed, such that
    only one distribution (for each name) remains.  `keep_dists` is an
    interable of distributions (which are not allowed to be removed).
    """
    from collections import defaultdict

    keep_dists = set(keep_dists)
    ldists = defaultdict(set) # map names to set of distributions
    for dist in linked_dists:
        name = name_dist(dist)
        ldists[name].add(dist)

    res = set()
    for dists in ldists.values():
        # `dists` is the group of packages with the same name
        if len(dists) == 1:
            # if there is only one package, nothing has to be removed
            continue
        if dists & keep_dists:
            # if the group has packages which are have to be kept, we just
            # take the set of packages which are in group but not in the
            # ones which have to be kept
            res.update(dists - keep_dists)
        else:
            # otherwise, we take lowest (n-1) (sorted) packages
            res.update(sorted(dists)[:-1])
    return sorted(res)


def remove_duplicates():
    idists = []
    for line in open(join(PKGS_DIR, 'urls')):
        m = url_pat.match(line)
        if m:
            fn = m.group('fn')
            idists.append(fn[:-8])

    keep_files = set()
    for dist in idists:
        with open(join(ROOT_PREFIX, 'conda-meta', dist + '.json')) as fi:
            meta = json.load(fi)
        keep_files.update(meta['files'])

    for dist in duplicates_to_remove(linked(ROOT_PREFIX), idists):
        print("unlinking: %s" % dist)
        meta_path = join(ROOT_PREFIX, 'conda-meta', dist + '.json')
        with open(meta_path) as fi:
            meta = json.load(fi)
        for f in meta['files']:
            if f not in keep_files:
                rm_rf(join(ROOT_PREFIX, f))
        rm_rf(meta_path)


def link_idists():
    src = join(PKGS_DIR, 'urls')
    dst = join(ROOT_PREFIX, '.hard-link')
    assert isfile(src), src
    assert not isfile(dst), dst
    try:
        _link(src, dst, LINK_HARD)
        linktype = LINK_HARD
    except OSError:
        linktype = LINK_COPY
    finally:
        rm_rf(dst)

    for env_name in sorted(C_ENVS):
        dists = C_ENVS[env_name]
        assert isinstance(dists, list)
        if len(dists) == 0:
            continue

        prefix = prefix_env(env_name)
        for dist in dists:
            assert dist in IDISTS
            link(prefix, dist, linktype)

        for dist in duplicates_to_remove(linked(prefix), dists):
            meta_path = join(prefix, 'conda-meta', dist + '.json')
            print("WARNING: unlinking: %s" % meta_path)
            try:
                os.rename(meta_path, meta_path + '.bak')
            except OSError:
                rm_rf(meta_path)


def prefix_env(env_name):
    if env_name == 'root':
        return ROOT_PREFIX
    else:
        return join(ROOT_PREFIX, 'envs', env_name)


def post_extract(env_name='root'):
    """
    assuming that the package is extracted in the environment `env_name`,
    this function does everything link() does except the actual linking,
    i.e. update prefix files, run 'post-link', creates the conda metadata,
    and removed the info/ directory afterwards.
    """
    prefix = prefix_env(env_name)
    info_dir = join(prefix, 'info')
    with open(join(info_dir, 'index.json')) as fi:
        meta = json.load(fi)
    dist = '%(name)s-%(version)s-%(build)s' % meta
    if FORCE:
        run_script(prefix, dist, 'pre-unlink')
    link(prefix, dist, linktype=None)
    shutil.rmtree(info_dir)


def main():
    global ROOT_PREFIX, PKGS_DIR

    p = OptionParser(description="conda link tool used by installers")

    p.add_option('--root-prefix',
                 action="store",
                 default=abspath(join(__file__, '..', '..')),
                 help="root prefix (defaults to %default)")

    p.add_option('--post',
                 action="store",
                 help="perform post extract (on a single package), "
                      "in environment NAME",
                 metavar='NAME')

    opts, args = p.parse_args()
    if args:
        p.error('no arguments expected')

    ROOT_PREFIX = opts.root_prefix.replace('//', '/')
    PKGS_DIR = join(ROOT_PREFIX, 'pkgs')

    if opts.post:
        post_extract(opts.post)
        return

    if FORCE:
        print("using -f (force) option")

    link_idists()


def main2():
    global SKIP_SCRIPTS

    p = OptionParser(description="conda post extract tool used by installers")

    p.add_option('--skip-scripts',
                 action="store_true",
                 help="skip running pre/post-link scripts")

    p.add_option('--rm-dup',
                 action="store_true",
                 help="remove duplicates")

    opts, args = p.parse_args()
    if args:
        p.error('no arguments expected')

    if opts.skip_scripts:
        SKIP_SCRIPTS = True

    if opts.rm_dup:
        remove_duplicates()
        return

    post_extract()


def warn_on_special_chrs():
    if on_win:
        return
    for c in SPECIAL_ASCII:
        if c in ROOT_PREFIX:
            print("WARNING: found '%s' in install prefix." % c)


if __name__ == '__main__':
    if IDISTS:
        main()
        warn_on_special_chrs()
    else: # common usecase
        main2()
