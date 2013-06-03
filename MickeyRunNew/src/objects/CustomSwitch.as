package objects
{
	import citrus.core.CitrusEngine;
	import citrus.core.CitrusObject;
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Sensor;
	
	import nape.callbacks.InteractionCallback;
	
	import starling.display.Image;
	
	public class CustomSwitch extends Sensor
	{	
		private var _context:GameContext = null;
		private var switchOff:Image;
		private var switchOn:Image;
		
		private var _doorId:String;
		
		private var springAnimCount:int = 0;
		
		public function CustomSwitch(name:String, params:Object=null,
									 context:GameContext=null, doorId:String=null )
		{
			switchOff = new Image( Assets.getMiscAtlas().getTexture("switch") );
			switchOn = new Image( Assets.getMiscAtlas().getTexture("switch2") );
			
			_doorId = doorId;
			
			super(name, params);
			this._context = context;
			this.view = switchOff;
			
			// sensor handler
			onBeginContact.add( onSensorTouched );
		}
		
		private function onSensorTouched(callback:InteractionCallback):void
		{
			//			if ( _context.viewMaster._mobileInput.screenTouched ) {
			var collider:NapePhysicsObject = callback.int1.userData.myData is Sensor ?
				callback.int2.userData.myData as NapePhysicsObject : callback.int1.userData.myData;
			if ( collider && collider is MickeyHero ) {
				this.view = switchOn;
				var cObj:CitrusObject = CitrusEngine.getInstance().state.getObjectByName( _doorId );
				if ( cObj is NapePhysicsObject )
				{
					cObj.kill = true;
				}
			}
		}
	}
}