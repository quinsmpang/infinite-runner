package
{
	import citrus.objects.platformer.nape.Sensor;
	
	public class CustomFallSensor extends Sensor
	{
		private var _hero:MickeyHero;
		public function CustomFallSensor(name:String, params:Object=null, _hero:MickeyHero=null )
		{
			super(name, params);
			this._hero = _hero;
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			if ( _hero ) {
				this.x = _hero.x - 100;
				//				trace( "removed body" + this.x );
			}
		}
	}
}