# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
# Modified by the QuantEcon Development Team.
# Further modified by Jeff Eldredge

# This contains the minimal set of assets needed to run the lectures and develop in Julia/Python.
# If you need more, consider pulling QuantEcon/all-notebook.

# Setup instructions
# base-notebook is the smallest one
FROM jupyter/base-notebook:59b402ce701d
LABEL maintainer="Jeff Eldredge <jdeldre@ucla.edu>"
USER root

# Linux setup
RUN apt-get update && apt-get install -yq --no-install-recommends \
    build-essential \
    git \
    pandoc \
    libsm6 \
    libxext-dev \
    libxrender1 \
    inkscape \
    sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Julia setup
# JULIA_PKGDIR will soon be deprecated; keep an eye on the jupyter upstream to see the new standard
ENV JULIA_PKGDIR=/opt/julia
ENV JULIA_VERSION=1.2.0

# sudo setup
ADD /sudoers.txt /etc/sudoers
RUN chmod 440 /etc/sudoers

# Install Julia
USER $NB_USER
RUN mkdir /opt/julia-${JULIA_VERSION} && \
    cd /tmp && \
    wget -q https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
    tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C /opt/julia-${JULIA_VERSION} --strip-components=1 && \
    rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz

RUN sudo ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia

# Show Julia where conda libraries are
USER root
RUN mkdir /etc/julia && \
    echo "push!(Libdl.DL_LOAD_PATH, \"$CONDA_DIR/lib\")" >> /etc/julia/juliarc.jl && \
    # Create JULIA_PKGDIR \
    mkdir $JULIA_PKGDIR && \
    chown $NB_USER $JULIA_PKGDIR && \
    fix-permissions $JULIA_PKGDIR

# PackageCompiler stuff
USER $NB_USER
RUN julia -e "using Pkg; pkg\"add PackageCompiler Plots Conda PyCall PyPlot PotentialFlow\"; using Conda; Conda.add(\"matplotlib\"); Conda.add(\"pyqt\"); using PackageCompiler; compile_incremental(:Plots, :PyPlot, :PotentialFlow, force = true)"
# QELP, QELAP
RUN julia -e "using Pkg; pkg\"add IJulia\"; pkg\"precompile\""

# Jupyter kernelspec stuff
USER root
RUN mv $HOME/.local/share/jupyter/kernels/julia* $CONDA_DIR/share/jupyter/kernels/ && \
    chmod -R go+rx $CONDA_DIR/share/jupyter && \
    rm -rf $HOME/.local && \
    fix-permissions $JULIA_PKGDIR $CONDA_DIR/share/jupyter

# Copy in files
USER $NB_USER
COPY --chown=1000 . ${HOME}
