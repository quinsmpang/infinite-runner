package starlingdemo {

	import citrus.core.starling.StarlingCitrusEngine;
	
	import starlingdemo.StarlingDemoGameState;

	[SWF(frameRate="60")]

	/**
	* @author Aymeric
	*/
	public class Main extends StarlingCitrusEngine {

		public function Main() {

			setUpStarling(true);
			
			sound.addSound("Hurt", "sounds/hurt.mp3");
			sound.addSound("Kill", "sounds/kill.mp3");

			state = new StarlingDemoGameState();
		}
	}
}