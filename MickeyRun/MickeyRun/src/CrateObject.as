package
{
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Crate;
	
	public class CrateObject extends Crate
	{
		private var origX:int = 0;
		private var _hero:MickeyHero = null;
		
		public function CrateObject(name:String, params:Object=null, _hero:MickeyHero=null )
		{
			super(name, params);
			origX = this.x;
			this._hero = _hero;
//			this._body.mass += 500;
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			if (_hero.x - this.x > 200 ) {
				this._ce.state.remove(this);
				this.destroy();
				trace( "removed body" + this.x );
			}
		}
	}
}