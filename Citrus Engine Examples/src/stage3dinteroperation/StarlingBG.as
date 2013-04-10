package stage3dinteroperation {

	import starling.display.Image;
	import starling.display.Sprite;

	/**
	 * @author Aymeric
	 */
	public class StarlingBG extends Sprite {
		
		[Embed(source="/../embed/1x/yellowBackground.png")]
		private var backgroundPNG:Class;

		public function StarlingBG() {
			
			addChild(Image.fromBitmap(new backgroundPNG()));
		}
	}
}
