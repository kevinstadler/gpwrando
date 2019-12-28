const GeoTIFF = require('geotiff.js');

const getImage = async (filename) => {
	return await (await GeoTIFF.fromFile(filename)).getImage();
}

const createCumTable = async (image) => {
	const data = await image.readRasters();
	// locate non-zero entries
	const indices = Array.from(Array(data.width * data.height).keys()).filter((i) => data[0][i] > 0);

	// reduce is too damn slow accumulating arrays so do this instead
	const cum = indices.map((i) => data[0][i]);
	for (let i = 1; i < cum.length; i++) {
		cum[i] += cum[i-1];
	}

	// transform into 2d indices
	const indices2 = indices.map((i) => [  Math.floor(i / data.width), i % data.width ]);
	return({ indices: indices2, cum: cum });
}

// return the lookup index inside the cumulative table
const getIndex = (cumTable, value) => {
	return cumTable.cum.findIndex((e) => value <= e);
}

// returns a (promise of a) bounding box of a randomly sampled individual
module.exports = async () => {
	const overview = await createCumTable(await getImage('data/overview.tif'))
	const r = Math.random() * overview.cum[ overview.cum.length - 1 ];
	const oi = getIndex(overview, r);

	const cellImage = await getImage('data/' + overview.indices[oi][0] + '/' + overview.indices[oi][1] + '.tif');
	const cell = await createCumTable(cellImage);
	// subtract offset (unless in first cell)
	const ci = getIndex(cell, oi === 0 ? r : r - overview.cum[oi-1]);

	const resolution = cellImage.getResolution();
	const origin = cellImage.getOrigin();

	return([
		origin[0] + cell.indices[ci][0] * resolution[0],
		origin[1] + (cell.indices[ci][0]+1) * resolution[1],
		origin[0] + cell.indices[ci][1] * resolution[0],
		origin[1] + (cell.indices[ci][1]+1) * resolution[1],
		]);
}
