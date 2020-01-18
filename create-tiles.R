#!/usr/local/bin/Rscript

setwd('data')

if (!file.exists('gpwzeroed.tif')) {
	system('gdal_merge.py -init 0 -o gpwzeroed.tif -co COMPRESS=DEFLATE gpw_v4_population_count_rev11_2020_30_sec.tif')
}
gpwzeroed <- raster::raster('gpwzeroed.tif')

writecompact <- function(data, filename) {
	raster::writeRaster(data, filename, overwrite=TRUE, options=c('COMPRESS=DEFLATE'))
	return(which(raster::values(data) > 0))
}

rows <- 72
cols <- 144
rowsize <- nrow(gpwzeroed) / rows
colsize <- ncol(gpwzeroed) / cols

# create and write overview

if (file.exists('overview.tif')) {
	overview <- raster::raster('overview.tif')
	dataindices <- which(raster::values(overview) > 0)
} else {

	overview <- raster::aggregate(gpwzeroed, fact=c(colsize, rowsize), fun=sum)
	dataindices <- writecompact(overview, 'overviewnodata.tif')
    system('gdal_merge.py -init 0 -o overview.tif -co COMPRESS=DEFLATE overviewnodata.tif') # -a_nodata 0
}

# write tiles

r <- raster::raster(ncols=colsize, nrows=rowsize)

dataindicesarray <- arrayInd(dataindices, c(cols, rows))

extent <- raster::extent(overview)
xres <- raster::xres(overview)
yres <- -raster::yres(overview)

for (i in seq(dataindices)) {
	print(paste('writing', i, 'of', length(dataindices)))
	tilename <- paste(dataindicesarray[i, 2] - 1, '/', dataindicesarray[i, 1] - 1, '.tif', sep = '')
	print(tilename)

	xoff <- (dataindicesarray[i, 1] - 1) * rowsize
	yoff <- (dataindicesarray[i, 2] - 1) * colsize

	# sanity check: within-tile sum and overview value are the same
##	data <- raster::getValuesBlock(gpwzeroed, 1 + yoff, rowsize, 1 + xoff, colsize)
#	print(sum(data, na.rm=TRUE))
#	print(raster::getValuesBlock(overview, row=dataindicesarray[i, 2], col=dataindicesarray[i, 1], ncols=1))

#	dir.create(paste(dataindicesarray[i, 2] - 1), showWarnings = FALSE, recursive = TRUE, mode = '0755')

#	print(extent[c(1, 4)] + c(xres, yres) * (dataindicesarray[i,]-1) )
#	print(raster::xyFromCell(overview, dataindices[i]))
#	print(extent[c(1, 4)] + c(xres, yres) * (dataindicesarray[i,]) )
##	raster::values(r) <- data
##	raster::extent(r) <- c(extent[1] + xres * (dataindicesarray[i,1] - 1:0 ), extent[4] + yres * ( dataindicesarray[i,2] - 0:1 ))
#	print(length(writecompact(r, tilename)))

#	file.rename(tilename, paste(dataindices[i], '-deflate.tif', sep = ''))
#	file.rename(tilename, paste(dataindicesarray[i, 2] - 1, '/', dataindicesarray[i, 1] - 1, '-lzw.tif', sep = ''))
#	file.rename(paste(dataindices[i], '-deflate.tif', sep = ''), tilename)

	# initial generation
#	system(paste('gdal_translate -srcwin', xoff, yoff, rowsize, colsize, '-co "COMPRESS=DEFLATE" gpwzeroed.tif', paste(dataindices[i], '-deflate.tif', sep = ''), sep=' '))
#	system(paste('gdal_translate -srcwin', xoff, yoff, rowsize, colsize, '-co "COMPRESS=LZW" gpwzeroed.tif', paste(dataindices[i], '-lzw.tif', sep = ''), sep=' '))
}
