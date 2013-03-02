package {

	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	
	import citrus.core.starling.StarlingState;
	import citrus.math.MathVector;
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.MovingPlatform;
	import citrus.objects.platformer.nape.Platform;
	import citrus.physics.nape.Nape;
	import citrus.view.starlingview.AnimationSequence;
	import citrus.view.starlingview.StarlingArt;
	import citrus.view.starlingview.StarlingView;
	
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
		
		[Embed(source="/../embed/bgLayer1.jpg")]
		private var bgLayer:Class;
		
		private var _nape:Nape;
		private var _hero:MickeyHero;
		
		private var _hillsTexture:HillsTexture;
		
		private var _cameraBounds:Rectangle;
		
		private var _hills:CustomHills;
		
		/** Game background object. */
		private var bg:GameBackground;

		public function TinyWingsGameState() {
			super();
		}

		override public function initialize():void {
			
			super.initialize();

			_nape = new Nape("nape");
			//_nape.visible = true;
			add(_nape);
			
//			var bitmap:Bitmap = new HeroPng();
//			var texture:Texture = Texture.fromBitmap(bitmap);
//			var xml:XML = XML(new HeroConfig());
//			var sTextureAtlas:TextureAtlas = new TextureAtlas(texture, xml);
//			var heroAnim:AnimationSequence = new AnimationSequence(sTextureAtlas, ["fly", "descent", "stop", "ascent", "throughPortal", "jump", "ground"], "fly", 30, true);
//			StarlingArt.setLoopAnimations(["fly"]);
			
			// Draw background.
			bg = new GameBackground("background", null, _hero);
			add(bg);
			
			
			var bitmap:Bitmap = new MickeyPng();
			bitmap.smoothing = TextureSmoothing.BILINEAR;
			var texture:Texture = Texture.fromBitmap(bitmap);
			var xml:XML = XML(new MickeyConfig());
			var sTextureAtlas:TextureAtlas = new TextureAtlas(texture, xml);
			var heroAnim:AnimationSequence = new AnimationSequence(sTextureAtlas, ["slice_", "mickeyjump_", "mickeyjump2_", "mickeythrow_", "mickeypush_"], "slice_", 12, true, "bilinear");
			StarlingArt.setLoopAnimations(["slice_", "mickeypush_"]);
			
			var filter:BlurFilter;// = new BlurFilter(1, 1, 1);
			filter = BlurFilter.createGlow(0x000000);//0x000000, 1, 0.2, 1);
			//filter = BlurFilter.createDropShadow(4, 0, 0x000000, 1, 0, 1);
//			filter.blurX = filter.blurY = 1;
//			filter.setUniformColor(true, 0x000000, 1);
			
			//heroAnim.filter = filter;
			
			_hero = new MickeyHero("hero", {x:stage.stageWidth * 0.2, radius:40, view:heroAnim, group:1});
			add(_hero);
			
			bg.setHero( _hero );
			
			_hillsTexture = new HillsTexture();

			_hills = new HillsManagingGraphics("hills", 
				{rider:_hero, sliceHeight:800, sliceWidth:100, currentYPoint:stage.stageHeight * 0.85, //currentXPoint: 10, 
					widthHills: stage.stageWidth + ( stage.stageWidth * 0.5 ), 
					registration:"topLeft", view:_hillsTexture});
			add(_hills);
			
//			var floor:Platform = new Platform("floor", {x:-100, y:stage.stageHeight - 100, width:5000, height: 250});
//			floor.view = new Quad(5100, 250, 0x00dd11);
//			add(floor);
			
			
			
			_cameraBounds = new Rectangle(0, 0, int.MAX_VALUE, int.MAX_VALUE);

			view.camera.setUp(_hero, new MathVector(stage.stageWidth * 0.20, stage.stageHeight * 0.85), _cameraBounds, new MathVector(1, 0.05));
			view.camera.allowZoom = true;
			
			//view.camera.zoom( 0.1 );

			//stage.addEventListener(TouchEvent.TOUCH, _addObject);
		}
		
		private function _addObject(tEvt:TouchEvent):void {
			
			var touch:Touch = tEvt.getTouch(stage, TouchPhase.BEGAN);
			
			if (touch) {
				
				var image:Image = new Image(Texture.fromBitmap(new _cratePng()));
				
				var physicObject:CrateObject = new CrateObject("physicobject", { x:stage.stageWidth + 100, y:touch.getLocation(this).y, width:35, height:38, view:image} );
				add(physicObject);
			}
			
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
		
		private function addPlatform():void {
			var floor:Platform = new SmallPlatform("floor", {x:_hero.x + stage.stageWidth, y:_hero.y - 50 - ( Math.random() * 200 ), width:300, height: 5}, _hero);
			floor.view = new Quad(300, 5, 0x222222);
			floor.oneWay = true;
			add(floor);
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
			
			if (Math.random() > 0.99) addCrate(false);
//			
			if (Math.random() > 0.99) addPlatform();
			
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
