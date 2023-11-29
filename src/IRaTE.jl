module IRaTE
    using MakieCore
    using Meshes

    include("utils_meshes.jl")

    include("sources.jl")
    export Source, coherentsum

    include("isar.jl")
    export ISAR_Image, generate_isar

    include("plots.jl")
    export plot
end