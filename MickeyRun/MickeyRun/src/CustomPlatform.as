package
{
	import citrus.objects.platformer.nape.Platform;
	
	import nape.phys.BodyType;
	
	public class CustomPlatform extends Platform
	{
		private var _hero:MickeyHero;
		public function CustomPlatform( name:String, params:Object=null, _hero:MickeyHero=null )
		{
			super(name, params);
			this._hero = _hero;
		}
		
		override protected function defineBody():void {
			
			_bodyType = BodyType.KINEMATIC;
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			if ( _hero ) {
				this.x = _hero.x;
				//				trace( "removed body" + this.x );
			}
		}
	}
}