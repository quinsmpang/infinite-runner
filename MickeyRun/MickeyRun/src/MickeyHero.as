package {

	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Enemy;
	import citrus.objects.platformer.nape.Hero;
	import citrus.objects.platformer.nape.Platform;
	import citrus.physics.nape.NapeUtils;
	import citrus.view.starlingview.AnimationSequence;
	import citrus.view.starlingview.StarlingView;
	
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionType;
	import nape.callbacks.Listener;
	import nape.callbacks.PreCallback;
	import nape.callbacks.PreFlag;
	import nape.callbacks.PreListener;
	import nape.geom.Vec2;
	
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.extensions.particles.PDParticleSystem;

	/**
	 * @author Aymeric
	 */
	public class MickeyHero extends Hero {

		//public var jumpDecceleration:Number = 2;

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
		private var speedTimer:Timer;
		private var numCoins:Number = 0;
		
		private var _context:GameContext;
		
		private var _heroAnim:AnimationSequence;
		
		private var _obstacleHit:Boolean = false;

		public function MickeyHero(name:String, params:Object = null, context:GameContext = null, heroAnim:AnimationSequence = null ) {

			super(name, params);
			
			_context = context;
			
			_minSpeed = _context.heroMinSpeed;
			_maxSpeed = _context.heroMaxSpeed;
			
			_heroAnim = heroAnim;

			jumpAcceleration += 10;
//			jumpHeight += 80;
			jumpHeight += 170;
			
//			this._body.gravMass = 4.8;
			this._body.gravMass = 6.8;
//			this._body.gravMass = 4.8;
			
//			this.dynamicFriction = 0;
//			this.staticFriction = 0;
			
			// working combo: jumAcc += 6; body.gravMass = 6.8; jumpHeight += 200;

			
			_mobileInput = new TouchInput();
			_mobileInput.initialize();
			
			downTimer = new Timer( 12000 );
			downTimer.addEventListener( TimerEvent.TIMER, handleTimeEvent );
			
			speedTimer = new Timer( 1000 );
			speedTimer.addEventListener( TimerEvent.TIMER, handleSpeedTimer );
			speedTimer.start();
			
		}
		
		private function setAnimFPS( anim:String, fps:Number ):void
		{
			if ( fps < 1 ) return;
			(_heroAnim.mcSequences[anim] as MovieClip).fps = fps;
		}
		
		protected function handleSpeedTimer(event:TimerEvent):void
		{
			// TODO Auto-generated method stub
			if ( _isFlying ) 
				_minSpeed *= 1.2;
			else if ( _isSpeeding ) {
				_minSpeed *= 1.3;
			} else {
				_minSpeed *= 1.1;
			}
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
			return numCoins;
		}

		private var missile:CustomMissile;
		private var _firedMissile:Boolean = false;
		
		private var _doubleJumpAvailable:Boolean = true;
		private var screenTouchedOnce:Boolean = false;
		private var screenTapped:Boolean = false;
		
		private var applyImpulse:Boolean = false;
		override public function update(timeDelta:Number):void {

			var velocity:Vec2 = _body.velocity;
			
//			if (velocity.x < _minSpeed) velocity.x = _minSpeed;
			
			
			if (_mobileInput.screenTouched) {
				
				
				screenTouchedOnce = true;
				
				if ( _isFlying ) {
					if ( _mobileInput.touchPoint ) {
//						this.y = _mobileInput.touchPoint.y;
//						this.y -= ( this.y - _mobileInput.touchPoint.y ) * 0.1;	
						velocity.y = -_flyingJumpHeight;
						
					}
				} else {

	//				velocity.x *= 1.5;
	//				if (velocity.x > _maxSpeed) {
	//					velocity.x = _maxSpeed;
	//				}
	//				if ( numJump < 10 ) {
	//					trace( "jump" );
	//					velocity.y = -jumpHeight;
	//					numJump++;
	//				} else {
	//					//numJump = 0;	
	//				}
					
					if (_onGround) {
	
	//					numJump = 0;
						//if (Math.random() > 0.5)
//						this._ce.state.view.camera.setZoom( 0.8 );
						//else
							//this._ce.state.view.camera.setZoom( 1.0 );
						
						_zoomModified = true;
						//velocity.x = 800;
						velocity.y = -jumpHeight;
						_onGround = false;
						
//						trace( "onGround" );
						
						_animation = "slice_";
	
					} else if ( screenTapped && _doubleJumpAvailable ) {
						
//						_body.applyImpulse( Vec2.weak( 200, 0 ) );
						
						velocity.y = -jumpHeight;
//						trace( "double jump" );
						_doubleJumpAvailable = false;
					} else if (velocity.y < 0) {
						velocity.y -= jumpAcceleration;
					} else {
						;//velocity.y += jumpAcceleration;
						
					}
					
				} // isFlying
				
			} else {
				
				if ( screenTouchedOnce ) screenTapped = true;
				
				if ( !_isFlying ) {
//					if (velocity.y < 0) velocity.y *= 0.9;
					if ( velocity.y > 0 ) { // going downwards
						if ( _zoomModified ) {
//							this._ce.state.view.camera.setZoom( 1.0 );
							_zoomModified = false;
						}
					}
				} else {
					if ( velocity.y > 0 ) velocity.y *= 0.85;
				}
				//else velocity.y *= 1.01;

//				if ( velocity.x > _minSpeed ) velocity.x *= 0.99999;
				//else velocity.x = 200;	
//				if ( _onGround ) {
//					if ( _zoomModified ) {
//						this._ce.state.view.camera.setZoom( 1.0 );
//						_zoomModified = false;
//					}
//				}
			}

			//velocity.x = 0;
			
			if ( _isFlying ) {
				velocity.x = _minSpeed + 40;
				if ( velocity.x > _maxSpeed + 20 ) velocity.x = _maxSpeed + 20;
			} else if ( _isSpeeding ) {
				velocity.x = _minSpeed + 100;
				if ( velocity.x > _maxSpeed + 150 ) velocity.x = _maxSpeed + 150;
			} else {
//				velocity.x += (_minSpeed - velocity.x) * 0.2;
				velocity.x = _minSpeed + 10;
				if ( velocity.x > _maxSpeed ) {
//					_isFlying = true;	
//					if ( _flyingPD ) _flyingPD.start();
					velocity.x = _maxSpeed;
				}
			}
			
			if ( _obstacleHit ) {
				velocity.x = -jumpHeight;
				velocity.y = -jumpHeight;
				_obstacleHit = false;
			} else {
			}
			
			if ( _mobileInput._buttonClicked && !_firedMissile ) {
				missile = new CustomMissile("Missile", 
					{x:x + width, y:y, group:group, 
						width:25, height:25, 
						speed:300, 
						explodeDuration:10000, fuseDuration:30000, 
						view:new Image(Assets.getMiscAtlas().getTexture("small_ball"))});
				_ce.state.add( missile );
				_firedMissile = true;
			} else if ( !_mobileInput._buttonClicked ) {
				_firedMissile = false;
			}
			
			_body.velocity = velocity;
			
//			if ( velocity.x < _minSpeed ) _body.applyImpulse( Vec2.weak( 200, 0 ) );
			
			if ( applyImpulse ) {
//				velocity.x = 1000;
//				velocity.y = -1000;
//				_body.applyImpulse( Vec2.weak( 500, 0 ) );
				applyImpulse = false;
			}
			

			_updateAnimation();
		}
		
		private var _flyingPD:PDParticleSystem;
		public function setFlyingPD( pd:PDParticleSystem ):void {
			_flyingPD = pd;
		}

		private function _updateAnimation():void {

			if (_mobileInput.screenTouched) {

//				_animation = _body.velocity.y < 0 ? "jump" : "ascent";
				if ( _isFlying ) _animation = true ? "mickeycarpet_" : "mickeybubble_";
				else if ( _onGround )
					_animation = "slice_";
				else
					_animation = "mickeyjump2_";//_body.velocity.y < 0 ? "mickeyjump2_" : "mickeythrow_";

			} 
			else {
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
//			else
//				_animation = "mickeythrow_";
			if ( _animation == "slice_" ) {
				setAnimFPS( _animation, Math.round( this.body.velocity.x / 14 ) );
			}
			
			if ( _mobileInput._buttonClicked ) {
				_animation = "mickeythrow_";
			}
		}

		override protected function createConstraint():void {

			super.createConstraint();

			_preListener = new PreListener(InteractionType.ANY, CbType.ANY_BODY, CbType.ANY_BODY, handlePreContact);
			_body.space.listeners.add(_preListener);
			
			//_contactBeginListener = new Listener();
			
			
		}
		
		override public function handleBeginContact(callback:InteractionCallback):void {
			
			var collider:NapePhysicsObject = NapeUtils.CollisionGetOther(this, callback);
			
			if (callback.arbiters.length > 0 && callback.arbiters.at(0).collisionArbiter) {
				
				var collisionAngle:Number = callback.arbiters.at(0).collisionArbiter.normal.angle * 180 / Math.PI;
				
				if ( collider is CrateObject || collider is CustomEnemy ) {
					if ( collisionAngle > 45 && collisionAngle < 135 ) {
					
					} else {
//						_maxSpeed += 100;
//						_minSpeed = 200;
						_obstacleHit = true;
						_isFlying = false;
						_isSpeeding = false;
						if ( _flyingPD ) _flyingPD.stop();
//						_context.gameEnded();
//						_context.onCrateHit();
					}
				}
				
//				if ( collider is CrateObject ) ( collider as CrateObject ).destroyThis();
			}
			
//			if ( (callback.int2.userData.myData is CrateObject) ) {
////				_isPushing = true;	
//				_minSpeed = 200;
//				_isFlying = false;
//				if ( _flyingPD ) _flyingPD.stop();
//			}
//			
//			if ( (callback.int2.userData.myData is CustomEnemy) ) {
//				_minSpeed = 200;
//				_isFlying = false;
//				if ( _flyingPD ) _flyingPD.stop();
//			}
			
			if ( collider is CustomBall ) {
				applyImpulse = true;
//				_body.applyImpulse( Vec2.weak( 200, 0 ) );
			}
			
			if (callback.int2.userData.myData is CustomCoin) {
				numCoins++;	
			}
			
			if (callback.int2.userData.myData is CustomBall) {
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
			if (callback.int2.userData.myData is CrateObject) {callback
				_isPushing = false;	
			}	
			
			super.handleEndContact(callback);
		}

		override public function handlePreContact(callback:PreCallback):PreFlag {
			//_isPushing = false;
			
			if ( (callback.int2.userData.myData is CustomGameEndSensor) ) {
				_context.gameEnded();
				return PreFlag.ACCEPT;
			}
			
			if ( _isFlying ) {
				
				if (callback.int1.userData.myData is MickeyHero) {
					if ( !(callback.int2.userData.myData is CustomHills) 
						&& !(callback.int2.userData.myData is CustomBall) )
						return PreFlag.IGNORE;
				}
				
			}

			// ignore platform sides - don't stop when colliding with the sides.
			var collider:NapePhysicsObject = callback.int2.userData.myData as NapePhysicsObject;
			
			if (callback.arbiter && callback.arbiter.collisionArbiter) {
				
				var collisionAngle:Number = callback.arbiter.collisionArbiter.normal.angle * 180 / Math.PI;
				
				if ( collider is Platform ) {
					//					trace( "collision angle: " + collisionAngle );
					if ( collisionAngle < 45 || collisionAngle > 135 ) {
						return PreFlag.IGNORE;	
					}
				}
			}
			
			if (callback.int2.userData.myData is Platform ||
				callback.int2.userData.myData is CustomHills ||
				callback.int2.userData.myData is PhyEPlatform285
			) {
				_onGround = true;
				_doubleJumpAvailable = true;
				screenTapped = false;
				screenTouchedOnce = false;
				//_animation = "slice_";
//				_minSpeed *= 1.09;
				
//				if ( _zoomModified ) {
//					this._ce.state.view.camera.setZoom( 1.0 );
//					_zoomModified = false;
//				}
			} 
//			else if (callback.int2.userData.myData is CrateObject) {
//				return PreFlag.IGNORE;	
//			}
			


			return PreFlag.ACCEPT;
		}
	}
}
