package groupobjects {

	import citrus.core.starling.StarlingCitrusEngine;

	import groupobjects.GroupGameState;

	[SWF(frameRate="60")]

	/**
	* @author Aymeric
	*/
	public class Main extends StarlingCitrusEngine {

		public function Main() {

			setUpStarling(true);

			state = new GroupGameState();
		}
	}
}