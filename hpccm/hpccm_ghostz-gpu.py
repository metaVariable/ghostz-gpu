"""
HPC Base image

Contents:
  CUDA version 10.0
  Boost version 3.3.8
  GNU compilers (upstream)
"""
# pylint: disable=invalid-name, undefined-variable, used-before-assignment
devel_image = 'nvidia/cuda:10.0-devel-ubuntu18.04'
runtime_image = 'nvidia/cuda:10.0-runtime-ubuntu18.04'

######
# Devel stage
######

Stage0.name = 'devel'

Stage0 += comment(__doc__, reformat=False)

Stage0 += baseimage(image=devel_image, _as='devel')

# GNU compilers
compiler = gnu()
Stage0 += compiler

# Boost
Stage0 += boost(
    version='1.68.0', 
    prefix='/usr/local/boost',
    bootstrap_opts=[]
)

# GHOSTZ-GPU
Stage0 += copy(src='.', dest='/workspace')
Stage0 += shell(commands=['cd /workspace', 'make -j$(nproc) BOOST_PATH=\"/usr/local/boost\"'])

######
# Runtime image
######

Stage1.name = 'runtime'
Stage1 += baseimage(image=runtime_image, _as=Stage1.name)
Stage1 += Stage0.runtime(_from='devel')

# copy MEGADOCK binary from devel
Stage1 += copy(_from=Stage0.name, src='/workspace/ghostz-gpu', dest='/workspace/ghostz-gpu')

Stage1 += environment(variables={'PATH': '$PATH:/workspace'})

Stage1 += workdir(directory='/workspace')