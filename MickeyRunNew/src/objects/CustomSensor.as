package objects
{
	import citrus.objects.platformer.nape.Sensor;
	
	import nape.phys.BodyType;

	public class CustomSensor extends Sensor
	{
		public function CustomSensor( name:String, params:Object=null )
		{
			super( name, params );
		}
		
		override protected function defineBody():void {
			super.defineBody();
//			_bodyType = BodyType.KINEMATIC;
		}
		
		override protected function createFilter():void {
			
			super.createFilter();
			_shape.sensorEnabled = true;
		}
	}
}