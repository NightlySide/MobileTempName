package;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledMap;
// import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import haxe.io.Path;

class MapLoader extends TiledMap
{

	public var nogotiles:FlxTilemap;
	public var backgroundtiles:FlxTilemap;

	public function new(data:FlxTiledMapAsset)
	{
		super(data);

		nogotiles = new FlxTilemap();
		backgroundtiles = new FlxTilemap();

		trace("[*] Map loading ...");

		for (layer in layers)
		{
			if (layer.type == TiledLayerType.TILE)
			{
				var tileLayer:TiledTileLayer = cast layer;

				var tileSetName:String = tileLayer.properties.get("tileset");
				trace("[+] Tile layer detected : "+tileLayer.name);
				var tileSet:TiledTileSet = getTileSet(tileSetName);
				var imagePath:Path = new Path(tileSet.imageSource);
				var processedPath:String = "assets/images/" + imagePath.file + "." + imagePath.ext;

				if (tileLayer.name == "Background")
				{
					trace("[ ] It was a background");
					backgroundtiles.width = width;
					backgroundtiles.height = height;
					backgroundtiles.loadMapFromCSV(tileLayer.csvData, processedPath, tileSet.tileWidth, tileSet.tileHeight, null, 1, 1, 1);
				} else if (tileLayer.name == "Colliding") {
					trace("[ ] It was collision tiles");
					nogotiles.width = width;
					nogotiles.height = height;
					nogotiles.loadMapFromCSV(tileLayer.csvData, processedPath, tileSet.tileWidth, tileSet.tileHeight, null, 1, 1, 1);
				}
			}
			else if (layer.type == TiledLayerType.OBJECT)
			{
				// var objectLayer:TiledObjectLayer = cast layer;
				// Continue code for object Layer
			}
		}
		trace("[+] Map successfully loaded");
	}

	public function collideWithLevel(obj:FlxGroup, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool
	{
		if (nogotiles != null)
		{
			return FlxG.overlap(nogotiles, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate);
		}
		return false;
	}

}