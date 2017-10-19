# BookExamples
This module contains notebooks that support the book *Mathematical Modeling of Unsteady Inviscid Flows* by Jeff D. Eldredge

This package requires Julia `0.6-` and above.

To get started, install the PotentialFlow module by typing the following at the julia command prompt:
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

Occasionally, you should run
```julia
julia> Pkg.update()
```
in order to get the most recent versions of the packages.
