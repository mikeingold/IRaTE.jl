"""
    Vec(s)

Convert a 2D Segment `s` with first vertice `a` and second vertice `b`to a 2D
`Meshes.Vec2` that points from `a` to `b`.
"""
Vec(s::Meshes.Segment) = s.vertices[2].coords - s.vertices[1].coords

"""
    ∠(v)

Calculate the angle of a 2D vector `v` relative to the positive `x` direction.
"""
∠(v::Meshes.Vec2) = ∠(Meshes.Vec(1,0), v)

"""
    ∠(v)

Calculate the angle of a 2D Segment `s` relative to the positive `x` direction.
"""
∠(s::Meshes.Segment) = ∠(Vec(s))

"""
    ⟂(s; dir=1)

Calculate the angle perpendicular to a 2D Segment `s`, treating `s` as a vector
pointing from its first vertice `a` toward its second vertice `b`. By default,
select the perpendicular axis that points to the left, when viewing `b` from `a`.
This orientation can be flipped by setting parameter `dir=-1`. 
"""
⟂(s::Meshes.Segment; dir=1) = mod(∠(s) + dir*π/2, 2π)

"""
    ∠(a,b)

Calculate the phase angle between two complex numbers.
"""
∠(a::C,b::C) where {C<:Complex} = min(abs(a-b), 2π-abs(a-b))

"""
    x(p)

Calculate the x-directed position of a Point `p`.
"""
x(p::Meshes.Point) = p.coords[1]

"""
    y(p)

Calculate the y-directed position of a Point `p`.
"""
y(p::Meshes.Point) = p.coords[2]
