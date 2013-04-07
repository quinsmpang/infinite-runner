package objects
{
	import citrus.objects.platformer.nape.MovingPlatform;
	
	import nape.phys.Material;
	
	public class CustomMovingPlatform extends MovingPlatform
	{
		private var _context:GameContext = null;
		private var _friction:Number = 0;
		public function CustomMovingPlatform( name:String, params:Object=null, context:GameContext=null )
		{
			_friction = params.friction;
			this.speed = 10;
			this.enabled = true;
			this.waitForPassenger = false;
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
			_material = new Material( 0, f, f, 10, f );
//			_material.elasticity = 30;
//			_material = Material.ice();
		}
	}
}