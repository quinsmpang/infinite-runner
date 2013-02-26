package games.tinywings {

	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	
	import citrus.core.starling.StarlingCitrusEngine;
	import citrus.core.starling.StarlingState;
	import citrus.math.MathVector;
	import citrus.objects.NapePhysicsObject;
	import citrus.physics.nape.Nape;
	import citrus.view.starlingview.AnimationSequence;
	import citrus.view.starlingview.StarlingArt;
	
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.textures.TextureSmoothing;

	/**
	 * @author Aymeric
	 */
	public class TinyWingsGameState extends StarlingState {
		
		[Embed(source="/../embed/1x/heroMobile.xml", mimeType="application/octet-stream")]
		public static const HeroConfig:Class;

		[Embed(source="/../embed/1x/heroMobile.png")]
		public static const HeroPng:Class;
		
//		[Embed(source="/../embed/mickey/mickeyrun.xml", mimeType="application/octet-stream")]
//		public static const MickeyRunConfig:Class;
//		
//		[Embed(source="/../embed/mickey/mickeyrun.png")]
//		public static const MickeyRunPng:Class;
		
		[Embed(source="/../embed/mickey/mickeyrunshoebox.xml", mimeType="application/octet-stream")]
		public static const MickeyRunConfig:Class;
		
		[Embed(source="/../embed/mickey/mickeyrunshoebox.png")]
		public static const MickeyRunPng:Class;
		
		[Embed(source="/../embed/mickey/mickeyall.xml", mimeType="application/octet-stream")]
		public static const MickeyConfig:Class;
		
		[Embed(source="/../embed/mickey/mickeyall.png")]
		public static const MickeyPng:Class;
		
		[Embed(source="/../embed/small_crate.png")]
		private var _cratePng:Class;
		
		private var _nape:Nape;
		private var _hero:BirdHero;
		
		private var _hillsTexture:HillsTexture;

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
			
			var bitmap:Bitmap = new MickeyPng();
			bitmap.smoothing = TextureSmoothing.BILINEAR;
			var texture:Texture = Texture.fromBitmap(bitmap);
			var xml:XML = XML(new MickeyConfig());
			var sTextureAtlas:TextureAtlas = new TextureAtlas(texture, xml);
			var heroAnim:AnimationSequence = new AnimationSequence(sTextureAtlas, ["slice_", "mickeyjump_", "mickeyjump2_", "mickeythrow_"], "slice_", 12, true, "bilinear");
			StarlingArt.setLoopAnimations(["slice_"]);
			
			_hero = new BirdHero("hero", {radius:20, view:heroAnim, group:1});
			add(_hero);
			
			_hillsTexture = new HillsTexture();

			var hills:HillsManagingGraphics = new HillsManagingGraphics("hills", 
				{sliceHeight:800, sliceWidth:70, currentYPoint:350, //currentXPoint: 10, 
					widthHills: stage.stageWidth + ( stage.stageWidth * 0.3 ), 
					registration:"topLeft", view:_hillsTexture});
			add(hills);

			view.camera.setUp(_hero, new MathVector(stage.stageWidth * 0.30, stage.stageHeight * 0.5), new Rectangle(0, 0, int.MAX_VALUE, int.MAX_VALUE), new MathVector(.5, .5));
			view.camera.allowZoom = true;
			view.camera.zoom( 0.8 );

			//stage.addEventListener(TouchEvent.TOUCH, _addObject);
		}
		
		private function _addObject(tEvt:TouchEvent):void {
			
			var touch:Touch = tEvt.getTouch(stage, TouchPhase.BEGAN);
			
			if (touch) {
				
				var image:Image = new Image(Texture.fromBitmap(new _cratePng()));
				
				var physicObject:NapePhysicsObject = new NapePhysicsObject("physicobject", { x:_hero.x + 600, y:touch.getLocation(this).y, width:35, height:38, view:image} );
				add(physicObject);
			}
			
		}
		
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			// update the hills here to remove the displacement made by StarlingArt. Called after all operations done.
			_hillsTexture.update();
		}
	}
}
