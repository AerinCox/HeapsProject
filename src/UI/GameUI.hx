package ui;
import h2d.Flow;

class GameUI {
	var examineFlow:h2d.Flow;
	var s2d:h2d.Scene;

	public function new(s2d:h2d.Scene) {
		this.s2d = s2d;
	}

	public function clearExamine() {
		if (examineFlow != null) {
			examineFlow.remove();
		}
	}

	public function makeExamine(xPos:Float, yPos:Float) {
		examineFlow = new Flow(s2d);
		examineFlow.layout = Vertical;
		examineFlow.horizontalSpacing = 10;
		var button = new Button(examineFlow, 100, 60);
		button.setText("Attack Pee Pee", Color.BLACK);
		var button2 = new Button(examineFlow, 100, 60);
		button2.setText("Examine Poo Poo", Color.BLACK);

		examineFlow.setPosition(xPos - 20, yPos - 20);

		examineFlow.enableInteractive = true;
		examineFlow.interactive.propagateEvents = true;
		examineFlow.interactive.setPosition(-50, -50);
		examineFlow.interactive.setScale(2);
		examineFlow.interactive.onOut = function(_) {
			examineFlow.remove();
		};
	}

	function getColor(i:Int):Int {
		switch (i) {
			case 1:
				return Color.iBEIGE;
			case 2:
				return Color.iBLACK;
			case 3:
				return Color.iBLUE;
			case 4:
				return Color.iBROWN;
			case 5:
				return Color.iCYAN;
			case 6:
				return Color.iGREEN;
			default:
				return Color.iWHITE;
		}
	}
}
