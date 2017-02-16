package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
import flixel.util.FlxSave;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;

class PlayState extends FlxState
{
    public var mapLoader:MapLoader;
    public var gridCamera:GridCamera;
    public var player:Player;
    public var canvas:FlxSprite;
    public var saveManager:FlxSave;
    public var entities:FlxGroup;

    override public function create()
    {
        saveManager = new FlxSave();
        saveManager.bind("demo");

        entities = new FlxGroup();
        player = new Player(0, 0);
        mapLoader = new MapLoader(AssetPaths.home__tmx);
        gridCamera = new GridCamera(player, 50, 50, 64, FlxG.camera, 0, 0, 0.75);
        gridCamera.set();
        canvas = new FlxSprite(0, 0);
        canvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
        canvas.scrollFactor.set(0, 0);
        player.canvas = canvas;
        onLoad();

        entities.add(player);

        var skillBtn = new FlxButton(FlxG.width-80, 0, "Skills", function() {
            onSave();
            FlxG.switchState(new SkillState());
        });

        var sheep = new Entity(5*64, 5*64);

        add(mapLoader.backgroundtiles);
        add(mapLoader.nogotiles);
        add(sheep);
        add(player);
        add(canvas);
        add(skillBtn);

		FlxG.worldBounds.set(0, 0, mapLoader.fullWidth, mapLoader.fullHeight);
        super.create();
    }

    override public function update(delta:Float)
    {
        super.update(delta);
        gridCamera.update();
        mapLoader.collideWithLevel(entities);
        if (FlxG.keys.anyPressed([R]))
        {
            onClear();
        }
    }

    public function onSave()
    {
        if (!saveManager.data.player_pos && !saveManager.data.gridcam_pos)
        {
            trace("[-] There's no saved data..");
            trace("[*] Creating new save storage...");
            saveManager.data.player_pos = player.getPosition();
            saveManager.data.gridcam_pos = new FlxPoint(gridCamera.currentGridX, gridCamera.currentGridY);
            saveManager.data.camera_scroll = FlxG.camera.scroll;
            trace("[+] Data created!");
            saveManager.flush();
            trace("[+] Data saved!");
        }
        else {
            trace("[-] There is already saved data...");
            trace("[*] Overwriting...");
            saveManager.data.player_pos = player.getPosition();
            saveManager.data.gridcam_pos = new FlxPoint(gridCamera.currentGridX, gridCamera.currentGridY);
            saveManager.data.camera_scroll = FlxG.camera.scroll;
            saveManager.flush();
            trace("[+] Data saved!");
        }
    }

    public function onLoad()
    {
        if (!saveManager.data.player_pos && !saveManager.data.gridcam_pos)
        {
            trace("[-] There's no saved data..");
        }
        else {
            trace("[+] Data found!");
            player.setPosition(saveManager.data.player_pos.x, saveManager.data.player_pos.y);
            gridCamera.currentGridX = saveManager.data.gridcam_pos.x;
            gridCamera.currentGridY = saveManager.data.gridcam_pos.y;
            FlxG.camera.scroll = saveManager.data.camera_scroll;
            trace("[+] Data loaded!");
        }
    }

    public function onClear()
    {
        saveManager.data.gridcam_pos = null;
        saveManager.data.player_pos = null;
        saveManager.data.camera_scroll = null;
        saveManager.flush();
    }
}