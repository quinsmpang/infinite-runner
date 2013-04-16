package objects
{
	import citrus.core.starling.StarlingState;
	import citrus.objects.CitrusSprite;
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Sensor;
	import citrus.view.starlingview.StarlingArt;
	import citrus.view.starlingview.StarlingView;
	
	import nape.callbacks.InteractionCallback;
	import nape.phys.BodyType;
	
	import starling.extensions.particles.PDParticleSystem;
	import starling.textures.Texture;
	
	import views.ParticleAssets;

	public class CustomPortal extends Sensor
	{
		private var _context:GameContext;
		private var _portalEntryParticleSystem:CitrusSprite;
		private var _portalEntryParticleSystemPD:PDParticleSystem;
		private var _particleMushroom:CitrusSprite;
		private var _particleMushroomPD:PDParticleSystem;
		
		private var _exitX:int;
		private var _exitY:int;
		
		public function CustomPortal( name:String, params:Object=null, 
			context:GameContext=null, exitX:int=0, exitY:int=0 )
		{
			_context = context;
			_exitX = exitX;
			_exitY = exitY;
			
			var psconfig:XML = Assets.getParticleConfig();
			var psTexture:Texture = Assets.getTexture( "_particlePng" );

			_portalEntryParticleSystem = new CitrusSprite("particleCoffee", 
				{view:new PDParticleSystem(psconfig, psTexture)});
			
			psconfig = Assets.getParticleMushroomConfig();
			psTexture = Assets.getTexture( "ParticleTexture" );
			
			_particleMushroomPD = new PDParticleSystem(psconfig, psTexture);
			_particleMushroomPD.start();
			
			super( name, params );
			this.view = _particleMushroomPD;
			
			_ce.state.add( _portalEntryParticleSystem );
			
			if ( _portalEntryParticleSystemPD == null ) {
				_portalEntryParticleSystemPD = 
					((((_ce.state as StarlingState).view as StarlingView).getArt(_portalEntryParticleSystem) as StarlingArt).content as PDParticleSystem);
			}
			_portalEntryParticleSystemPD.start();
			
			_portalEntryParticleSystemPD.emitterX = exitX;
			_portalEntryParticleSystemPD.emitterY = exitY;
			
			// sensor handler
			onBeginContact.add( onSensorTouched );
		}
		
		private function onSensorTouched(callback:InteractionCallback):void
		{
			var collider:NapePhysicsObject = callback.int1.userData.myData is Sensor ?
				callback.int2.userData.myData as NapePhysicsObject : callback.int1.userData.myData;
			if ( collider ) {
				collider.x = _exitX;
				collider.y = _exitY;
			}
		}
		
		
		private var isSleeping:Boolean = false;
		override public function update( timeDelta:Number ):void {
			super.update( timeDelta );
			
//			if ( this.x < _context.viewCamPosX || this.x > _context.viewCamPosX + _context.viewCamLensWidth ) {
//				_particleMushroomPD.stop();
//				_portalEntryParticleSystemPD.stop();
//				isSleeping = true;
//			} else {
//				_particleMushroomPD.start();
//				_portalEntryParticleSystemPD.start();
//				isSleeping = false;
//			}
		}
		
		override protected function defineBody():void {
			super.defineBody();
//			_bodyType = BodyType.KINEMATIC;
		}
		
		override protected function createFilter():void {
			
			super.createFilter();
			_shape.sensorEnabled = true;
		}
	}
}