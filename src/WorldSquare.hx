import hxd.res.Model;
import h3d.scene.Mesh;
import h3d.scene.Object;
import hxd.Event;

class WorldSquare {
	public var interactFunction:(e:Event) -> Void;
	var terrain : Terrain;
	var size : Int;
	var s3d : Object;

	public function new(size: Int, s3d:Object) {
		this.s3d = s3d;
		this.size = size;
		// Terrain
		// TODO: Heightmaps for each block.
		this.terrain = new Terrain(size);
		terrain.addNormals();
		terrain.addUVs();
		var soil = new h3d.scene.Mesh(terrain, s3d);
		soil.setPosition(0,0,0);
		// TODO: Fix weird shadow between block lines.
		soil.material.texture = h3d.mat.Texture.fromColor(0x408020);
		var interactive = new h3d.scene.Interactive(soil.getCollider(), s3d);
		interactive.propagateEvents = true;
		interactive.onClick = function(e:hxd.Event) {
			interactFunction(e);
		}
	}

    public function addModel( model : Model, cache : h3d.prim.ModelCache, x : Int, y : Int, scale = 1., rotation = 0. ) {
		var newObj = cache.loadModel(model);
		newObj.scale(scale);
		var z = terrain.points[(x * size) + y].z;
		newObj.setPosition(x, y, z);
		s3d.addChild(newObj);
	}
}