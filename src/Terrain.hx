import h3d.col.Point;

class Terrain extends h3d.prim.Polygon {
	public function new(chunkSize:Int) {
		var XSize = chunkSize + 1;
		var YSize = chunkSize + 1;
        
		var pointList = new Array<Point>();
		var idx = new hxd.IndexBuffer();

		// Initializing all the vertexes in the grid
		for (x in 0...XSize) {
			for (y in 0...YSize) {
				// TODO: Image Heightmap of some kind.
				var z = 0;
				if (x > (chunkSize / 2) - 20 && x < (chunkSize / 2) + 20) {
					z = 1;
				}
				// END TODO
				pointList.push(new Point(x, y, z));
			}
		}
		// Using those points to make our terrain
		for (i in 0...(XSize * YSize) - YSize) {
			if ((i + 1) % YSize == 0) {
				continue;
			}
			// Left Triangle
			idx.push(i);
			idx.push(i + YSize);
			idx.push(i + YSize + 1);
			// Right Triangle
			idx.push(i);
			idx.push(i + YSize + 1);
			idx.push(i + 1);
		}
		super(pointList, idx);
	}
}
