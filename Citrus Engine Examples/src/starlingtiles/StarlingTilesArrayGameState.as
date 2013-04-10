package starlingtiles 
{

	import citrus.core.starling.StarlingState;
	import citrus.math.MathVector;
	import citrus.objects.Box2DPhysicsObject;
	import citrus.objects.CitrusSprite;
	import citrus.objects.platformer.box2d.Hero;
	import citrus.objects.platformer.box2d.Platform;
	import citrus.objects.platformer.box2d.Sensor;
	import citrus.physics.box2d.Box2D;
	import citrus.utils.objectmakers.ObjectMaker2D;
	import citrus.view.starlingview.StarlingTileSystem;

	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.textures.Texture;

	import org.osflash.signals.Signal;

	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	
	/**
	 * @author Nick Pinkham
	 */
	public class StarlingTilesArrayGameState extends StarlingState 
	{
		[Embed(source="../../embed/crate.png")]
		private var _cratePng:Class;
		
		[Embed(source = "../../embed/hero_static.png")]
		private var _heroPng:Class;
		
		
		public var lvlEnded:Signal;
		public var restartLevel:Signal;
		
		protected var _level:MovieClip;
		
		private var _hero:Hero;
		
		public function StarlingTilesArrayGameState(level:MovieClip = null) 
		{
			super();
			
			_level = level;
			
			lvlEnded = new Signal();
			restartLevel = new Signal();
			
			// Useful for not forgetting to import object from the Level Editor
			var objectsUsed:Array = [Hero, Platform, Sensor, CitrusSprite];
		}
 
		override public function initialize():void {
 
			super.initialize();
			
			var box2d:Box2D = new Box2D("box2d");
			box2d.visible = false;
			add(box2d);
			
			// create objects from our level made with Flash Pro
			ObjectMaker2D.FromMovieClip(_level);
			
			// the hero view from sprite sheet
			var heroBitmap:Bitmap = new _heroPng();
			var heroImage:Image = Image.fromBitmap(heroBitmap);
			
			// get hero from movieclip
			_hero = Hero(getFirstObjectByType(Hero));
			_hero.view = heroImage;
			
			// setup camera to follow hero
			view.camera.setUp(_hero, new MathVector(400, 300), new Rectangle(0, 0, 4096, 1024), new MathVector(0.25, 0.15));
			
			
			// bitmaps in array converted to tiles
			var tileSprite:CitrusSprite = new CitrusSprite("tile_bg_sprite_0", { x:0, y:0, parallaxX:0.6, parallaxY:0.6 } );
			var tiles:Array = MyTiles.tile_0;
			var tileSystem:StarlingTileSystem = new StarlingTileSystem(tiles);
			
			tileSystem.parallax = 0.6;
			tileSystem.name = "tile_bg_tiles_0";
			tileSystem.blendMode = BlendMode.NONE;
			tileSystem.touchable = false;
			tileSystem.init();
			
			tileSprite.view = tileSystem;
			tileSprite.group = 0;
			add(tileSprite);
			
			
			if (Starling.current.context.driverInfo.toLowerCase().search("software") < 0) {
				
				// add upper background
				tileSprite = new CitrusSprite("tile_bg_sprite_1", { x:0, y:0, parallaxX:0.8, parallaxY:0.8 } );
				tiles = MyTiles.tile_1;
				tileSystem = new StarlingTileSystem(tiles);
				
				tileSystem.parallax = 0.8;
				tileSystem.name = "tile_bg_tiles_1";
				tileSystem.touchable = false;
				tileSystem.init();
				
				tileSprite.view = tileSystem;
				tileSprite.group = 1;
				add(tileSprite);
				
			}
			
			// add top plane tiles via flash stage
			tileSprite = new CitrusSprite("tile_bg_sprite_2", { x:0, y:0 } );
			tiles = MyTiles.tile_2;
			tileSystem = new StarlingTileSystem(tiles);
			
			tileSystem.name = "tile_bg_tiles_2";;
			tileSystem.touchable = false;
			tileSystem.init();
			
			tileSprite.view = tileSystem;
			tileSprite.group = 2;
			add(tileSprite);
			
			// if software mode, only drops 1 box. if full gpu drops 10 boxes.
			if (Starling.current.context.driverInfo.toLowerCase().search("software") < 0) {
				var texture:Texture = Texture.fromBitmap(new  _cratePng());
				var image:Image;
				var physicObject:Box2DPhysicsObject;
				for (var i:uint = 0; i < 10; i++ ) {
					image = new Image(texture);
					physicObject = new Box2DPhysicsObject(("physicobject" + i), { x:Math.random() * stage.stageWidth, y:Math.random() * 300, width:60, height:60, view:image } );
					physicObject.group = 3;
					add(physicObject);
				}

			} else {
				var texture1:Texture = Texture.fromBitmap(new _cratePng());
				var image1:Image = new Image(texture1);
				var physicObject1:Box2DPhysicsObject = new Box2DPhysicsObject("physicobject", { x:Math.random() * stage.stageWidth, y:0, width:60, height:60, view:image1 } );
				physicObject1.group = 3;
				add(physicObject1);
			}
		}		
		
		override public function destroy():void {
			super.destroy();
		}
 
	}
 
}