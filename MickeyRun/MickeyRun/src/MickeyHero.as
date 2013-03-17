package {

	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import citrus.objects.platformer.nape.Hero;
	import citrus.objects.platformer.nape.Platform;
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

	/**
	 * @author Aymeric
	 */
	public class MickeyHero extends Hero {

		//public var jumpDecceleration:Number = 2;

		private var _mobileInput:TouchInput;
		private var _preListener:PreListener;
		
		private var _contactBeginListener:Listener;
		
		private var _minSpeed:uint = 190;
		private var _maxSpeed:uint = 400;
		
		public var _isFlying:Boolean = false;
		
		private var _zoomModified:Boolean = false;
		
		private var _isPushing:Boolean = false;
		
		public var _heroSpeed:uint = 100;
		
		private var numJump:int = 0;
		
		private var downTimer:Timer;
		private var numCoins:Number = 0;

		public function MickeyHero(name:String, params:Object = null) {

			super(name, params);

			//jumpAcceleration += 20;
			jumpHeight += 180;
			
			this._body.gravMass = 4.8;
			
//			this.dynamicFriction = 0;
//			this.staticFriction = 0;

			
			_mobileInput = new TouchInput();
			_mobileInput.initialize();
			
			downTimer = new Timer( 10000 );
			downTimer.addEventListener( TimerEvent.TIMER, handleTimeEvent );
			
		}
		
		protected function handleTimeEvent(event:TimerEvent):void
		{
			// TODO Auto-generated method stub
			_isFlying = false;
			downTimer.stop();
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

		override public function update(timeDelta:Number):void {

			var velocity:Vec2 = _body.velocity;
			
			if (velocity.x < _minSpeed) velocity.x = _minSpeed;
			
			
			if (_mobileInput.screenTouched) {
				
				if ( _isFlying ) {
					if ( _mobileInput.touchPoint ) {
//						this.y = _mobileInput.touchPoint.y;
//						this.y -= ( this.y - _mobileInput.touchPoint.y ) * 0.1;	
						velocity.y = -200;
						
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
							//this._ce.state.view.camera.setZoom( 0.8 );
						//else
							//this._ce.state.view.camera.setZoom( 1.0 );
						
						_zoomModified = true;
						//velocity.x = 800;
						velocity.y = -jumpHeight;
						_onGround = false;
						
						_animation = "slice_";
	
					} else if (velocity.y < 0)
						velocity.y -= jumpAcceleration;
					else {
						;//velocity.y += jumpAcceleration;
						
					}
					
				} // isFlying
				
			} else {
				if ( !_isFlying ) {
					if (velocity.y < 0) velocity.y *= 0.9;
				} else {
					if ( velocity.y > 0 ) velocity.y *= 0.8;
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

//			if ( velocity.x < _maxSpeed ) velocity.x *= 1.015;
			//velocity.x = 0;
			
			if ( _isFlying ) {
				velocity.x = _minSpeed + 60;
			} else {
				velocity.x = _minSpeed;
			}
			
			_body.velocity = velocity;

			_updateAnimation();
		}

		private function _updateAnimation():void {

			if (_mobileInput.screenTouched) {

//				_animation = _body.velocity.y < 0 ? "jump" : "ascent";
				if ( _isFlying ) _animation = true ? "mickeycarpet_" : "mickeybubble_";
				else _animation = "mickeyjump2_";//_body.velocity.y < 0 ? "mickeyjump2_" : "mickeythrow_";

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
		}

		override protected function createConstraint():void {

			super.createConstraint();

			_preListener = new PreListener(InteractionType.ANY, CbType.ANY_BODY, CbType.ANY_BODY, handlePreContact);
			_body.space.listeners.add(_preListener);
			
			//_contactBeginListener = new Listener();
			
			
		}
		
		override public function handleBeginContact(callback:InteractionCallback):void {
			
			
			if (callback.int2.userData.myData is CrateObject) {
				_isPushing = true;	
			}
			
			if (callback.int2.userData.myData is CustomCoin) {
				numCoins++;	
			}
			
			if (callback.int2.userData.myData is CustomPowerup) {
				downTimer.start();
				_isFlying = true;//!_isFlying;	
			}
			
			super.handleBeginContact(callback);
		}
		
		override public function handleEndContact(callback:InteractionCallback):void {
			if (callback.int2.userData.myData is CrateObject) {
				_isPushing = false;	
			}	
			
			super.handleEndContact(callback);
		}

		override public function handlePreContact(callback:PreCallback):PreFlag {
			//_isPushing = false;
			
			if ( _isFlying ) {
				
				if ( !(callback.int2.userData.myData is CustomHills) )
					return PreFlag.IGNORE;
			}
			
			if (callback.int2.userData.myData is Platform ||
				callback.int2.userData.myData is PhyEPlatform285) {
				_onGround = true;
				//_animation = "slice_";
				
//				if ( _zoomModified ) {
//					this._ce.state.view.camera.setZoom( 1 );
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
