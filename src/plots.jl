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

	return isar
end

#=  Test code to produce an image
isartest = ISAR_Image(xlims=(-5,5), ylims=(-1.5,1.5), resolution=(201,151))

fig = Figure()
ax = Makie.Axis(fig[1,1], aspect=1)
showisar(ax, isartest)

save("./irate_pretest_plot.png", fig)
fig
=#

#=  Old test settings
fig = Figure(size=(800,600))
# ax = Makie.Axis(fig[1,1], title="Simulated ISAR Image",
# 				limits=(isar.xlims,isar.ylims),
# 				xlabel="Cross-range [m]",
# 				ylabel="Down-range [m]"  )
=#