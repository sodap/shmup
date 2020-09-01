package;

/**
 * Handy, pre-built Registry class that can be used to store
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
class Reg
{
	public static var recording:Bool = false;
	public static var replaying:Bool = true;
	public static var finalScore:Int = 0;
	public static var inputNewScore:Bool = false;
	public static var lastKey:Int = 0;
	public static var goToTitle:Bool = false;
	public static var attractMode:String = "fail";
}
