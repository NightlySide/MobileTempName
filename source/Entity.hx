package;

import flixel.FlxSprite;
import flixel.addons.util.FlxFSM;
import flixel.addons.util.FlxFSM.FlxFSMState;
import flixel.FlxG;
import flixel.math.FlxPoint;

class Entity extends FlxSprite
{
    public var fsm:FlxFSM<Entity>;
    public var age:Float = 0;
    public var isMoving:Bool = false;
    public var maxIdleTime:Float = 5;
    public var maxMovingDistance:Float = 3 * 64;
    public var speed:Float = 20 * 64;

    override public function new(X:Float=0, Y:Float=0)
    {
        super(X, Y);
        loadGraphic(AssetPaths.entity__png, false, 64, 64);
        fsm = new FlxFSM<Entity>(this);
        fsm.transitions.add(Idle, Move, Conditions.wait)
                       .add(Move, Idle, Conditions.finishMoving)
                       .start(Idle);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        age += elapsed;
        fsm.update(elapsed);
    }
}

class Conditions
{
    public static function wait(entity:Entity):Bool
    {
        if (FlxG.random.int(0, 1500) == 50)
            return true;
        return (entity.fsm.age > entity.maxIdleTime);
    }

    public static function finishMoving(entity:Entity):Bool
    {
        return !entity.isMoving;
    }
}

class Idle extends FlxFSMState<Entity>
{
    override public function enter(entity:Entity, fsm:FlxFSM<Entity>)
    {
        // Play corresponding animation
        fsm.age = 0;
        trace("Goind idle...");
    }

    override public function update(elapsed:Float, entity:Entity, fsm:FlxFSM<Entity>)
    {
        
    }
}

class Move extends FlxFSMState<Entity>
{
    public var target:FlxPoint;

    override public function enter(entity:Entity, fsm:FlxFSM<Entity>)
    {
        trace("Moving...");
        // Play corresponding animation
        var sprPos = entity.getMidpoint();
        var new_x = sprPos.x + entity.maxMovingDistance * FlxG.random.float(-1, 1);
        var new_y = sprPos.y + entity.maxMovingDistance * FlxG.random.float(-1, 1);
        new_x = Utils.clamp(new_x, 0, FlxG.width);
        new_y = Utils.clamp(new_y, 0, FlxG.height);
        target = new FlxPoint(new_x, new_y);
        entity.isMoving = true;
    }

    override public function update(elapsed:Float, entity:Entity, fsm:FlxFSM<Entity>)
    {
        var distance = entity.getMidpoint().distanceTo(target);
        entity.velocity.set(0, 0);

        if (distance < 10/100 * 64)
        {
            trace("Near target");
            entity.isMoving = false;
        }
        else {
            var dir = new FlxPoint(target.x, target.y);
            dir.subtractPoint(entity.getMidpoint());
            var speedPerSec = entity.speed * elapsed;
            entity.velocity.x = dir.x / distance * speedPerSec;
            entity.velocity.y = dir.y / distance * speedPerSec;
        }
    }
}