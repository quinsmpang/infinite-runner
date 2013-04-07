package
{
	import citrus.objects.platformer.nape.MovingPlatform;
	
	import nape.phys.Material;
	
	public class SmallMovingPlatform extends MovingPlatform
	{
		private var _hero:MickeyHero = null;
		private var _friction:Number = 0;
		public function SmallMovingPlatform( name:String, params:Object=null, _hero:MickeyHero=null )
		{
			_friction = params.friction;
			this.speed = 10;
			this.enabled = true;
			this.waitForPassenger = false;
			super(name, params);
			
			this._hero = _hero;
//			this.waitForPassenger = false;
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			if ( this.x + this.width /2 < _ce.state.view.camera.camPos.x ) {
//			if (_hero.x - this.x > this.width + 100 ) {
				this._ce.state.remove(this);
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