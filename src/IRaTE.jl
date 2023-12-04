module IRaTE
    using Images, ImageDraw, ImageFiltering
    using Makie
    using Meshes

    include("utils_meshes.jl")

    include("sources.jl")
    export ScatteringSource, ScatteringPoint, ScatteringLine
    export coherentsum

    include("isar.jl")
    export ISAR_Image, generate_isar

    include("plots.jl")
    export plot
end