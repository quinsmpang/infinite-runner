package {
	
	import citrus.core.CitrusEngine;
	
	import games.osmos.OsmosGameState;
	
	[SWF(frameRate="60")]
	
	/**
	 * @author Aymeric
	 */
	public class OsmosCE extends CitrusEngine {
		
		public function OsmosCE() {
			
			state = new OsmosGameState();
		}
	}
}

