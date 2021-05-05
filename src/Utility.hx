class Utility{
    public static function lerp(min:Float, max:Float, time:Float):Float {
		return min + (max - min) * time;
	}
}