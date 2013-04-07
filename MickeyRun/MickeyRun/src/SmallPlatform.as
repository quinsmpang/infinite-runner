package
{
	import citrus.objects.platformer.nape.Platform;
	
	import nape.phys.Material;
	
	public class SmallPlatform extends Platform
	{
		private var _hero:MickeyHero = null;
		private var _friction:Number = 0;
		
		public function SmallPlatform( name:String, params:Object=null, _hero:MickeyHero=null )
		{
			_friction = params.friction;
			super(name, params);
			
			
			this._hero = _hero;
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			if ( this.x + this.width /2 < _ce.state.view.camera.camPos.x ) {
//			if (_hero.x - this.x > this.width + this.width/2 ) {
				this._ce.state.remove(this);
				//trace( "removed body" + this.x );
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