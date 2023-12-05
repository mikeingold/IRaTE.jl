# Makie Recipe
Makie.@recipe(ShowISAR) do scene
    # Attributes provides a define-able API for plot-specific settings
    # These aren't automatically propagated, merely passed as fields in a ShowISAR scene object
	Attributes()
end

function Makie.plot!(isar::ShowISAR{<:Tuple{ISAR_Image}})
	# Extract from image struct: x & y ranges, resolution, and the image itself
	xs = range(isar[1][].xlims[1], isar[1][].xlims[2], length=isar[1][].resolution[1])
	ys = range(isar[1][].ylims[1], isar[1][].ylims[2], length=isar[1][].resolution[2])
	img = Makie.Observable(isar[1][].img)

	# Plot image as a heatmap, updates automatically if the image data is changed
	Makie.heatmap!(isar,xs,ys, Makie.@lift(reinterpret(Float64,$img)), colormap=Reverse(:deep))

	isar.axis.title = "ISAR Image"
	isar.axis.xlabel = "Cross-Range [m]"
	isar.axis.ylabel = "Down-Range [m]"
	isar.axis.aspect = DataAspect()

	return isar
end
