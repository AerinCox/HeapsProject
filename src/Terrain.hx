import h3d.col.Point;

class Terrain extends h3d.prim.Polygon {
	public function new() {
		var XSize = 50;
		var YSize = 50;
		var pointList = new Array<Point>();
		var idx = new hxd.IndexBuffer();
        
		// Initializing all the vertexes in the grid
		for (x in 0...XSize) {
			for (y in 0...YSize) {
				pointList.push(new Point(x, y, 0));
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