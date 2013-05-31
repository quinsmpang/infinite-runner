package objects
{
	import com.playdom.gas.AnimList;
	import com.playdom.gas.anims.Path;
	
	import flash.utils.setTimeout;
	
	import citrus.core.CitrusEngine;
	import citrus.core.starling.StarlingState;
	import citrus.objects.CitrusSprite;
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Sensor;
	import citrus.view.starlingview.StarlingArt;
	import citrus.view.starlingview.StarlingView;
	
	import nape.callbacks.InteractionCallback;
	import nape.phys.BodyType;
	
	import starling.display.BlendMode;
	import starling.extensions.particles.PDParticleSystem;
	import starling.textures.Texture;
	
	import views.ParticleAssets;

	public class CustomPortal extends Sensor
	{
		private var _context:GameContext;
		private var _portalExit:CitrusSprite;
		private var _portalExitPD:PDParticleSystem;
		private var _portalEntry:CitrusSprite;
		private var _portalEntryPD:PDParticleSystem;
		
		private var _exitX:int;
		private var _exitY:int;
		
		public function CustomPortal( name:String, params:Object=null, 
			context:GameContext=null, exitX:int=0, exitY:int=0 )
		{
			_context = context;
			_exitX = exitX;
			_exitY = exitY;
			
			var psconfig:XML = Assets.getParticleMushroomConfig();
//			var psconfig:XML = Assets.getParticleConfig();
//			var psTexture:Texture = Assets.getTexture( "_particlePng" );
			var psTexture:Texture =	Assets.getMiscAtlas().getTexture( "ParticleTexture" );

			_portalExit = new CitrusSprite("particleMushroom", 
				{view:new PDParticleSystem(psconfig, psTexture)});
			
			psconfig = Assets.getParticleConfig();
//			psTexture = Assets.getTexture( "ParticleTexture" );
//			psTexture =	Assets.getMiscAtlas().getTexture( "ParticleTexture" );
				
			_portalEntryPD = new PDParticleSystem(psconfig, psTexture);
//			_portalEntryPD.start();
			
			super( name, params );
			this.view = _portalEntryPD;
			
			_ce.state.add( _portalExit );
			
			if ( _portalExitPD == null ) {
				_portalExitPD = 
					((((_ce.state as StarlingState).view as StarlingView).getArt(_portalExit) as StarlingArt).content as PDParticleSystem);
			}
//			_portalExitPD.start();
			
//			_portalEntryPD.blendMode = BlendMode.NONE;
//			_portalExitPD.blendMode = BlendMode.NONE;
			
			_portalExitPD.emitterX = exitX;
			_portalExitPD.emitterY = exitY;
			
			// sensor handler
			onBeginContact.add( onSensorTouched );
			
//			var alist:AnimList = _context.animControl.attachAnimList( _portalExitPD );
//			Path.make( alist, 1000, _portalExitPD.y, 3000, 2000 ).osc = true;
		}
		
		private function onSensorTouched(callback:InteractionCallback):void
		{
			var collider:NapePhysicsObject = callback.int1.userData.myData is Sensor ?
				callback.int2.userData.myData as NapePhysicsObject : callback.int1.userData.myData;
			var facingLeft:Boolean = _exitX < _context.viewCamLeftX + _context.viewCamLensWidth / 2;
			
			if ( collider ) {
				collider.x = _exitX;
				collider.y = _exitY;
			}
			
			if ( collider is CustomBall ) {
				( collider as CustomBall ).turn( facingLeft );
			}
			
			if ( collider is MickeyHero ) {
				( collider as MickeyHero ).turn( facingLeft );
				( collider as MickeyHero )._isMoving = false;
				( collider as MickeyHero ).screenTappedOnce = false;
				
				_context.viewMaster._mobileInput.screenTouched = false;
			}
		}
		
		
		private var isEntrySleeping:Boolean = false;
		private var isExitSleeping:Boolean = false;
		override public function update( timeDelta:Number ):void {
			super.update( timeDelta );
			
//			_exitX = _portalExitPD.x;
//			_exitY = _portalExitPD.y;
			
			if ( this.x < _context.viewCamLeftX 
				|| ( this.x > _context.viewCamLeftX + _context.viewCamLensWidth + 200 )  ) {
				
				if ( !isEntrySleeping ) {
					_portalEntryPD.stop();
					isEntrySleeping = true;
				}
			} else {
				if ( isEntrySleeping ) {
//					_portalEntryPD.start();
					isEntrySleeping = false;
				}
			}
			
			if ( _exitX < _context.viewCamLeftX 
				|| ( _exitX > _context.viewCamLeftX + _context.viewCamLensWidth )  ) {
				
				if ( !isExitSleeping ) {
					_portalExitPD.stop();
					isExitSleeping = true;
				}
			} else {
				if ( isExitSleeping ) {
//					_portalExitPD.start();
					isExitSleeping = false;
				}
			}
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