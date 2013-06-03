package objects
{
	import citrus.objects.platformer.nape.Coin;
	
	import nape.phys.BodyType;
	
	public class CustomCoin extends Coin
	{	
		private var _context:GameContext = null;
		
		public function CustomCoin(name:String, params:Object=null, context:GameContext=null )
		{
			super(name, params);
			this._context = context;
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
//			if ( this.x + this.width < _context.viewCamLeftX ) {
//				this.kill = true;
//			}
		}
		
		override protected function defineBody():void {
			
			_bodyType = BodyType.KINEMATIC;
		}
	}
}