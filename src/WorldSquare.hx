import hxd.res.Model;
import h3d.scene.Mesh;
import h3d.scene.Object;
import hxd.Event;

class WorldSquare {
	public var interactFunction:(e:Event) -> Void;

	var terrain:Terrain;
	var width:Int;
	var s3d:Object;
	var navMesh:Array<Bool>; // TRUE are spots that are good, FALSE is an obstacle

	public function new(width:Int, s3d:Object) {
		this.s3d = s3d;
		this.width = width;
		// Terrain
		// TODO: Heightmaps for each block.
		this.terrain = new Terrain(width);
		terrain.addNormals();
		terrain.addUVs();
		var soil = new h3d.scene.Mesh(terrain, s3d);
		soil.setPosition(0, 0, 0);
		// TODO: Fix weird shadow between block lines.
		soil.material.texture = h3d.mat.Texture.fromColor(0x408020);
		var interactive = new h3d.scene.Interactive(soil.getCollider(), s3d);
		interactive.propagateEvents = true;
		interactive.onClick = function(e:hxd.Event) {
			interactFunction(e);
		}
		navMesh = new Array<Bool>();
		for(x in 0...width){
			for (y in 0...width){
				navMesh[(x * width) + y] = true;
			}
		}
	}

	public function getZ(x:Int, y:Int){
		return terrain.points[(x * width) + y].z;
	}

	public function checkNavMesh(x:Int, y:Int){
		var coord = (x * width) + y;
		if(coord >= navMesh.length || coord < 0){
			return false;
		}
		return navMesh[coord];
	}
	public function getWidth(){
		return this.width;
	}

	public function addWall(x:Int, y:Int) {
		var cubeShape = new h3d.prim.Cube();
		cubeShape.unindex();
		cubeShape.addNormals();
		var wall = new Mesh(cubeShape, s3d);
		wall.scaleX = 1;
		wall.scaleY = 5;
		wall.scaleZ = 5;
		wall.material.shadows = false;
		wall.setPosition(x, y, getZ(x,y));

		for (wallWidth in x...x+1) {
			for (wallLength in y...(y + 5)) {
				navMesh[(wallWidth * width) + wallLength] = false;
			}
		}
	}

	public function addModel(model:Model, cache:h3d.prim.ModelCache, x:Int, y:Int, scale = 1., rotation = 0.) {
		var newObj = cache.loadModel(model);
		newObj.scale(scale);
		var z = terrain.points[(x * width) + y].z;
		newObj.setPosition(x, y, z);
		s3d.addChild(newObj);
	}
}
