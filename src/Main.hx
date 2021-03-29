import hxd.Key;
import hxd.Event;
import hxd.fmt.fbx.Geometry;
import hxd.fmt.hmd.Data.Model;
import h3d.scene.World.WorldModel;
import h3d.scene.World.WorldModelGeometry;
import h3d.Vector;
import h2d.Interactive;
import h3d.prim.Cube;
import h3d.scene.*;

class WASDCameraController extends h3d.scene.CameraController {
	override function onEvent(e:hxd.Event) {
		e.propagate = true;
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

	public function setPos(xPos, yPos) {
		targetOffset.x = xPos;
		targetOffset.y = yPos;
	}
}

class WorldMesh extends h3d.scene.World {
	public var interactFunction:(e:Event) -> Void;

	override public function new(chunkSize:Int, parent, ?autoCollect = true) {
		super(chunkSize, parent, autoCollect);
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

		var interactive = new h3d.scene.Interactive(soil.getCollider(), c.root);
		interactive.propagateEvents = true;
		interactive.onClick = function(e:hxd.Event) {
			interactFunction(e);
		}
	}
}

class Main extends hxd.App {
	var player:Mesh;
	var world:WorldMesh;

	var camera:WASDCameraController;
	var line:h2d.Graphics;

	override function init() {
		super.init();

		// World
		world = new WorldMesh(16, s3d);
		var rock = world.loadModel(hxd.Res.rock);

		for (i in 0...1000)
			world.add(rock, Math.random() * 128, Math.random() * 128, 0, 1.2 + hxd.Math.srand(0.4), hxd.Math.srand(Math.PI));

		world.done();

		// Camera
		camera = new WASDCameraController(50, s3d);
		camera.set(500);

		// Player
		var cubeShape = new h3d.prim.Cube();
		cubeShape.unindex();
		cubeShape.addNormals();
		cubeShape.addUVs();
		player = new Mesh(cubeShape, s3d);
		player.scale(0.2);
		player.material.shadows = false;

		// Interactable Object
		var cache = new h3d.prim.ModelCache();
		var interactableRock = cache.loadModel(hxd.Res.rock);
		for (mat in interactableRock.getMaterials()) {
			mat.color.set(1, 0, 0);
		}
		interactableRock.scale(5);
		interactableRock.setPosition(50,50,0);
		var rockRightClick = new h3d.scene.Interactive(interactableRock.getCollider(), s3d);
		rockRightClick.propagateEvents = true;
		rockRightClick.enableRightButton = true;
		rockRightClick.onRelease = function (e : hxd.Event){
			if(hxd.Key.isReleased(Key.MOUSE_RIGHT)){
				
			}
		}
		s3d.addChild(interactableRock);

		// Light
		new h3d.scene.fwd.DirLight(new h3d.Vector(0.3, -0.4, -0.9), s3d);
		s3d.lightSystem.ambientLight.setColor(0x990000);

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

		// Interactions
		var clickToMove = function(e:hxd.Event) {
			player.setPosition(e.relX, e.relY, e.relZ);
			camera.setPos(e.relX, e.relY);
		};
		world.interactFunction = clickToMove;

		// Cursor
		line = new h2d.Graphics(s2d);
		line.beginFill(0xFFFFFFFF);
		line.drawRect(0, -0.5, 100, 1);
		line.endFill();

		// A General World Event
		// hxd.Window.getInstance().addEventTarget(onEvent);
	}

	// Don't forget to remove the event using removeEventTarget when disposing your objects.
	function onEvent(event:hxd.Event) {/* Not used currently */}

	override function update(dt:Float) {
		// Cursor
		var px = s2d.mouseX;
		var py = s2d.mouseY;

		line.x = px;
		line.y = py;

		// Camera Rotation
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
