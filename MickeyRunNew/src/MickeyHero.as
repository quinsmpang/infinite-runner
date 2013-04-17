package {
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import citrus.core.starling.StarlingState;
	import citrus.objects.CitrusSprite;
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Hero;
	import citrus.objects.platformer.nape.Platform;
	import citrus.physics.nape.NapeUtils;
	import citrus.view.starlingview.AnimationSequence;
	import citrus.view.starlingview.StarlingArt;
	import citrus.view.starlingview.StarlingView;
	
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionType;
	import nape.callbacks.Listener;
	import nape.callbacks.PreCallback;
	import nape.callbacks.PreFlag;
	import nape.callbacks.PreListener;
	import nape.geom.Vec2;
	
	import objects.CustomBall;
	import objects.CustomCannonSensor;
	import objects.CustomCoin;
	import objects.CustomCrate;
	import objects.CustomEnemy;
	import objects.CustomHills;
	import objects.CustomMissile;
	import objects.CustomPlatform;
	import objects.CustomPowerup;
	
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.extensions.particles.PDParticleSystem;
	import starling.textures.Texture;
	
	import views.ParticleAssets;

	public class MickeyHero extends Hero {

		private var _mobileInput:TouchInput;
		private var _preListener:PreListener;
		
		private var _contactBeginListener:Listener;
		
		private var _minSpeed:uint = 180;
		private var _maxSpeed:uint = 400;
		
		public var _isFlying:Boolean = false;
		private var _flyingJumpHeight:uint = 250;
		
		public var _isSpeeding:Boolean = false;
		
		private var _zoomModified:Boolean = false;
		
		private var _isPushing:Boolean = false;
		
		public var _heroSpeed:uint = 100;
		
		private var numJump:int = 0;
		
		private var downTimer:Timer;
		private var numStars:Number = 0;
		
		private var _context:GameContext;
		
		private var _heroAnim:AnimationSequence;
		
		private var _obstacleHit:Boolean = false;
		private var _cannonHit:Boolean = false;
		
		private var _ignoreNextPlatform:Boolean = false;
		
		public var impulseCount:int = 0;
		public const impulseMax:int = 50;
		
		private var _isMoving:Boolean = true;
		
		private var MICKEY_HERO:CbType = new CbType();
		
		private var particleCoffee:CitrusSprite;
		private var particleCoffeePD:PDParticleSystem;

		public function MickeyHero(name:String, params:Object = null, context:GameContext = null, heroAnim:AnimationSequence = null ) {

			super(name, params);
			
			_context = context;
			
			_minSpeed = _context.heroMinSpeed;
			_maxSpeed = _context.heroMaxSpeed;
			
			_heroAnim = heroAnim;

			jumpAcceleration += 10;
			jumpHeight += 200;
			
			this._body.gravMass = 2.8;
			
			// working combo: jumAcc += 6; body.gravMass = 6.8; jumpHeight += 200;
			
			_mobileInput = new TouchInput();
			_mobileInput.initialize();
			
			downTimer = new Timer( 12000 );
			downTimer.addEventListener( TimerEvent.TIMER, handleTimeEvent );
			
			particleCoffee = new CitrusSprite("particleCoffee", {view:new PDParticleSystem(XML(new ParticleAssets.ParticleCoffeeXML()), 
				Assets.getMiscAtlas().getTexture( "ParticleTexture" )
//				Texture.fromBitmap(new ParticleAssets.ParticleTexture())
			)});
			_ce.state.add(particleCoffee);
			
			if ( particleCoffeePD == null ) {
				particleCoffeePD = 
					((((_ce.state as StarlingState).view as StarlingView).getArt(particleCoffee) as StarlingArt).content as PDParticleSystem);
//				particleCoffeePD.start();
			}
			
			_flyingPD = particleCoffeePD;
		}
		
		private function setAnimFPS( anim:String, fps:Number ):void
		{
			if ( fps < 1 ) return;
			(_heroAnim.mcSequences[anim] as MovieClip).fps = fps;
		}
		
		protected function handleTimeEvent(event:TimerEvent):void
		{
			// TODO Auto-generated method stub
			_isSpeeding = false;
			_isFlying = false;
			downTimer.stop();
			if ( _flyingPD ) _flyingPD.stop();
		}
		
		override public function destroy():void {

			_preListener.space = null;
			_preListener = null;

			_mobileInput.destroy();

			super.destroy();
		}
		
		public function get velocityX():Number {
			return _body.velocity.x;
		}
		
		public function get numCoinsCollected():Number {
			return numStars;
		}

		private var missile:CustomMissile;
		private var _firedMissile:Boolean = false;
		
		private var _doubleJumpAvailable:Boolean = true;
		private var screenTouchedOnce:Boolean = false;
		private var screenTapped:Boolean = false;
		
		private var applyImpulse:Boolean = false;
		override public function update(timeDelta:Number):void {

			var velocity:Vec2 = _body.velocity;
			
			if ( velocity.x < _minSpeed && !_mobileInput.screenTouchedLeft ) velocity.x = _minSpeed;
			
			if (_mobileInput.screenTouchedRight && !_mobileInput.screenTouchedLeft) {
				screenTouchedOnce = true;
				
				if ( _isFlying ) {
					if ( _mobileInput.touchStartPoint ) {
						velocity.y = -_flyingJumpHeight;
					}
				} else {

					if (_onGround) {
	
						_zoomModified = true;
						velocity.y = -jumpHeight;
						_onGround = false;
						
						_animation = "slice_";
	
					} else if ( screenTapped && _doubleJumpAvailable ) {
						velocity.y = -jumpHeight;
						_doubleJumpAvailable = false;
					} else if (velocity.y < 0) {
						velocity.y -= jumpAcceleration;
					} else {
						;
					}
					
				} // isFlying
				
			} else if ( _mobileInput.screenTouchedLeft ){ 
				if ( _onGround ) {
					if ( velocity.x > 1 ) {
//					velocity.x = 0;
//						velocity.y = -10;
						_body.applyImpulse( Vec2.weak( -40, 0 ) );
					}
				}
			} else {
				
				if ( screenTouchedOnce ) screenTapped = true;
				
				if ( !_isFlying ) {
					if ( velocity.y > 0 ) { // going downwards
						if ( _zoomModified ) {
							_zoomModified = false;
						}
					}
				} else {
					if ( velocity.y > 0 ) velocity.y *= 0.85;
				}
			}

			if ( _isFlying ) {
				velocity.x = _minSpeed + 40;
				if ( velocity.x > _maxSpeed + 20 ) velocity.x = _maxSpeed + 20;
			} else if ( _isSpeeding ) {
//				velocity.x = _minSpeed + 100;
//				if ( velocity.x > _maxSpeed + 150 ) velocity.x = _maxSpeed + 150;
			} else {
//				velocity.x += (_minSpeed - velocity.x) * 0.2;
//				velocity.x = _minSpeed + 10;
				if ( velocity.x > _maxSpeed ) {
					velocity.x = _maxSpeed;
				}
			}
			
			if ( _obstacleHit ) {
//				velocity.x = -jumpHeight;
				velocity.y = -jumpHeight;
				_obstacleHit = false;
				_ignoreNextPlatform = true;
			}
			
			if ( _cannonHit ) {
//				_body.applyImpulse( Vec2.weak( 500, -100 ) );
//				velocity.x = jumpHeight * 20;
//				velocity.y = -30;
				_cannonHit = false;
			}
			
			if ( impulseCount-- > 0 ) {
				_body.applyImpulse( Vec2.weak( 0, -100 ) );
				if ( impulseCount > impulseMax - 2 ) {
					velocity.y = -jumpHeight;
					_onGround = false;
				}
				
				if ( velocity.y > 0 ) {
					impulseCount = 0;
				}
				
			}
			
			if ( _mobileInput.screenTouchedLeft && ( _mobileInput.screenTouchedRight || _isFlying ) && !_firedMissile ) {
				missile = new CustomMissile("Missile", 
					{x:x + width, y:y, group:group, 
						width:25, height:25, 
						speed:300, 
						explodeDuration:2000, fuseDuration:5000, 
						view:new Image(Assets.getMiscAtlas().getTexture("small_ball"))}, _context);
				_ce.state.add( missile );
				_firedMissile = true;
			} else {
				if ( ( _isFlying && !_mobileInput.screenTouchedLeft )
					|| ( !_isFlying && ( !_mobileInput.screenTouchedLeft || !_mobileInput.screenTouchedRight ) ) ) {
					_firedMissile = false;
				}
			}
			
			_body.velocity = velocity;
			
			_updateAnimation();
			
			//update particles
			if ( _isFlying )
				particleCoffeePD.emitterX = this.x + this.width + 15;
			else 
				particleCoffeePD.emitterX = this.x;
			
			particleCoffeePD.emitterY = this.y;
			
		}
		
		private var _flyingPD:PDParticleSystem;
		public function startFlying( start:Boolean, startTimer:Boolean=false, timerDelay:int=5000 ):void {
			
			_isFlying = start;
			
			if ( start ) {
				if ( _flyingPD ) _flyingPD.start();
			} else {
				if ( _flyingPD ) _flyingPD.stop();
			}
			
			if ( startTimer ) {
				downTimer.delay = timerDelay;
				downTimer.start();
			} else {
				downTimer.reset();
			}
		}

		private function _updateAnimation():void {

			if ( _isFlying ) {
				_animation = true ? "mickeycarpet_" : "mickeybubble_";
				return;
			}
			
			if (_mobileInput.screenTouchedRight && _mobileInput.screenTouchedLeft) {
				_animation = "mickeythrow_";
//				setAnimFPS( _animation, 4 );
			} else if (_mobileInput.screenTouchedRight) {
				
				if ( _onGround )
					_animation = "slice_";
				else
					_animation = "mickeyjump2_";//_body.velocity.y < 0 ? "mickeyjump2_" : "mickeythrow_";
				
			} else if ( _mobileInput.screenTouchedLeft ) {
				
				if ( _onGround ) {
//					_animation = "mickeywatch_";
//					setAnimFPS( _animation, 8 );
					_animation = "mickeyidle_";
				} else {
//					_animation = "mickeythrow_";
				}
				
			} else {
				if (_isPushing) {
					//(this.view as AnimationSequence).changeAnimation("mickeypush_", true);	
					_animation = "mickeypush_";
				} else {
					if ( _isFlying ) {
						_animation = "mickeycarpet_";	
					} else if (_onGround)
						_animation = "slice_";
				}
			}

			if ( _animation == "slice_" ) {
				setAnimFPS( _animation, Math.round( this.body.velocity.x / 10 ) );
			}
			
//			if ( _mobileInput._buttonClicked ) {
//				_animation = "mickeythrow_";
//			}
		}

		
		override protected function createConstraint():void {
			super.createConstraint();

			_preListener = new PreListener(InteractionType.ANY, CbType.ANY_BODY, CbType.ANY_BODY, handlePreContact);
//			_preListener = new PreListener(InteractionType.ANY, MICKEY_HERO, CbType.ANY_BODY, handlePreContact);
			_body.space.listeners.add(_preListener);
			_body.cbTypes.add(MICKEY_HERO);
			
		}
		
		override public function handleBeginContact(callback:InteractionCallback):void {
			
			var collider:NapePhysicsObject = NapeUtils.CollisionGetOther(this, callback);
			
			if (callback.arbiters.length > 0 && callback.arbiters.at(0).collisionArbiter) {
				
				var collisionAngle:Number = callback.arbiters.at(0).collisionArbiter.normal.angle * 180 / Math.PI;
				
				if ( collider is CustomEnemy ) {
					if ( collisionAngle > 45 && collisionAngle < 135 ) {
					
					} else {
						_obstacleHit = true;
						_isFlying = false;
						_isSpeeding = false;
						if ( _flyingPD ) _flyingPD.stop();
					}
				}
			}
			
			if (callback.int2.userData.myData is CustomCoin) {
				numStars++;	
				if ( _context.hud ) {
					_context.hud.setStars( numStars );
				}
			}
			
//			if (callback.int2.userData.myData is CustomCannonSensor) {
//				impulseCount = impulseMax;
//			}
			
			if (callback.int2.userData.myData is CustomBall) {
				_cannonHit = true;
				if ( false && Math.random() > 0.99 ) {
					_isSpeeding = true;
					downTimer.start();
					if ( _flyingPD ) _flyingPD.start();
				}
			}
			
			if (callback.int2.userData.myData is CustomPowerup) {
				downTimer.start();
				_isFlying = true;//!_isFlying;
				if ( _flyingPD ) _flyingPD.start();
			}
			
			super.handleBeginContact(callback);
		}
		
		override public function handleEndContact(callback:InteractionCallback):void {
			if (callback.int2.userData.myData is CustomCrate) {callback
				_isPushing = false;	
			}	
			
			super.handleEndContact(callback);
		}

		override public function handlePreContact(callback:PreCallback):PreFlag {
			if ( _isFlying ) {
				if (callback.int1.userData.myData is MickeyHero) {
					if ( !(callback.int2.userData.myData is CustomHills) 
						&& !(callback.int2.userData.myData is CustomEnemy) )
						return PreFlag.IGNORE;
				}
			}

			if ( _ignoreNextPlatform ) {
				if (callback.int1.userData.myData is MickeyHero) {
					if ( callback.int2.userData.myData is CustomPlatform) {
						_ignoreNextPlatform = false;
						return PreFlag.IGNORE;
					}
				}
			}
			
			// ignore platform sides - don't stop when colliding with the sides.
			var collider:NapePhysicsObject = callback.int2.userData.myData as NapePhysicsObject;
			
			if (callback.arbiter && callback.arbiter.collisionArbiter) {
				
				var collisionAngle:Number = callback.arbiter.collisionArbiter.normal.angle * 180 / Math.PI;
				
				if ( collider is Platform ) {
					if ( collisionAngle < 45 || collisionAngle > 135 ) {
						return PreFlag.IGNORE;	
					}
				}
			}
			
			if (callback.int2.userData.myData is Platform ||
				callback.int2.userData.myData is CustomHills
			) {
				_onGround = true;
				_doubleJumpAvailable = true;
				screenTapped = false;
				screenTouchedOnce = false;
			} 

			return PreFlag.ACCEPT;
		}

	}
}
