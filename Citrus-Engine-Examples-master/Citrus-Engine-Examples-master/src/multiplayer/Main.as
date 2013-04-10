package multiplayer {

	import citrus.core.starling.StarlingCitrusEngine;

	[SWF(frameRate="60")]

	/**
	* @author Aymeric
	*/
	public class Main extends StarlingCitrusEngine {

		public function Main() {
			
			// for good references on multiplayer
			// https://developer.valvesoftware.com/wiki/Source_Multiplayer_Networking
			// http://gafferongames.com/game-physics/networked-physics/

			setUpStarling(true);

			state = new MultiPlayerGameState();
		}
	}
}