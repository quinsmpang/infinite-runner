package objects
{
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import citrus.objects.platformer.nape.Missile;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.physics.nape.NapeUtils;
	import citrus.view.ACitrusCamera;
	
	import nape.callbacks.InteractionCallback;
	import nape.dynamics.InteractionFilter;
	import nape.phys.Material;
	import nape.shape.Circle;

	public class CustomMissile extends Missile
	{
		private var cam:ACitrusCamera;
		private var _context:GameContext = null;
		public function CustomMissile(name:String, params:Object = null, context:GameContext=null ) {
			super(name, params);
			cam = _ce.state.view.camera;
		}
		
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			body.velocity.x += 600;
//			if (!_exploded)
//				_body.velocity.x += 500;
//			else
//				_body.velocity.x = 0;
			
			if (_body.position.x > cam.camPos.x + cam.cameraLensWidth + this.width) {
				kill = true;
			}
		}
		
		override public function explode():void {
			
			if (_exploded)
				return;
			
			_exploded = true;
			updateAnimation();
			
			var filter:InteractionFilter = new InteractionFilter();
			filter.collisionMask = PhysicsCollisionCategories.GetNone();
			_body.setShapeFilters(filter);
			
			onExplode.dispatch(this, _contact);
			
			clearTimeout(_fuseDurationTimeoutID);
			_explodeTimeoutID = setTimeout(killMissile, explodeDuration);
		}
		
		override protected function createShape():void {
			
			_material = new Material( 10 );
			_radius = _width/2;
			_shape = new Circle(_radius, null, _material);
			
			_body.shapes.add(_shape);
		}
		
		override protected function createBody():void {
			
			super.createBody();
			
//			_body.allowRotation = false;
			_body.gravMass = 0;
//			_body.rotate(new Vec2(_x, _y), angle * Math.PI / 180);
		}
		
		override protected function createConstraint():void {
			
			_body.space = _nape.space;			
			_body.cbTypes.add(MISSILE);
		}
		
		override public function handleBeginContact(callback:InteractionCallback):void {
			
			_contact = NapeUtils.CollisionGetOther(this, callback);
			
//			if (!callback.arbiters.at(0).shape1.sensorEnabled && !callback.arbiters.at(0).shape2.sensorEnabled)
//				explode();
		}
		
//		override public function handleBeginContact(contact:b2Contact):void {
//			explode();
//		}
		
//		override protected function defineBody():void {
//			
//			super.defineBody();
//			
//			_bodyDef.bullet = false;
//			_bodyDef.allowSleep = true;
//		}
//		
//		override protected function defineFixture():void {
//			
//			super.defineFixture();
//			
//			_fixtureDef.filter.categoryBits = PhysicsCollisionCategories.Get("Level");
//			_fixtureDef.filter.maskBits = PhysicsCollisionCategories.GetAllExcept("Level");
//		}
	}
}