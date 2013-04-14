package objects
{
	import citrus.objects.platformer.nape.Crate;
	
	import nape.callbacks.InteractionCallback;
	
	public class CustomCrate extends Crate
	{
		private var _context:GameContext = null;
		
		public function CustomCrate(name:String, params:Object=null, context:GameContext=null )
		{
			super(name, params);
			this._context = context;
		}
		
		private var rightMostX:int;
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
//			if ( this.x + this.width < _context.viewCamPosX ) {
//				this.kill = true;
//			}
		}
		
		override protected function createMaterial():void {
			super.createMaterial();
//			_material.elasticity = 1;
		}
		
		public function destroyThis():void {
			this._ce.state.remove( this );
			this.destroy();
		}
		
	}
}