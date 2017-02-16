package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.math.FlxPoint;

class MenuState extends FlxState
{
    override public function create()
    {
        super.create();

        var offset = new FlxPoint(40, FlxG.height/2);

        var playBtn = new FlxButton(offset.x, offset.y, "", newGame);
		playBtn.setGraphicSize(FlxG.width-80, 40);
		playBtn.updateHitbox();
		playBtn.label = new FlxText(0, 4, playBtn.width, "Play the Game");
        playBtn.label.setFormat(null, 16, 0x333333, "center");
		playBtn.label.offset.set(0, -6);
		add(playBtn);
    }

    public function newGame()
    {
        FlxG.switchState(new SkillState());
    }
}