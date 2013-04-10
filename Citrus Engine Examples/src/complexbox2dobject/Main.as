package complexbox2dobject {

	import citrus.core.CitrusEngine;
	
	import complexbox2dobject.ComplexBox2DObjectGameState;

	[SWF(frameRate="60")]

	/**
	* @author Aymeric
	*/
	public class Main extends CitrusEngine {

		public function Main() {

			state = new ComplexBox2DObjectGameState();
		}
	}
}