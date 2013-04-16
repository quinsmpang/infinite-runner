package objects
{
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Sensor;
	
	import nape.callbacks.InteractionCallback;
	
	import starling.display.Image;
	
	public class CustomCannonSensor extends Sensor
	{	
		private var _context:GameContext = null;
		private var springCompressed:Image;
		private var springUnCompressed:Image;
		
		private var springAnimCount:int = 0;
		
		public function CustomCannonSensor(name:String, params:Object=null, context:GameContext=null )
		{
			springCompressed = new Image( Assets.getMiscAtlas().getTexture("spring") );
			springUnCompressed = new Image( Assets.getMiscAtlas().getTexture("spring2") );
			super(name, params);
			this._context = context;
			this.view = springCompressed;
			
			// sensor handler
			onBeginContact.add( onSensorTouched );
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			if ( springAnimCount-- < 1 ) {
				this.view = springCompressed;
				springAnimCount = 0;
			}
			
//			if ( this.x + this.width < _context.viewCamPosX ) {
//				this.kill = true;
//			}
		}
		
		private function onSensorTouched(callback:InteractionCallback):void
		{
			var collider:NapePhysicsObject = callback.int1.userData.myData is Sensor ?
				callback.int2.userData.myData as NapePhysicsObject : callback.int1.userData.myData;
			if ( collider && collider is MickeyHero ) {
				var mickey:MickeyHero = collider as MickeyHero;
				mickey.impulseCount = mickey.impulseMax;
				springAnimCount = 10;
				this.view = springUnCompressed;
			}
		}
	}
}