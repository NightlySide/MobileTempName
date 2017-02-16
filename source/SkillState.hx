package;

import tjson.TJSON;
import openfl.Assets;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

#if android
import Hardware;
#end

using flixel.util.FlxSpriteUtil;

class SkillState extends FlxState
{
    public static var needsUpdate = false;
    public var sknodes:SkillLoader;
    public var canvas:FlxSprite;

    private var _mousePos:FlxPoint;
    private var _cameraScroll:FlxPoint;

    override public function create():Void
	{
        sknodes = new SkillLoader(AssetPaths.skillnodes__json, this);
        add(sknodes.canvas);

        for (node in sknodes.skillnodes)
        {
            add(node);
        }
        for (text in sknodes.skillnames)
            add(text);

        sknodes.findNodeFromID(0).setState("active");
        sknodes.updateNodes();

        var closeBtn = new FlxButton(FlxG.width-80, 0, "Close", function() {FlxG.switchState(new PlayState());});
        add(closeBtn);

        FlxG.camera.setScrollBoundsRect(0, 0, sknodes.width, sknodes.height);
		FlxG.worldBounds.set(0, 0, sknodes.width, sknodes.height);
        super.create();
    }

    override public function update(delta:Float)
    {
        if (needsUpdate)
        {
            sknodes.updateNodes();
            needsUpdate = false;
        }
        #if desktop
        if (FlxG.mouse.justPressed){
            _mousePos = FlxG.mouse.getWorldPosition(FlxG.camera);
            _cameraScroll = FlxG.camera.scroll;
        }
        if (FlxG.mouse.pressed){
            var mousePosChange:FlxPoint = FlxG.mouse.getWorldPosition(FlxG.camera).subtractPoint(_mousePos);
            FlxG.camera.scroll.subtractPoint(mousePosChange);
        }
        #end

        #if android
        for (touch in FlxG.touches.list)
        {
            if (touch.justPressed) {
                _mousePos = new FlxPoint(touch.x, touch.y);
                _cameraScroll = FlxG.camera.scroll;
            }
            if (touch.pressed) {
                var mousePosChange:FlxPoint = new FlxPoint(touch.x, touch.y).subtractPoint(_mousePos);
                FlxG.camera.scroll.subtractPoint(mousePosChange);
            }
        }
        #end

        super.update(delta);
    }
}

class SkillLoader {
    public var skillnodes:Array<SkillNode>;
    public var skillnames:Array<FlxText>;
    public var canvas:FlxSprite;
    public var lines:Array<FlxSprite>;
    public var width:Float;
    public var height:Float;

    private var _nodeOffset = 32;

    public function new(nodespath:String, context:FlxState)
    {
        skillnodes = new Array<SkillNode>();
        skillnames = new Array<FlxText>();
        lines = new Array<FlxSprite>();

        var json = TJSON.parse(Assets.getText(nodespath));
        var data:Array<Dynamic> = json.data;
        var maxX:Array<Int> = json.maxX;
        var maxY:Array<Int> = json.maxY;
        var offset = 2;
        var zero = new FlxPoint(Math.abs(Std.int((maxX[1]-maxX[0])/2))+offset, Math.abs(Std.int((maxY[1]-maxY[0])/2))+offset);
        
        width = (Math.abs(maxX[1]-maxX[0])+2*offset) * (64+2*_nodeOffset);
        height = (Math.abs(maxY[1]-maxY[0])+2*offset) * (64+2*_nodeOffset);

        canvas = new FlxSprite();
        canvas.makeGraphic(Std.int(width), Std.int(height), FlxColor.BLACK, true);
        
        for (node in data) {
            var position:Array<Int> = node.pos;
            var realPos = new FlxPoint((64+_nodeOffset)*(position[0]+zero.x), (64+_nodeOffset)*(position[1]+zero.y));
            
            var sknode = new SkillNode(node.id, realPos.x, realPos.y, node.sprite, context);
            sknode.parents = node.parents;
            sknode.name = node.name;
            
            var text = new FlxText((64+_nodeOffset)*(position[0]+zero.x), (64+_nodeOffset)*(position[1]+zero.y+1)-_nodeOffset, 64, node.name, 8, true);
            text.alignment = "center";

            skillnodes.push(sknode);
            skillnames.push(text);
        }

        for (node in skillnodes)
        {
            for (parent in node.parents)
            {
                var parent_node:SkillNode = findNodeFromID(parent);
                if (parent_node != null)
                {
                    var pos = node.getMidpoint();
                    var ppos = parent_node.getMidpoint();
                    var line = canvas.drawLine(pos.x, pos.y, ppos.x, ppos.y, { color: FlxColor.RED, thickness: 3 });
                    lines.push(line);
                }
            }
        }
    }

    public function updateNodes()
    {
        for (node in skillnodes)
        {
            if (node.state == "locked")
            {
                var unlocked = true;
                for (parent in node.parents)
                {
                    var pnode = findNodeFromID(parent);
                    if (pnode.state != "active")
                        unlocked = false;
                }
                if (unlocked)
                    node.setState("unlocked");
            }
        }
    }

    public function findNodeFromID(id:Int)
    {
        for (node in skillnodes)
            if (node.id == id)
                return node;
        return null;
    }
}

class SkillNode extends FlxSprite {

    public var parents:Array<Int>;
    public var name:String;
    public var id:Int;
    public var state:String = "locked";

    private var _clicked:Bool = false;
    private var _context:FlxState;

    override public function new(ID:Int, X:Float, Y:Float, graphic:String, context:FlxState)
    {
        super(X, Y);

        id = ID;
        loadGraphic(graphic, true, 64, 64);
        animation.add("active",     [0], false);
        animation.add("unlocked",   [1], false);
        animation.add("locked",     [2], false);
        setState(state);

        parents = new Array<Int>();
        _context = context;
        FlxMouseEventManager.add(this, null, onReleased, onTouchOver, null);
    }

    public function setState(newstate:String)
    {
        state = newstate;
        animation.play(newstate);
    }
    
    public function onReleased(sprite:FlxSprite)
    {
        if (state == "locked")
            _context.openSubState(new Popup(false, "Locked", "You can't unlock this skill : "+name+", until you've unlocked the others!", null, null));
        else if (state != "active")
            _context.openSubState(new Popup(true, "Skill buying", "Do you want to buy this skill? \n("+name+")", unlock, null));
    }

    public function unlock()
    {
        setState("active");
        SkillState.needsUpdate = true;
    }

    public function onTouchOver(sprite:FlxSprite) {
        #if android
            Hardware.vibrate(25);
            onReleased(sprite);
        #end
    }
}