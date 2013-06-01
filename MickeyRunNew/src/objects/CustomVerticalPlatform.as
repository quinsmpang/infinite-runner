package objects
{
	import citrus.objects.platformer.nape.Platform;
	
	public class CustomVerticalPlatform extends Platform
	{
		private var _context:GameContext;
		
		public function CustomVerticalPlatform(name:String, params:Object=null, context:GameContext=null)
		{
			_context = context;
			super(name, params);
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
		}
	}
}