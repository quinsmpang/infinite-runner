package objects
{
	import citrus.objects.platformer.nape.Platform;
	
	import nape.phys.Material;
	
	public class CustomPlatform extends Platform
	{
		private var _context:GameContext = null;
		private var _friction:Number = 0;
		
		public function CustomPlatform( name:String, params:Object=null, context:GameContext=null )
		{
//			_friction = params.friction;
			super(name, params);
			this._context = context;
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			if ( this.x + this.width < _context.viewCamPosX ) {
				this.kill = true;
			}
		}
		
		override protected function createMaterial():void {
			super.createMaterial();
			
			var f:int = _friction;
			_material = new Material( 0, f, f, 1, f );
//			_material.elasticity = 30;
//			_material = Material.ice();
		}
	}
}