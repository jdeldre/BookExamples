module BookExamples

using PotentialFlow

using PyPlot

import PotentialFlow.Utils:@get, MappedVector

import PyCall

export install_examples, plot_streamlines, conformal_grid

const mygreen = [151/255,180/255,118/255];
const mygreen2 = [113/255,161/255,103/255];
const myblue = [74/255,144/255,226/255];

PlotColor = Union{Vector{Float64},String,Symbol}

struct PlotStyle

  bodycolor :: PlotColor
  xicolor   :: PlotColor
  etacolor  :: PlotColor
  markercolor :: PlotColor
  linewidth :: Int64
  pointsize :: Int64

end

function install_examples(dir::String)

  fulldir = joinpath(homedir(),dir)
  if !isdir(fulldir)
      mkdir(fulldir)
  end

  examplesroot = joinpath(Pkg.dir("BookExamples"),"binder/notebooks")
  for (root, dirs, files) in walkdir(examplesroot)
    for file in files
        if contains(file[end-5:end], ".ipynb") && root == examplesroot
            cp(joinpath(root, file),joinpath(fulldir,file)) # path to files
        end
    end
  end

end

function PlotStyle()
  PyCall.PyDict(matplotlib["rcParams"])["font.family"] = "STIXGeneral";
  PyCall.PyDict(matplotlib["rcParams"])["mathtext.fontset"] = "stix";
  PyCall.PyDict(matplotlib["rcParams"])["font.size"] = 10;

  bodycolor = mygreen
  xicolor = mygreen2
  etacolor = myblue
  markercolor = "r"
  linewidth = 1
  pointsize = 3

  PlotStyle(bodycolor,xicolor,etacolor,markercolor,linewidth,pointsize)

end

function conformal_grid(b::Bodies.PowerBody)

  ps = PlotStyle()

  xmaxc = 4.0
  rmax = sqrt(2)*xmaxc

  PyPlot.subplot(121)
  PyPlot.axis("scaled")
  PyPlot.axis([-xmaxc,xmaxc,-xmaxc,xmaxc])
  PyPlot.xticks(ceil(-xmaxc/2)*2:2:floor(xmaxc/2)*2)
  PyPlot.yticks(ceil(-xmaxc/2)*2:2:floor(xmaxc/2)*2)

  PyPlot.subplot(122)
  PyPlot.axis("scaled")
  xmaxp = xmaxc*abs(b.C[1])
  dxp = 0.5*xmaxp
  PyPlot.axis([-xmaxp,xmaxp,-xmaxp,xmaxp])
  PyPlot.xticks(ceil(-xmaxp/dxp)*dxp:dxp:floor(xmaxp/dxp)*dxp)
  PyPlot.yticks(ceil(-xmaxp/dxp)*dxp:dxp:floor(xmaxp/dxp)*dxp)

  nθ = 20
  dθ = 2π/nθ
  θg = 0
  nrg = 100
  rg = linspace(1,rmax,nrg)
  for jθ in 1:nθ
      ζg = collect(rg*exp(im*θg))
      zg = Bodies.powermap(ζg,b.C)

       PyPlot.subplot(121)
       PyPlot.plot(real(ζg),imag(ζg),linewidth=ps.linewidth,color=ps.xicolor)

       PyPlot.subplot(122)
       PyPlot.plot(real(zg),imag(zg),linewidth=ps.linewidth,color=ps.xicolor)

       θg += dθ
   end

   nr = 10
   dr = (rmax-1)/nr
   rg = 1

   nθg = 200
   θg = linspace(0,2π,nθg)
   #if strcmpi(maptype,'sc')
  #     thg = [thg shape.prevangle'];  % Include prevertices
  #     thsort = sort(thg - floor(thg/(2*pi))*2*pi);  % Normalize the range
    #   thg = thsort(abs(diff(thsort))>1e-15);  % Eliminate duplicates
  #     thg = [thg 2*pi];
   #end
   for jr in 1:nr
       ζg = collect(rg*exp.(im*θg));
       zg = Bodies.powermap(ζg,b.C)

       PyPlot.subplot(121)
       PyPlot.plot(real(ζg),imag(ζg),linewidth=ps.linewidth,color=ps.etacolor)

       PyPlot.subplot(122)
       PyPlot.plot(real(zg),imag(zg),linewidth=ps.linewidth,color=ps.etacolor)

       rg += dr
   end

end

function setup_grid(b::Bodies.PowerBody)

  eps = 0.00001;
  len = 1/abs(b.C[1]);
  xcent = 0; ycent = 0;
  xfact = 6; yfact = 6;
  xlen = xfact*len; ylen = yfact*len;
  xmin = xcent - 0.5*xlen; xmax = xcent + min(0.5*xlen,len);
  ymin = ycent - min(0.5*ylen,2*len);
  ymax = ycent + min(0.5*ylen,2*len);

  nth = 400;
  dth = 2π/nth;
  θ = linspace(0,2π,nth+1);
  dr = dth;
  r = [1+eps];
  while maximum(r) < xlen
    push!(r,r[end]+dr)
    dr = r[end]*dth;
  end
  xmin = -maximum(r)/sqrt(2)*abs(b.C[1]); xmax = maximum(r)/sqrt(2)*abs(b.C[1]);
  ymin = -maximum(r)/sqrt(2)*abs(b.C[1]); ymax = maximum(r)/sqrt(2)*abs(b.C[1]);
  ζ = r * exp.(im*θ');
  Z = zero(ζ);
  Z = [Bodies.powermap(ζi,b.C) for ζi in ζ];

  PyPlot.axis("scaled");
  PyPlot.axis([xmin,xmax,ymin,ymax]);
  PyPlot.xticks(ceil(xmin/2)*2:2:floor(xmax/2)*2);
  PyPlot.yticks(ceil(ymin/2)*2:2:floor(ymax/2)*2);

  Z, ζ

end

function set_contour_levels(ψ)

  vmin = minimum(ψ);
  vmax = maximum(ψ);
  vmean = vmax-vmin;
  vfact = 1;
  vmin = vmean+vfact*(vmin-vmean);
  vmax = vmean+vfact*(vmax-vmean);
  v = linspace(vmin,vmax,31);
  if (sign(vmin) != sign(vmax))
    v = v .- v[abs.(v).==minimum(abs.(v))];
  end
  v

end

function plot_streamlines(b::Bodies.PowerBody,m::Bodies.RigidBodyMotion,t)

  ps = PlotStyle()

  Z, ζ = setup_grid(b)

  ψ = zero(ζ);
  ψ = Bodies.streamfunction.(ζ,b,m,t)



  pc = PyPlot.contour(real(Z),imag(Z),ψ,set_contour_levels(ψ),
                      colors="black",linestyles="solid",linewidths=ps.linewidth);
  pf = PyPlot.fill(real(b.zs),imag(b.zs),facecolor=ps.bodycolor);
  PyPlot.plot(real(b.zs),imag(b.zs),color=ps.bodycolor);

  #PyPlot.savefig("/Users/jeff/Desktop/testfig2.eps",format="eps")

end

function plot_streamlines(b::Bodies.PowerBody,src,t)

  ps = PlotStyle()

  Z, ζ = setup_grid(b)

  ψ = [Bodies.streamfunction(ζi,b,src,t) for ζi in ζ]


  pc = PyPlot.contour(real(Z),imag(Z),ψ,set_contour_levels(ψ),
                      colors="black",linestyles="solid",linewidths=ps.linewidth);
  pf = PyPlot.fill(real(b.zs),imag(b.zs),facecolor=ps.bodycolor);
  PyPlot.plot(real(b.zs),imag(b.zs),color=ps.bodycolor);

  z = Elements.conftransform(src,b);
  PyPlot.plot(real.(z),imag.(z),
              marker="o",markerfacecolor=ps.markercolor,markersize=ps.pointsize,
              markeredgecolor=ps.markercolor,linestyle="none");

  #PyPlot.savefig("/Users/jeff/Desktop/testfig2.eps",format="eps")

end

function plot_streamlines(b::Bodies.PowerBody,Winf::Complex128)

  ps = PlotStyle()

  Z, ζ = setup_grid(b)

  ψ = zero(ζ);
  ψ = Bodies.streamfunction.(ζ,b,Winf,0.0)



  pc = PyPlot.contour(real(Z),imag(Z),ψ,set_contour_levels(ψ),
                      colors="black",linestyles="solid",linewidths=ps.linewidth);
  pf = PyPlot.fill(real(b.zs),imag(b.zs),facecolor=ps.bodycolor);
  PyPlot.plot(real(b.zs),imag(b.zs),color=ps.bodycolor);

  #PyPlot.savefig("/Users/jeff/Desktop/testfig2.eps",format="eps")

end

end
