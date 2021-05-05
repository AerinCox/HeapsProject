import Pathfinder.Coordinate;
import h3d.col.Point;
import h3d.scene.Mesh;

class Entity {
	var id:Int;
	var mesh:Mesh;

	public function new(id:Int, mesh:Mesh) {
		this.id = id;
		this.mesh = mesh;
	}

	public function getId() {
		return id;
	}

	public function setPosition(x:Float, y:Float, z:Float) {
		mesh.setPosition(x, y, z);
	}
}

// Entities that also use pathfinding
class PathedEntity extends Entity {
	var pathFinder:Pathfinder;
	var currPath:Array<Coordinate>;
    var startPosition:Point;
	var index:Int = 0;
	var time:Float = 0;

    public function new(id:Int, mesh:Mesh, world:WorldSquare ) {
		super(id, mesh);
        pathFinder = new Pathfinder(world);
        currPath = [];
	}

    public function setPath(destX:Int, destY:Int){
        this.currPath = pathFinder.generatePath(Math.round(mesh.x), Math.round(mesh.y), destX, destY);
        this.startPosition = new Point(mesh.x, mesh.y, mesh.z);
        this.index = 0;
        this.time = 0;
    }

	public function path(dt: Float) {
		if (currPath != null && currPath.length != 0) {
			time += dt;
			if (time <= 1) {
				var lerpX = Utility.lerp(startPosition.x, currPath[index].x + 0.5, time); // TODO: Center the object in a way that actually works 100% of the time lol
				var lerpY = Utility.lerp(startPosition.y, currPath[index].y + 0.5, time);
				// var lerpZ = Utility.lerp(currZ, world.getZ(currPath[index].x, currPath[index].y), time); // TODO: Put back in Z stuff.
				setPosition(lerpX, lerpY, 0);
				return [lerpX, lerpY];
			} else {
				if (index + 1 == currPath.length) {
					currPath = null;
					index = 0;
					time = 0;
				} else {
					time = 0;
                    startPosition.x = mesh.x;
                    startPosition.y = mesh.y;
                    startPosition.z = mesh.z;
					index++;
				}
			}
		}
        return null;
	}
    public function getCurrPath(){
        return this.currPath;
    }
}
