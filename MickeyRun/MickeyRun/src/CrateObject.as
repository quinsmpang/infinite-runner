package
{
	import citrus.objects.NapePhysicsObject;
	
	public class CrateObject extends NapePhysicsObject
	{
		private var origX:int = 0;
		private var _hero:MickeyHero = null;
		
		public function CrateObject(name:String, params:Object=null, _hero:MickeyHero=null )
		{
			super(name, params);
			origX = this.x;
			this._hero = _hero;
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			if (_hero.x - this.x > 100 ) {
				this._ce.state.remove(this);
				trace( "removed body" + this.x );
			}
		}
	}
}