package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		trace("Launching the game...");
		
		addChild(new FlxGame(320*2, 512*2, PlayState));
	}
}
