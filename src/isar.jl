mutable struct ISAR_Image{T}
    img::Matrix{T}
    xlims::Tuple{Float64,Float64}
    ylims::Tuple{Float64,Float64}
    resolution::Tuple{Int64,Int64}
    xstep::Float64
    ystep::Float64
end

# Construct a blank image
function ISAR_Image(; xlims, ylims, resolution)
    img = zeros(Gray{Float64}, resolution)
    xstep = (xlims[2] - xlims[1]) / (resolution[1] - 1)
    ystep = (ylims[2] - ylims[1]) / (resolution[2] - 1)
    
    ISAR_Image(img, xlims, ylims, resolution, xstep, ystep)
end

# Map a spatial (x,y) point to image array indices (i, j)
function _map_point_to_img(point::Meshes.Point, isar::ISAR_Image)
	# Get spatial center for the n'th element along each axis
	_x(i::T) where {T<:Integer} = isar.xlims[1] + i * isar.xstep
	_y(j::T) where {T<:Integer} = isar.ylims[1] + j * isar.ystep
	
	# Error between desired point and the i'th center along each axis
	xerr(i::T) where {T<:Integer} = x(point) - _x(i)
	yerr(j::T) where {T<:Integer} = y(point) - _y(j)
	
	# Find closest spatial center along x axis
	i_opt = findfirst(i -> xerr(i) < 0, 1:isar.resolution[1])
	i = abs(xerr(i_opt)) < abs(xerr(i_opt-1)) ? i_opt : (i_opt - 1)
	
	# Find closest spatial center along y axis
	j_opt = findfirst(j -> yerr(j) < 0, 1:isar.resolution[2])
	j = abs(yerr(j_opt)) < abs(yerr(j_opt-1)) ? j_opt : (j_opt - 1)

	return (j,i)
end

# Draw a ScatteringPoint on in ISAR image
function _isar_add_layer!(isar::ISAR_Image, source::ScatteringPoint)
	# Map source point (x,y) to image pixel (x,y)
	(img_x, img_y) = _map_point_to_img(source.pos, isar)
	
	# Draw the point on the image
	draw!(isar.img, ImageDraw.Point(img_x,img_y), Gray{Float64}(1.0))

	return nothing
end

# Draw a ScatteringLine on in ISAR image
function _isar_add_layer!(isar::ISAR_Image, source::ScatteringLine)
	# Map source end-points (x,y) to image pixel (x,y)
	(img_a_x, img_a_y) = _map_point_to_img(source.a, isar)
	(img_b_x, img_b_y) = _map_point_to_img(source.b, isar)
	
	# Create end points from these coordinates
	img_a = ImageDraw.Point(img_a_x, img_a_y)
	img_b = ImageDraw.Point(img_b_x, img_b_y)
	
	# Draw a line segment on the image
	draw!(isar.img, LineSegment(img_a,img_b), Gray{Float64}(1.0), xiaolin_wu)

	return nothing
end

# Draw simulated noise on an ISAR image
function _isar_add_noise!(isar::ISAR_Image, level)
	# Require that level is within range [0,1] to bound value of Color type Gray{}
	if !( 0 <= level <= 1 )
		error("Level must be inside range [0,1]")
	end

	# Construct an image layer representing noise: each pixel IID uniform random in [0, level]
	noise = [Gray{Float64}(level*rand()) for x in 1:isar.resolution[1], y in 1:isar.resolution[2]]

	# Add noise layer to existing image data
	isar.img .+= noise

	return nothing
end

"""
	generate_isar(sources; xlims, ylims, resolution, noise_level)

Generate a simulated ISAR_Image from a set of ScatteringSource's, where the image is
bounded by `xlims` and `ylims` and sampled at a given `resolution`.

Optional settings:
- `gsd` (Ground Sample Distance in meters) is used for automatic resolution determination
"""
function generate_isar(
	sources::Vector{T};
	xlims=:auto, ylims=:auto, resolution=:auto, noise_level=0.1, gsd=0.02, pad_factor=0.5
) where {T<:ScatteringSource}
	# If :auto limits, determine reasonable settings
	if (xlims == :auto) || (ylims == :auto)
		# Calculate a 2D bounding box enclosing all source geometries
		bbox = boundingbox(map(_geometry, sources))
		pads = pad_factor .* (bbox.max - bbox.min)

		# For any :auto axis limits, use the bounding box limits expanded by the padding
		if (xlims == :auto)
			xlims = x.([bbox.min, bbox.max]) .+ (-pads[1], pads[1])
		end
		if (ylims == :auto)
			ylims = y.([bbox.min, bbox.max]) .+ (-pads[2], pads[2])
		end
	end

	# If :auto resolution, determine reasonable settings
	if resolution == :auto
		ranges = (xlims[2]-xlims[1], ylims[2]-ylims[1])
		resolution = round.(Int, ranges ./ gsd)
	end

	# Generate a blank monochrome image
	isar = ISAR_Image(xlims=xlims, ylims=ylims, resolution=resolution)
	
	# Iteratively add each provided source to the image
	foreach(source -> _isar_add_layer!(isar,source), sources)
	
	# Apply a Gaussian blur
	isar.img = imfilter(isar.img, Kernel.gaussian(1))

	# Add noise
	_isar_add_noise!(isar, noise_level)
	
	# Return the finished image
	return isar
end
