package objects
{
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Crate;
	import citrus.physics.nape.NapeUtils;
	
	import nape.callbacks.InteractionCallback;
	
	public class CustomCrate extends Crate
	{
		private var _context:GameContext = null;
		private var _spawnItem:String = null;
		
		public function CustomCrate(name:String, params:Object=null, context:GameContext=null, spawnItem:String=null )
		{
			this._context = context;
			this._spawnItem = spawnItem;
			super(name, params);
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
		
		override public function handleBeginContact(callback:InteractionCallback):void {
			
			var npo:NapePhysicsObject = NapeUtils.CollisionGetOther(this, callback);
			
			if ( npo is CustomMissile ) {
				if ( _spawnItem ) {
					_context.viewMaster.createLevelComponent( _spawnItem );
				}
				this.kill = true;
			}
			
//			if (!callback.arbiters.at(0).shape1.sensorEnabled && !callback.arbiters.at(0).shape2.sensorEnabled)
//				explode();
		}
	}
}