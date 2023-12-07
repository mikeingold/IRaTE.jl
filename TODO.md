# TODO:
- Develop a symbolic expression for sigma(::ScatteringLine, phi)
    - Function of phi, lambda, and line length
    - Maybe simplify to function of angle and line length (in lamdba's)
    - Fallback: estimate using JefimenkoModels and basis functions
- File a PR with **ImageDraw.jl** regarding `core.jl:~304` to enable `method` keyword arg like `line2d.jl:64` has
- Recipe for showplanform(::Planform) to draw basic planform geometry