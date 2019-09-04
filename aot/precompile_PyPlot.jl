function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    precompile(Tuple{typeof(PyPlot.find_backend), PyCall.PyObject})
    precompile(Tuple{getfield(PyPlot, Symbol("##draw#40")), Base.Iterators.Pairs{Union{}, Union{}, Tuple{}, NamedTuple{(), Tuple{}}}, typeof(PyPlot.draw)})
    precompile(Tuple{getfield(PyPlot, Symbol("##figure#7")), Base.Iterators.Pairs{Union{}, Union{}, Tuple{}, NamedTuple{(), Tuple{}}}, typeof(PyPlot.figure)})
    precompile(Tuple{typeof(PyPlot.isdisplayok)})
    precompile(Tuple{getfield(PyPlot, Symbol("##ioff#68")), Base.Iterators.Pairs{Union{}, Union{}, Tuple{}, NamedTuple{(), Tuple{}}}, typeof(PyPlot.ioff)})
    precompile(Tuple{typeof(PyPlot.__init__)})
    precompile(Tuple{typeof(PyPlot.gcf)})
    precompile(Tuple{typeof(PyPlot.init_colormaps)})
    precompile(Tuple{typeof(PyPlot.figure)})
    precompile(Tuple{typeof(PyPlot.ioff)})
end
