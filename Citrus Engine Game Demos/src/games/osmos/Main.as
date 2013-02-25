package games.osmos {

	import citrus.core.CitrusEngine;

	[SWF(frameRate="60")]
	
	/**
	 * @author Aymeric
	 */
	public class Main extends CitrusEngine {
		
		public function Main() {
			
			state = new OsmosGameState();
		}
	}
}
