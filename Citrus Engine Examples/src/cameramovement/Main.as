package cameramovement {
	
	import cameramovement.CameraMovement;

	import citrus.core.starling.StarlingCitrusEngine;
	
	import flash.display.Sprite;

	[SWF(frameRate="60",width="800", height="600")]
	
	public class Main extends StarlingCitrusEngine {
		
		//this will be the flash debug sprite for the camera.
		public var debugSpriteRectangle:Sprite = new Sprite();
		
		public function Main() {
			
			addChild(debugSpriteRectangle);
			
			setUpStarling(true, 1);
			
			state = new CameraMovement(debugSpriteRectangle);
		}
	}
}
