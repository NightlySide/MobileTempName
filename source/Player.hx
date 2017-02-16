package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.math.FlxPoint;

class Player extends FlxSprite
{
    private var _tileSize:Int = 64;
    private var _mousePos:FlxPoint;
    private var _mouseScreenPos:FlxPoint;
    private var _timeTouched:Float;

    public var speedInTiles:Float = 4;
    public var speedInPixels:Float;
    public var canvas:FlxSprite;

    override public function new(X:Float, Y:Float)
    {
        super(X, Y);

        loadGraphic(AssetPaths.player__png, false, 128, 128);
        speedInPixels = speedInTiles * _tileSize;
    }

    override public function update(delta:Float)
    {
        super.update(delta);
        move(delta);
    }

    private function move(delta)
	{ 
        velocity.set(0, 0);

        #if desktop
		var up = FlxG.keys.anyPressed([UP, Z]);
		var down = FlxG.keys.anyPressed([DOWN, S]);
		var left = FlxG.keys.anyPressed([LEFT, Q]);
		var right = FlxG.keys.anyPressed([RIGHT, D]);
        var attack_key = FlxG.keys.anyPressed([SPACE]);

        if (up && !down)
            velocity.y = -speedInPixels;
        else if (down && !up)
            velocity.y = speedInPixels;
        if (left && !right)
            velocity.x = -speedInPixels;
        else if (right && !left)
            velocity.x = speedInPixels;

        if (attack_key)
            attack();
		#end

        #if android
        for (touch in FlxG.touches.list){
            if (touch.justPressed) {
                _mousePos = new FlxPoint(touch.x, touch.y);
                _mouseScreenPos = new FlxPoint(touch.screenX, touch.screenY);
                _timeTouched = Date.getTime();
            }
            if (touch.pressed) {
                var distMax = 100;
                var mousePosChange:FlxPoint = new FlxPoint(touch.x, touch.y).subtractPoint(_mousePos);
                mousePosChange.x /= 100;
                mousePosChange.y /= 100;
                mousePosChange.x = Utils.clamp(mousePosChange.x, -1, 1);
                mousePosChange.y = Utils.clamp(mousePosChange.y, -1, 1);

                velocity.x = mousePosChange.x * speedInPixels;
                velocity.y = mousePosChange.y * speedInPixels;
            }
            if (touch.released) {
                var deltaTime = Date.getTime() - _timeTouched;
                if (deltaTime < 1 * 1000)
                {
                    attack();
                }
            }
        }
        #end
    }

    public function attack()
    {
        trace("Attack");
    }
}