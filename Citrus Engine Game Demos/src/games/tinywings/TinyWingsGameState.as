package games.tinywings {

	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	
	import citrus.core.starling.StarlingState;
	import citrus.math.MathVector;
	import citrus.physics.nape.Nape;
	import citrus.view.starlingview.AnimationSequence;
	import citrus.view.starlingview.StarlingArt;
	
	import starling.core.starling_internal;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	/**
	 * @author Aymeric
	 */
	public class TinyWingsGameState extends StarlingState {
		
		[Embed(source="/../embed/1x/heroMobile.xml", mimeType="application/octet-stream")]
		public static const HeroConfig:Class;

		[Embed(source="/../embed/1x/heroMobile.png")]
		public static const HeroPng:Class;
		
		[Embed(source="/../embed/mickey/mickeyrun.xml", mimeType="application/octet-stream")]
		public static const MickeyRunConfig:Class;
		
		[Embed(source="/../embed/mickey/mickeyrun.png")]
		public static const MickeyRunPng:Class;
		
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
			
			var bitmap:Bitmap = new MickeyRunPng();
			var texture:Texture = Texture.fromBitmap(bitmap);
			var xml:XML = XML(new MickeyRunConfig());
			var sTextureAtlas:TextureAtlas = new TextureAtlas(texture, xml);
			var heroAnim:AnimationSequence = new AnimationSequence(sTextureAtlas, ["run"], "run", 11, true);
			StarlingArt.setLoopAnimations(["run"]);
			
			_hero = new BirdHero("hero", {radius:20, view:heroAnim, group:1});
			add(_hero);
			
			_hillsTexture = new HillsTexture();

			var hills:HillsManagingGraphics = new HillsManagingGraphics("hills", 
				{sliceHeight:800, sliceWidth:70, currentYPoint:350, currentXPoint: -10, 
					widthHills: stage.stageWidth + ( stage.stageWidth * 0.3 ), 
					registration:"topLeft", view:_hillsTexture});
			add(hills);

			view.camera.setUp(_hero, new MathVector(stage.stageWidth * 0.20, stage.stageHeight * 0.65), new Rectangle(0, -int.MAX_VALUE, int.MAX_VALUE, int.MAX_VALUE), new MathVector(.5, .5));
			//view.camera.allowZoom = true;
			//view.camera.zoom( 0.5 );

		}
			
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			// update the hills here to remove the displacement made by StarlingArt. Called after all operations done.
			_hillsTexture.update();
		}
	}
}
