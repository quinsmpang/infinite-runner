package
{
	import citrus.objects.platformer.nape.Enemy;

	public class CustomEnemy extends Enemy
	{
		private var _hero:MickeyHero = null;
		
		public function CustomEnemy(name:String, params:Object=null, _hero:MickeyHero=null )
		{
			super(name, params);
			this._hero = _hero;
			//			this._body.mass += 500;
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			_animation = "slice_";
			
			if (_hero.x - this.x > 300 ) {
				this._ce.state.remove(this);
				this.destroy();
				//				trace( "removed body" + this.x );
			}
		}
	}
}