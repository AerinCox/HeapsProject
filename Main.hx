import hxd.fmt.fbx.Geometry;
import hxd.fmt.hmd.Data.Model;
import h3d.scene.World.WorldModel;
import h3d.scene.World.WorldModelGeometry;
import h3d.Vector;
import h2d.Interactive;
import h3d.Camera;
import h3d.prim.Cube;
import h3d.scene.*;

class WASDCameraController extends h3d.scene.CameraController {
	override function onEvent(e:hxd.Event) {
		switch (e.kind) {
			case EWheel:
				zoom(e.wheelDelta);
			default:
		}
	}
	override public function rot(dx, dy) {
		moveX += dx;
		moveY += dy;
	}
}

class WorldMesh extends h3d.scene.World {
	public var soilInteract:List<h3d.scene.Interactive>;

	override public function new(chunkSize:Int, parent, ?autoCollect = true) {
		super(chunkSize, parent, autoCollect);
		this.soilInteract = new List<h3d.scene.Interactive>();
	}

	override function initChunkSoil(c:h3d.scene.World.WorldChunk) {
		var cube = new h3d.prim.Cube(chunkSize, chunkSize, 0);
		cube.addNormals();
		cube.addUVs();
		var soil = new h3d.scene.Mesh(cube, c.root);
		soil.x = c.x;
		soil.y = c.y;
		soil.material.texture = h3d.mat.Texture.fromColor(0x408020);
		soil.material.shadows = true;

		this.soilInteract.add(new h3d.scene.Interactive(soil.getCollider(), c.root));
	}
}

class Main extends hxd.App {
	var cube1:Mesh;
	var world:WorldMesh;
	var camera:WASDCameraController;

	var line:h2d.Graphics;

	override function init() {
		super.init();

		// World
		world = new WorldMesh(16, s3d);
		var r = world.loadModel(hxd.Res.rock);

		for (i in 0...1000)
			world.add(r, Math.random() * 128, Math.random() * 128, 0, 1.2 + hxd.Math.srand(0.4), hxd.Math.srand(Math.PI));

		world.done();

		// Init cube
		var cubeShape = new h3d.prim.Cube();
		// cubeShape.translate(-0.5, -0.5, -0.5);
		cubeShape.unindex();
		cubeShape.addNormals();
		cubeShape.addUVs();
		cube1 = new Mesh(cubeShape, s3d);
		cube1.scale(0.2);
		cube1.material.shadows = false;

		// Light
		// var light = new h3d.scene.fwd.DirLight(new h3d.Vector(0.3, -0.4, -0.9), s3d);
		s3d.lightSystem.ambientLight.setColor(0x909090);

		var shadow = s3d.renderer.getPass(h3d.pass.DefaultShadowMap);
		shadow.size = 2048;
		shadow.power = 200;
		shadow.blur.radius = 0;
		shadow.bias *= 0.1;
		shadow.color.set(0.7, 0.7, 0.7);

		var parts = new h3d.parts.GpuParticles(world);
		var g = parts.addGroup();
		g.size = 0.2;
		g.gravity = 1;
		g.life = 10;
		g.nparts = 10000;
		g.emitMode = CameraBounds;
		parts.volumeBounds = h3d.col.Bounds.fromValues(-20, -20, 15, 40, 40, 40);

		s3d.camera.target.set(72, 72, 0);
		s3d.camera.pos.set(120, 120, 40);
		s3d.camera.zNear = 1;
		s3d.camera.zFar = 100;
		camera = new WASDCameraController(s3d);
		camera.initFromScene();

		// Cursor
		line = new h2d.Graphics(s2d);
		line.beginFill(0xFFFFFFFF);
		line.drawRect(0, -0.5, 100, 1);
		line.endFill();

		// Interactions
		// var cubeEvent = new h3d.scene.Interactive(cube1.getCollider(), s3d);
		// cubeEvent.onOver = function(e:hxd.Event) {
		// 	cube1.material.color.set(1, 1, 0);
		// }

		//broken
		for (interact in world.soilInteract) {
			interact.onClick = function(e:hxd.Event) {
				cube1.setPosition(e.relX, e.relY, e.relZ);
				trace("Setting position to " + e.relX + " " + e.relY + " " + e.relZ);
			}
		}

		// Keyboard Input
		hxd.Window.getInstance().addEventTarget(onEvent);
	}

	// Don't forget to remove the event using removeEventTarget when disposing your objects.
	function onEvent(event:hxd.Event) {
		// // W
		// if (event.kind == EKeyDown && event.keyCode == 87) {
		// 	cube1.setPosition(cube1.x, cube1.y, cube1.z + 0.1);
		// }
		// // S
		// if (event.kind == EKeyDown && event.keyCode == 87) {
		// 	cube1.setPosition(cube1.x, cube1.y, cube1.z - 0.1);
		// }
		// // A
		// if (event.kind == EKeyDown && event.keyCode == 65) {
		// 	cube1.setPosition(cube1.x - 0.1, cube1.y, cube1.z);
		// }
		// // D
		// if (event.kind == EKeyDown && event.keyCode == 68) {
		// 	cube1.setPosition(cube1.x + 0.1, cube1.y, cube1.z);
		// }
	}

	override function update(dt:Float) {
		// Cursor
		var px = s2d.mouseX;
		var py = s2d.mouseY;

		line.x = px;
		line.y = py;

		if (hxd.Key.isDown(hxd.Key.A)) {
			camera.rot(5, 0);
		}
		if (hxd.Key.isDown(hxd.Key.D)) {
			camera.rot(-5, 0);
		}
		if (hxd.Key.isDown(hxd.Key.W)) {
			camera.rot(0, 5);
		}
		if (hxd.Key.isDown(hxd.Key.S)) {
			camera.rot(0, -5);
		}
	}

	static function main() {
		hxd.Res.initEmbed(); // https://heaps.io/documentation/resource-management.html
		new Main();
	}
}
