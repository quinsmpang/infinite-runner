package
{
	import citrus.objects.platformer.nape.Coin;
	
	public class CustomCoin extends Coin
	{	
		private var _hero:MickeyHero = null;
		
		public function CustomCoin(name:String, params:Object=null, _hero:MickeyHero=null )
		{
			super(name, params);
			this._hero = _hero;
			//			this._body.mass += 500;
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			if (_hero.x - this.x > 200 ) {
				this._ce.state.remove(this);
				this.destroy();
//				trace( "removed body" + this.x );
			}
		}
	}
}