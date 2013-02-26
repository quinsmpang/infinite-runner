package 
{
	import com.citrusengine.core.CitrusEngine;
	
	[SWF(backgroundColor="#000000", frameRate="60")]
	/**
	 * ...
	 * @author Aymeric
	 */
	public class Main extends CitrusEngine 
	{
		
		public function Main():void 
		{
			setUpStarling(true);
			
			state = new NapeStarlingGameState();
		}
	}
	
}