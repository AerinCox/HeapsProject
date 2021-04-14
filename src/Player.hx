import h3d.col.Point;
import h3d.scene.Mesh;

class Player {
	public var mesh:Mesh;
	public var currPosition:Point;
	public var goalPosition:Point;

	public function new(mesh:Mesh) {
		this.mesh = mesh;
		currPosition = new Point(0, 0, 0);
		goalPosition = new Point(0, 0, 0);
		mesh.setPosition(0, 0, 0);
	}

    public function setGoalPosition(x:Int, y:Int, z:Int){
        goalPosition = new Point(x,y,z);
    }
    public function teleport(x:Int, y:Int, z:Int){
        currPosition = new Point(x,y,z);
        goalPosition = new Point(x,y,z);
        mesh.setPosition(x,y,z);
    }

    // public function move(){
    //     if(currPosition == goalPosition){
    //         return;
    //     }
    //     mesh.setPosition()
    // }
}
