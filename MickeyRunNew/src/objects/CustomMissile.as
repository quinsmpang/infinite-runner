package objects
{
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import citrus.core.starling.StarlingState;
	import citrus.objects.CitrusSprite;
	import citrus.objects.platformer.nape.Missile;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.physics.nape.NapeUtils;
	import citrus.view.ACitrusCamera;
	import citrus.view.starlingview.StarlingArt;
	import citrus.view.starlingview.StarlingView;
	
	import nape.callbacks.InteractionCallback;
	import nape.dynamics.InteractionFilter;
	import nape.phys.Material;
	import nape.shape.Circle;
	
	import starling.extensions.particles.PDParticleSystem;
	import starling.textures.Texture;
	
	import views.ParticleAssets;

	public class CustomMissile extends Missile
	{
		private var _context:GameContext = null;
		private var particleMissile:CitrusSprite;
		private var particleMissilePD:PDParticleSystem;
		
		public function CustomMissile(name:String, params:Object = null, context:GameContext=null ) {
			super(name, params);
			
			particleMissile = new CitrusSprite("particleMissile", {view:new PDParticleSystem(XML(new ParticleAssets.ParticleMissileXML()), Texture.fromBitmap(new ParticleAssets.ParticleTexture()))});
			_ce.state.add(particleMissile);
			
			if ( particleMissilePD == null ) {
				particleMissilePD = 
					((((_ce.state as StarlingState).view as StarlingView).getArt(particleMissile) as StarlingArt).content as PDParticleSystem);
				particleMissilePD.maxNumParticles = 200;
				particleMissilePD.start();
			}
		}
		
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			body.velocity.x = 600;
			
			particleMissilePD.emitterX = this.x;
			particleMissilePD.emitterY = this.y - 5;
			
//			if ( _body == null || _context == null ) return;
//			
//			if (_body.position.x > _context.viewCamPosX + _context.viewCamLensWidth) {
//				kill = true;
//			}
		}
		
		override public function destroy():void
		{
			if ( particleMissilePD ) {
				particleMissilePD.stop();
				particleMissilePD.dispose();
			}
			
			super.destroy();
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