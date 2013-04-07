package objects
{
	import citrus.objects.platformer.nape.Coin;
	
	public class CustomPowerup extends Coin
	{	
		private var _context:GameContext = null;
		
		public function CustomPowerup(name:String, params:Object=null, context:GameContext=null )
		{
			super(name, params);
			this._context = context;
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			if ( this.x + this.width < _context.viewCamPosX ) {
				this.kill = true;
			}
		}
	}
}