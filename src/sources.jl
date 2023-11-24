abstract type ScatteringSource end

"""
    ScatteringPoint

Represents a scattering point source at some `pos`ition in space and with
monostatic RCS function `sigma`.
"""
struct ScatteringPoint <: ScatteringSource
    pos::Meshes.Point
    sigma::Function
end

"""
    ScatteringPoint

Represents a scattering line source that extends from a point `a` to another
point `b` with a monostatic RCS function `sigma`.
"""
struct ScatteringLine <: ScatteringSource
	a::Meshes.Point
	b::Meshes.Point
	amplitude::Float64
    sigma::Function
end

@doc raw"""
    coherentsum(sources, lambda, phi)

Calculate the coherent far-field sum of a set of `sources`, at a specific
wavelength `lambda`, and angle `phi` relative to the positive-x-direction.
```math
\sigma(\phi) = \left| \sum_{i=1}^N \sqrt{\sigma_i(\phi)} \exp\left[ 2\frac{2\pi}{\lambda} \left( x\,\cos\phi + y\,\sin\phi \right) \right] \right|^2
```
"""
function coherentsum(sources::Vector{ScatteringSource}, lambda, phi)
	phase(x,y) = 2*(2π/lambda) * (x*cos(phi) + y*sin(phi))
	contribution(source) = sqrt(source.sigma(θ)) * exp(j*phase(x(source.pos), y(source.pos)))
    abs(sum([contribution(source) for source in sources]))^2
end
