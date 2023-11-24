function plot(isar::ISAR_Image; size=(640,480))
	fig = Figure(size=(800,600))
	ax = Makie.Axis(fig[1,1], title="Simulated ISAR Image",
					limits=(isar.xlims,isar.ylims),
					xlabel="Cross-range [m]",
					ylabel="Down-range [m]"  )

	xs = range(isar.xlims[1], isar.xlims[2], length=isar.resolution[1])
	ys = range(isar.ylims[1], isar.ylims[2], length=isar.resolution[2])
	
	heatmap!(ax,xs,ys,reinterpret(Float64,isar.img), colormap=Reverse(:deep))
	fig
end