package
{
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Crate;
	import citrus.physics.nape.NapeUtils;
	
	import nape.callbacks.InteractionCallback;
	import nape.phys.Material;
	
	public class CrateObject extends Crate
	{
		private var origX:int = 0;
		private var _hero:MickeyHero = null;
		
		public function CrateObject(name:String, params:Object=null, _hero:MickeyHero=null )
		{
			super(name, params);
			origX = this.x;
			this._hero = _hero;
			this._body.mass += 500;
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			if ( this.x + this.width /2 < _ce.state.view.camera.camPos.x ) {
//			if (_hero.x - this.x > 400 ) {
				this._ce.state.remove(this);
				this.destroy();
				//trace( "removed body" + this.x );
			}
		}
		
		override protected function createMaterial():void {
			
//			_material = new Material(0.65, 0.57, 1.2, 1, 0);
			super.createMaterial();
			
//			_material.elasticity = 1;
		}
		
		public function destroyThis():void {
			this._ce.state.remove( this );
			this.destroy();
		}
		
		override public function handleBeginContact(callback:InteractionCallback):void {
			var collider:NapePhysicsObject = NapeUtils.CollisionGetOther(this, callback);
				
			if ( collider is CustomMissile ) {
				this.destroyThis();
			}
//			if ( collider is CrateObject ) ( collider as CrateObject ).destroyThis();
			
		}
	}
}