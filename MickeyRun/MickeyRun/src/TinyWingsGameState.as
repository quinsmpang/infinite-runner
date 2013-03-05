package {

	import flash.display.Bitmap;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import citrus.core.starling.StarlingState;
	import citrus.math.MathVector;
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Coin;
	import citrus.objects.platformer.nape.MovingPlatform;
	import citrus.objects.platformer.nape.Platform;
	import citrus.objects.platformer.nape.Sensor;
	import citrus.physics.nape.Nape;
	import citrus.view.starlingview.AnimationSequence;
	import citrus.view.starlingview.StarlingArt;
	import citrus.view.starlingview.StarlingView;
	
	import nape.callbacks.InteractionCallback;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Polygon;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.filters.BlurFilter;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.textures.TextureSmoothing;

	/**
	 * @author Aymeric
	 */
	public class TinyWingsGameState extends StarlingState {
		
//		[Embed(source="/../embed/1x/heroMobile.xml", mimeType="application/octet-stream")]
//		public static const HeroConfig:Class;
//
//		[Embed(source="/../embed/1x/heroMobile.png")]
//		public static const HeroPng:Class;
		
//		[Embed(source="/../embed/mickey/mickeyrun.xml", mimeType="application/octet-stream")]
//		public static const MickeyRunConfig:Class;
//		
//		[Embed(source="/../embed/mickey/mickeyrun.png")]
//		public static const MickeyRunPng:Class;
		
//		[Embed(source="/../embed/mickey/mickeyrunshoebox.xml", mimeType="application/octet-stream")]
//		public static const MickeyRunConfig:Class;
//		
//		[Embed(source="/../embed/mickey/mickeyrunshoebox.png")]
//		public static const MickeyRunPng:Class;
		
		[Embed(source="/../embed/mickey/mickeyall.xml", mimeType="application/octet-stream")]
		public static const MickeyConfig:Class;
		
		[Embed(source="/../embed/mickey/mickeyall.png")]
		public static const MickeyPng:Class;
		
		[Embed(source="/../embed/small_crate.png")]
		private var _cratePng:Class;
		
		[Embed(source="/../embed/large_crate.png")]
		private var _largeCratePng:Class;
		
		[Embed(source="/../embed/coin.png")]
		private var _coinPng:Class;
		
		[Embed(source="/../embed/platform500.png")]
		private var platform500:Class;
		
		private var _nape:Nape;
		private var _hero:MickeyHero;
		
		private var _hillsTexture:HillsTexture;
		
		private var _cameraBounds:Rectangle;
		
		private var _hills:CustomHills;
		
		/** Game background object. */
		private var bg:GameBackground;
		
		private var fg:GameBackground;
		
		private var fallSensor:CustomFallSensor

		public function TinyWingsGameState() {
			super();
		}

		override public function initialize():void {
			
			super.initialize();

			_nape = new Nape("nape");
			//_nape.visible = true;
			//_nape.gravity.y -= 200;
			add(_nape);
			
//			var bitmap:Bitmap = new HeroPng();
//			var texture:Texture = Texture.fromBitmap(bitmap);
//			var xml:XML = XML(new HeroConfig());
//			var sTextureAtlas:TextureAtlas = new TextureAtlas(texture, xml);
//			var heroAnim:AnimationSequence = new AnimationSequence(sTextureAtlas, ["fly", "descent", "stop", "ascent", "throughPortal", "jump", "ground"], "fly", 30, true);
//			StarlingArt.setLoopAnimations(["fly"]);
			
//			// Draw background.
//			bg = new GameBackground("background", null, _hero, true);
//			add(bg);
			
			
			var bitmap:Bitmap = new MickeyPng();
			//bitmap.smoothing = TextureSmoothing.BILINEAR;
			var texture:Texture = Texture.fromBitmap(bitmap, true, false, 1);
			var xml:XML = XML(new MickeyConfig());
			var sTextureAtlas:TextureAtlas = new TextureAtlas(texture, xml);
			var heroAnim:AnimationSequence = new AnimationSequence(sTextureAtlas, ["slice_", "mickeyjump2_", "mickeythrow_", "mickeypush_"], "slice_", 18, true, "none");
			StarlingArt.setLoopAnimations(["slice_", "mickeypush_"]);
			
//			var filter:BlurFilter;// = new BlurFilter(1, 1, 1);
//			filter = BlurFilter.createGlow(0x000000);//0x000000, 1, 0.2, 1);
			//filter = BlurFilter.createDropShadow(4, 0, 0x000000, 1, 0, 1);
//			filter.blurX = filter.blurY = 1;
//			filter.setUniformColor(true, 0x000000, 1);
			
//			heroAnim.filter = filter;
			
			_hero = new MickeyHero("hero", {x:stage.stageWidth * 0.2, radius:40, view:heroAnim, group:1});
			add(_hero);
			
			bg = new GameBackground("background", null, _hero, true);
			add(bg);
			
//			bg.setHero( _hero );
			
			_hillsTexture = new HillsTexture();
			
//			fallSensor = new CustomFallSensor("fallSensor", {x:_hero.x, y: stage.stageHeight * 0.85, width:stage.stageWidth + ( stage.stageWidth * 0.5 ),
//				height: 20}, _hero);
//			fallSensor.view = new Quad( fallSensor.width, fallSensor.height, 0x00dd11);
//			fallSensor.onBeginContact.add(_fallSensorTouched);
//			add( fallSensor );
			
			// small safety platform that follows Mickey
//			var fallSensor:CustomPlatform = new CustomPlatform("fallSensor", {x:_hero.x, y: stage.stageHeight * 0.85, width:400,
//				height: 20}, _hero);
//			fallSensor.view = new Quad( fallSensor.width, fallSensor.height, 0x88dd11);
//			//fallSensor.onBeginContact.add(_fallSensorTouched);
//			add( fallSensor );
				

			_hills = new HillsManagingGraphics("hills", 
				{rider:_hero, sliceHeight:30, sliceWidth:200, currentYPoint:stage.stageHeight * 0.85, //currentXPoint: 10, 
					widthHills: stage.stageWidth + ( stage.stageWidth * 0.5 ), 
					registration:"topLeft", view:_hillsTexture});
			add(_hills);
			
//			var floor:Platform = new Platform("floor", {x:-100, y:stage.stageHeight - 100, width:5000, height: 250});
//			floor.view = new Quad(5100, 250, 0x00dd11);
//			add(floor);
			
			// Draw background.
//			fg = new GameBackground("foreground", null, _hero, false);
//			add(fg);
//			
//			fg.setHero( _hero );
			
//			_cameraBounds = new Rectangle(0, -500, int.MAX_VALUE, int.MAX_VALUE);
			
			_cameraBounds = new Rectangle(0, -1500, int.MAX_VALUE, int.MAX_VALUE);

			view.camera.setUp(_hero, new MathVector(stage.stageWidth * 0.05, stage.stageHeight * 0.6), _cameraBounds, new MathVector(0.05, 0.05));
			view.camera.allowZoom = true;
			
			
			
			var downTimer:Timer = new Timer( 1200 );
			downTimer.addEventListener( TimerEvent.TIMER, handleTimeEvent );
			downTimer.start();
			
//			view.camera.zoom( 1.2 );
			
			//view.camera.zoomFit( stage.stageWidth, stage.stageHeight );

			//stage.addEventListener(TouchEvent.TOUCH, _addObject);
			
//			addPlatform( stage.stageWidth, stage.stageWidth * 2 );
		}
		
		private function _fallSensorTouched(callback:InteractionCallback):void
		{
			trace( "Hero fell down!" );
			_hero.y -= 800; // temp reset
			_hero.x += 500;
			
		}
		
		protected function handleTimeEvent(event:TimerEvent):void
		{
			addPlatform();
			//addCrate( true );
			
		}
		
		private function _addObject(tEvt:TouchEvent):void {
			
			var touch:Touch = tEvt.getTouch(stage, TouchPhase.BEGAN);
			
			if (touch) {
				
				var image:Image = new Image(Texture.fromBitmap(new _cratePng()));
				
				var physicObject:CrateObject = new CrateObject("physicobject", { x:stage.stageWidth + 100, y:touch.getLocation(this).y, width:35, height:38, view:image} );
				add(physicObject);
			}
			
		}
		
		private function addCurvedPlatform():void {
			
		}
		
		private function addCrate(addSmallCrate:Boolean):void {
			var image:Image;
			var width:int; var height:int;
			
			if ( addSmallCrate ) {
				image = new Image(Texture.fromBitmap(new _cratePng()));
				width = 35; height = 38;
			} else {
				image = new Image(Texture.fromBitmap(new _largeCratePng()));
				width = 70; height = 76;
			}
			
			var physicObject:CrateObject = new CrateObject("physicobject", { x:_hero.x + stage.stageWidth, y:_hero.y - 100, width:width, height:height, view:image}, _hero );
			add(physicObject);	
		}
		
		private function addCoin( coinX:int, coinY:int ):void {
			var image:Image;
			var width:int; var height:int;
			
			image = new Image(Texture.fromBitmap(new _coinPng()));
			width = 40; height = 40;

			var physicObject:Coin = new CustomCoin("physicobject", { x:coinX, y:coinY, width:width, height:height, view:image}, _hero );
			add(physicObject);	
		}
		
		private var platformY:int = 0;
		private function addPlatform( platformX:int=0, platWidth:int=0 ):void {
			var platformWidth:int = platWidth > 0 ? platWidth : 500;//Math.random() * 400 + 300;
			var floor:Platform = new SmallPlatform("floor", {x:_hero.x + stage.stageWidth - platformX, y:stage.stageHeight * 0.7 - platformY - ( Math.random() * 200 ), 
				width:platformWidth, height: 30}, _hero);
			floor.view = platformWidth == 500 ? new Image(Texture.fromBitmap(new platform500())) : new Quad(platformWidth, 30, 0xF09732);
			floor.oneWay = true;
			add(floor);
			
			platformY += Math.random() * 50;
			
			if ( floor.y < _hero.y - 700 ) platformY = 0;
			
			var coinX:int = floor.x - floor.width/2;
			addCoin( coinX + 100, floor.y - 50 );
			addCoin( coinX + 200, floor.y - 50 );
			addCoin( coinX + 300, floor.y - 50 );
		}
		
		private function addMovingPlatform():void {
			var floor:Platform = new SmallMovingPlatform("floor", 
				{x:_hero.x + stage.stageWidth, y:_hero.y - 100, width:200,
					startX:_hero.x + stage.stageWidth, startY:300, endX: _hero.x, endY:500, height: 5}, _hero);
			floor.view = new Quad(200, 5, 0x1158D4);
			//floor.oneWay = true;
			add(floor);
		}
		
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			// update the hills here to remove the displacement made by StarlingArt. Called after all operations done.
			_hillsTexture.update();
			
//			var aa:int;
//			
//			aa = view.camera.camPos.x;
//			aa = view.camera.camPos.y;
//			aa = view.camera.cameraLensWidth;
//			aa = view.camera.cameraLensHeight;
			
//			if (Math.random() > 0.99) addCrate(false);
//			
//			if (Math.random() > 0.99) addPlatform();
			
//			if (_cameraBounds.y < _hills.currentYPoint - 590) {
//				_cameraBounds.y += 3;
//			} else if ( _cameraBounds.y > _hills.currentYPoint - 610 ) {
//				_cameraBounds.y -= 3;
//			}
			//view.camera.bounds = _cameraBounds;
			// Set the background's speed based on hero's speed.
			//bg.speed = _hero.velocity.x;
//			bg.y = _hero.y;
//			bg.x = _hero.x;
		}
	}
}
