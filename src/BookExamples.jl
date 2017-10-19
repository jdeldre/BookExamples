module BookExamples

using PotentialFlow

using PyPlot

import PotentialFlow.Utils:@get, MappedVector

import PyCall

export plot_streamlines

const mygreen = [151/255,180/255,118/255];


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

function plot_streamlines(b::Bodies.PowerBody,m::Bodies.RigidBodyMotion,t)

  PyCall.PyDict(matplotlib["rcParams"])["font.family"] = "STIXGeneral";
  PyCall.PyDict(matplotlib["rcParams"])["mathtext.fontset"] = "stix";
  PyCall.PyDict(matplotlib["rcParams"])["font.size"] = 14;

  Z, ζ = setup_grid(b)

  ψ = zero(ζ);
  ψ = Bodies.streamfunction.(ζ,b,m,t)

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

  pc = PyPlot.contour(real(Z),imag(Z),ψ,v,colors="black",linestyles="solid",linewidths=1);
  pf = PyPlot.fill(real(b.zs),imag(b.zs),facecolor=mygreen);
  PyPlot.plot(real(b.zs),imag(b.zs),color=mygreen);

  #PyPlot.savefig("/Users/jeff/Desktop/testfig2.eps",format="eps")

end

function plot_streamlines(b::Bodies.PowerBody,src,t)

  PyCall.PyDict(matplotlib["rcParams"])["font.family"] = "STIXGeneral";
  PyCall.PyDict(matplotlib["rcParams"])["mathtext.fontset"] = "stix";
  PyCall.PyDict(matplotlib["rcParams"])["font.size"] = 14;

  Z, ζ = setup_grid(b)

  #ψ = zero(ζ);
  ψ = [Bodies.streamfunction(ζi,b,src,t) for ζi in ζ]

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

  pc = PyPlot.contour(real(Z),imag(Z),ψ,v,colors="black",linestyles="solid",linewidths=1);
  pf = PyPlot.fill(real(b.zs),imag(b.zs),facecolor=mygreen);
  PyPlot.plot(real(b.zs),imag(b.zs),color=mygreen);

  z = Elements.conftransform(src,b);
  PyPlot.plot(real.(z),imag.(z),"ro",markersize=3);

  #PyPlot.savefig("/Users/jeff/Desktop/testfig2.eps",format="eps")

end

end
