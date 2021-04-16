#!/bin/sh

INPUT=gpw_v4_population_count_rev11_2020_30_sec.tif

COLS=144
ROWS=144

###gdal_merge.py -init 0 -o gpwzeroed.tif -co COMPRESS=LZW "$INPUT"
# mean is 8,5406425236537, times 43200x21600 = 933120000 (900mio) cells
# times 8,5406425236537 = total world populaton of 7969444351,671740544

###gdalwarp -ts $COLS $ROWS -r average "gpwzeroed.tif" overview.tif
#gdal_translate -outsize $COLS $ROWS -r average "$INPUT" tmp.tif
#SUM= # TODO get stats
#gdal_translate -scale 0 $SUM 0 1 tmp.tif overview.tif
#gdal_translate -a_scale sum

# 

# 32bit float mantissa is 23 bit long, i.e. "1.(23 bits)".
# the smallest representable difference just under 1 is therefore 1*2^24,
# which is around 1/16*10^9, i.e. good enough to capture even one person living
# in a raster area (plus minus some rounding error).

# tiles
#for ((i = 0; i < 10; i++)); do
#  gdal_translate -srcwin xoff yoff xsize ysize "$INPUT" -stats output.tif
#  gdal_calc.py --calc="A/asdasd" --outfile= -A "inputfile.tif"
#done;
#gdal2tiles.py --profile raster --zoom=8 --no-kml --webviewer=none --verbose "gpw_v4_population_count_rev11_2020_30_sec.tif" /Users/kevin/gpwtiles

# overview
