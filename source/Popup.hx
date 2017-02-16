package;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.ui.FlxButton;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;

#if android
import Hardware;
#end

class Popup extends FlxSubState
{
    private var _acceptAct:Void->Void;
    private var _refuseAct:Void->Void;

    public static var opened:Bool;

    override public function new(twoBtns:Bool, title:String, text:String, acceptAct:Void->Void, refuseAct:Void->Void)
    {
        super();

        var fadingbg = new FlxSprite(0, 0);
        fadingbg.makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(0,0,0,200));
        fadingbg.scrollFactor.set(0, 0);
        add(fadingbg);

        var background = new FlxSprite(160-100, 256-150);
        background.loadGraphic(AssetPaths.popup__png, false, 200, 300);
        background.scrollFactor.set(0, 0);
        add(background);

        var flxtitle = new FlxText(160-100, 256-140, 200, title, 16, true);
        flxtitle.antialiasing = false;
        flxtitle.alignment = "center";
        flxtitle.scrollFactor.set(0, 0);
        add(flxtitle);

        var desc = new FlxText(160-100+10, 256-150+50, 180, text, 8, true);
        desc.antialiasing = false;
        desc.setFormat(null, 8, FlxColor.BLACK, "left", FlxTextBorderStyle.NONE, FlxColor.BLACK, true);
        desc.scrollFactor.set(0, 0);
        add(desc);

        _acceptAct = acceptAct;
        _refuseAct = refuseAct;

        if (twoBtns)
        {
            var _refuseBtn = new FlxButton(160-100+14, 256-150+300-30, "Refuse", refuseAction);
            add(_refuseBtn);
            var _acceptBtn = new FlxButton(160-100+28+80, 256-150+300-30, "Accept", acceptAction);
            add(_acceptBtn);
        } else {
            var _acceptBtn = new FlxButton(100-40+160-100, 256-150+300-30, "Accept", acceptAction);
            add(_acceptBtn);
        }
    }

    public function refuseAction()
    {
        #if android
        Hardware.vibrate(25);
        #end
        if (_refuseAct != null)
            _refuseAct();
        close();
    }

    public function acceptAction()
    {
        #if android
        Hardware.vibrate(25);
        #end
        if (_acceptAct != null)
            _acceptAct();
        close();
    }
}