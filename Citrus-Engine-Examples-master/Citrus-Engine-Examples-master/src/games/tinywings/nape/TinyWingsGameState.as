package games.tinywings.nape {

	import citrus.core.starling.StarlingState;
	import citrus.math.MathVector;
	import citrus.physics.nape.Nape;
	import citrus.view.starlingview.AnimationSequence;
	import citrus.view.starlingview.StarlingArt;

	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	import flash.display.Bitmap;
	import flash.geom.Rectangle;

	/**
	 * @author Aymeric
	 */
	public class TinyWingsGameState extends StarlingState {
		
		[Embed(source="/../embed/1x/heroMobile.xml", mimeType="application/octet-stream")]
		public static const HeroConfig:Class;

		[Embed(source="/../embed/1x/heroMobile.png")]
		public static const HeroPng:Class;
		
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
			
			var bitmap:Bitmap = new HeroPng();
			var texture:Texture = Texture.fromBitmap(bitmap);
			var xml:XML = XML(new HeroConfig());
			var sTextureAtlas:TextureAtlas = new TextureAtlas(texture, xml);
			var heroAnim:AnimationSequence = new AnimationSequence(sTextureAtlas, ["fly", "descent", "stop", "ascent", "throughPortal", "jump", "ground"], "fly", 30, true);
			StarlingArt.setLoopAnimations(["fly"]);
			
			_hero = new BirdHero("hero", {radius:20, view:heroAnim, group:1});
			add(_hero);
			
			_hillsTexture = new HillsTexture();

			var hills:HillsManagingGraphics = new HillsManagingGraphics("hills", {sliceHeight:200, sliceWidth:70, currentYPoint:350, registration:"topLeft", view:_hillsTexture});
			add(hills);

			view.camera.setUp(_hero, new MathVector(stage.stageWidth /2, stage.stageHeight / 2), new Rectangle(0, 0, int.MAX_VALUE, int.MAX_VALUE), new MathVector(.25, .05));
		}
			
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			// update the hills here to remove the displacement made by StarlingArt. Called after all operations done.
			_hillsTexture.update();
		}
	}
}
