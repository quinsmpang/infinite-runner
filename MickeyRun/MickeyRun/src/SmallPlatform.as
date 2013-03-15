package
{
	import citrus.objects.platformer.nape.Platform;
	
	public class SmallPlatform extends Platform
	{
		private var _hero:MickeyHero = null;
		
		public function SmallPlatform( name:String, params:Object=null, _hero:MickeyHero=null )
		{
			super(name, params);
			
			this._hero = _hero;
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			if (_hero.x - this.x > this.width + this.width/2 ) {
				this._ce.state.remove(this);
				//trace( "removed body" + this.x );
			}
		}
	}
}