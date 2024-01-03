################################################################################
#        Scattering Sources
################################################################################

abstract type ScatteringSource end

"""
    ScatteringPoint

Represents a scattering point source at some `pos`ition in space and with
monostatic RCS function `sigma`.
"""
struct ScatteringPoint <: ScatteringSource
    pos::Meshes.Point
    sigma::Function
    isar_amplitude::Float64
end

"""
    ScatteringLine

Represents a scattering line source that extends from a point `a` to another
point `b` with a monostatic RCS function `sigma`.
"""
struct ScatteringLine <: ScatteringSource
	a::Meshes.Point
	b::Meshes.Point
    s::Meshes.Segment
    sigma::Function
    isar_amplitude::Float64
end

################################################################################
#        Composites
################################################################################

"""
    Planform

    Represents a two-dimensional planform.
"""
struct Planform
    boundary::Meshes.Ngon
    sources_defects::Vector{ScatteringPoint}
    sources_edges::Vector{ScatteringLine}
end

# Construct a planform given only the boundary geometry
function Planform(
    boundary::Meshes.Ngon;
    defects::Bool=true, defect_density::Int64=1000, defect_severity::Float64=1e-6
)
    # Generate defects within boundary
    if defects
        sampler = HomogeneousSampling(1000)
        points = sample(planform, sampler) |> collect
        sigma = let val = defect_severity
                    phi -> val
                end
        sources_defects = [ScatteringPoint(pos, sigma, defect_severity) for pos in points]
    else
        sources_defects = ScatteringPoint[]
    end

    # Generate edge Sources
    # sources_edges = [ScatteringLine(segment) for segment in segments(boundary)]
    # TODO (see Pluto notebooks):
    # - Define segments(::Meshes.Ngon)::Vector{Meshes.Segment}
    # - Define ScatteringLine(::Meshes.Segment)

    Planform(boundary, sources_defects, sources_edges)
end

################################################################################
#        Utilities
################################################################################

@doc raw"""
    coherentsum(sources, lambda, phi)

Calculate the coherent far-field sum of a set of `sources`, at a specific
wavelength `lambda`, and angle `phi` relative to the positive-x direction.
```math
\sigma(\phi) = \left| \sum_{i=1}^N \sqrt{\sigma_i(\phi)} \exp\left[ 2\frac{2\pi}{\lambda} \left( x\,\cos\phi + y\,\sin\phi \right) \right] \right|^2
```
"""
function coherentsum(sources::Vector{T}, lambda, phi) where {T<:ScatteringSource}
	phase(x,y) = 2*(2π/lambda) * (x*cos(phi) + y*sin(phi))
	contribution(source) = sqrt(source.sigma(θ)) * exp(j*phase(x(source.pos), y(source.pos)))
    abs(sum([contribution(source) for source in sources]))^2
end

# Get the fundamental geometry object associated with a ScatteringSource
_geometry(pt::ScatteringPoint) = pt.pos
_geometry(line::ScatteringLine) = pt.s
