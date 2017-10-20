# BookExamples
This module contains notebooks that support the book *Mathematical Modeling of Unsteady Inviscid Flows* by Jeff D. Eldredge

This package requires Julia `0.6-` and above.

To get started, install the PotentialFlow module by typing the following in an interactive Julia session. (Note that this session could be the Julia REPL or from within an IJulia notebook, such as on JuliaBox.)
```julia
julia> Pkg.clone("https://github.com/jdeldre/PotentialFlow.jl.git")
```
That will take a minute or so as all of the dependencies are installed. Then, type
```julia
julia> Pkg.checkout("PotentialFlow","je/book")
```
Finally,
```julia
julia> Pkg.clone("https://github.com/jdeldre/BookExamples")
```
Now you've installed the necessary modules. The notebooks in the `examples` folder are ready to run.

To install the examples in a local working directory on your system, then first type
```julia
julia> using BookExamples
```
This might take a minute or two to run, since it precompiles all of the modules. Then, type
```julia
julia> install_examples("ExamplesFolder")
```
This command creates a folder called `ExamplesFolder` in your home directory and copies all of the notebooks from the package into this folder. These copied notebooks are the ones you should use. If you've already run this before and wish to refresh the notebooks, you will need to manually delete any existing notebooks in that folder, because the script will not overwrite them. (This prevents accidentally overwriting notebooks that you've been working on and modifying.)

As a general rule, it is a good idea to run
```julia
julia> Pkg.update()
```
in order to get the most recent versions of the packages. You might need to re-run `install_examples` once you've done this to install any changes to the notebooks.
