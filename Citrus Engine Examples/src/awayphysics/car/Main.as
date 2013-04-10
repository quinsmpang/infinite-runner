package awayphysics.car {
	
	import awayphysics.car.CarGameState;

	import citrus.core.away3d.Away3DCitrusEngine;

	[SWF(frameRate="60")]

	/**
	* @author Aymeric
	*/
	public class Main extends Away3DCitrusEngine {

		public function Main() {
			
			setUpAway3D(true);
			
			state = new CarGameState();
		}
	}
}