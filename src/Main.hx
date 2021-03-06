import Pathfinder.Coordinate;
import hxd.Key;
import hxd.Event;
import h3d.Vector;
import h3d.prim.Cube;
import h3d.scene.*;
// import ch3.scene.S2DPlane;
import h2d.Graphics;
import ui.*;
import networking.*;

class WASDCameraController extends h3d.scene.CameraController {
	override public function new(?distance, ?s3d, ?s2d) {
		super(distance, s3d);
	}

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

	public function setPos(xPos:Float, yPos:Float, xMouse:Float, yMouse:Float) {
		targetOffset.x = xPos;
		targetOffset.y = yPos;
	}
}

// class UniqueKey {
// 	private static var _key = 0;
// 	public static function getNextKey() {
// 		return ++_key;
// 	}
// }

class Main extends hxd.App {
	var player:Player;
	var world:WorldSquare;

	public static var camera:WASDCameraController;

	var cursor:h2d.Graphics;
	var interactableRock:h3d.scene.Object;
	var gameUI:GameUI;

	override function init() {
		super.init();

		// World
		world = new WorldSquare(16, s3d);
		world.addWall(2, 2);

		// Camera
		camera = new WASDCameraController(50, s3d, s2d);
		camera.set(500);

		// Player
		var cubeShape = new h3d.prim.Cube();
		cubeShape.unindex();
		cubeShape.addNormals();
		cubeShape.addUVs();
		var mesh = new Mesh(cubeShape, s3d);
		mesh.scale(0.2);
		mesh.material.shadows = false;
		mesh.setPosition(0, 0, 0);

		player = new Player(0, mesh, world);

		// Game UI
		gameUI = new GameUI(s2d);

		// Objects
		var cache = new h3d.prim.ModelCache();
		world.addModel(hxd.Res.rock, cache, 8, 1, 1, 0);

		interactableRock = cache.loadModel(hxd.Res.rock);
		for (mat in interactableRock.getMaterials()) {
			mat.color.set(1, 0, 0);
		}
		interactableRock.scale(5);
		interactableRock.setPosition(50, 50, 0);
		var rockRightClick = new h3d.scene.Interactive(interactableRock.getCollider(), s3d);
		rockRightClick.propagateEvents = true;
		rockRightClick.enableRightButton = true;
		rockRightClick.onRelease = function(e:hxd.Event) {
			if (hxd.Key.isReleased(Key.MOUSE_RIGHT)) {
				gameUI.clearExamine();
				gameUI.makeExamine(s2d.mouseX, s2d.mouseY);
			}
		}

		s3d.addChild(interactableRock);

		// Light n Shadow
		new h3d.scene.fwd.DirLight(new h3d.Vector(0.3, -0.4, -0.9), s3d);
		s3d.lightSystem.ambientLight.setColor(0x990000);

		var shadow = s3d.renderer.getPass(h3d.pass.DefaultShadowMap);
		shadow.size = 2048;
		shadow.power = 200;
		shadow.blur.radius = 0;
		shadow.bias *= 0.1;
		shadow.color.set(0.7, 0.7, 0.7);

		var parts = new h3d.parts.GpuParticles(s3d);
		var g = parts.addGroup();
		g.size = 0.2;
		g.gravity = 1;
		g.life = 10;
		g.nparts = 10000;
		g.emitMode = CameraBounds;
		parts.volumeBounds = h3d.col.Bounds.fromValues(-20, -20, 15, 40, 40, 40);

		// Networking
		var client = new Client();

		// Click to Move interaction
		var clickToMove = function(e:hxd.Event) {
			var eventX = Math.floor(e.relX);
			var eventY = Math.floor(e.relY);
			if (world.checkNavMesh(eventX, eventY)) {
				player.setPath(eventX, eventY);
				client.send("Im going to: " + player.getCurrPath()[0]);
			}
		};
		world.interactFunction = clickToMove;

		// Cursor
		cursor = new h2d.Graphics(s2d);
		cursor.beginFill(0xFFFFFFFF);
		cursor.drawRect(0, -0.5, 100, 1);
		cursor.endFill();

		// A General World Event
		// hxd.Window.getInstance().addEventTarget(onEvent);
	}

	// Don't forget to remove the event using removeEventTarget when disposing your objects.
	function onEvent(event:hxd.Event) {/* Not used currently */}

	override function update(dt:Float) {
		// Cursor
		var px = s2d.mouseX;
		var py = s2d.mouseY;

		cursor.x = px;
		cursor.y = py;

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
		var movement = player.path(dt);
		if (movement != null) {
			camera.setPos(movement[0], movement[1], s2d.mouseX, s2d.mouseY);
		}
	}

	static function main() {
		hxd.Res.initEmbed(); // https://heaps.io/documentation/resource-management.html
		new Main();
	}
}

// Code Notes
// 3d scene tile stuff
// var t = hxd.Res.dedede.toTile();
// t.dx = Std.int(-t.width / 2);
// t.dy = Std.int(-t.height / 2);
// rockRightClick.onRelease = function(e:hxd.Event) {
// 	if (hxd.Key.isReleased(Key.MOUSE_RIGHT)) {
// 		if (clickUI != null) {
// 			clickUI.remove();
// 		}
// 		clickUI = new TileSprite(t, 500, true, interactableRock);
// 		var newPos = clickUI.globalToLocal(new h3d.col.Point(e.relX, e.relY, e.relZ));
// 		clickUI.x = newPos.x;
// 		clickUI.y = newPos.y;
// 		clickUI.z = newPos.z;
// 		clickUI.material.receiveShadows = false;
// 		clickUI.material.texture.filter = Nearest;
// 	}
// }
