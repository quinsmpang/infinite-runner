package {

	import citrus.objects.platformer.nape.Hero;
	import citrus.objects.platformer.nape.Platform;
	
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionType;
	import nape.callbacks.PreCallback;
	import nape.callbacks.PreFlag;
	import nape.callbacks.PreListener;
	import nape.geom.Vec2;

	/**
	 * @author Aymeric
	 */
	public class BirdHero extends Hero {

		public var jumpDecceleration:Number = 2;

		private var _mobileInput:TouchInput;
		private var _preListener:PreListener;
		
		private var _minSpeed:uint = 100;
		private var _maxSpeed:uint = 400;
		
		private var _zoomModified:Boolean = false;

		public function BirdHero(name:String, params:Object = null) {

			super(name, params);

			jumpAcceleration += 7;
			//jumpHeight += 20;
			
			_mobileInput = new TouchInput();
			_mobileInput.initialize();
		}

		override public function destroy():void {

			_preListener.space = null;
			_preListener = null;

			_mobileInput.destroy();

			super.destroy();
		}

		override public function update(timeDelta:Number):void {

			var velocity:Vec2 = _body.velocity;
			
			if (velocity.x < _minSpeed) velocity.x = _minSpeed;
			
			if (_mobileInput.screenTouched) {

				velocity.x *= 1.5;
				if (velocity.x > _maxSpeed) {
					velocity.x = _maxSpeed;
				}
				
				if (_onGround) {

					//if (Math.random() > 0.5)
						//this._ce.state.view.camera.setZoom( 0.8 );
					//else
						//this._ce.state.view.camera.setZoom( 1.0 );
					
					_zoomModified = true;
					//velocity.x = 800;
					velocity.y = -jumpHeight;
					_onGround = false;

				} else if (velocity.y < 0)
					velocity.y -= jumpAcceleration;
				else {
					velocity.y -= jumpDecceleration;
					
				}
			} else {
				if ( velocity.x > _minSpeed ) velocity.x *= 0.99999;
				//else velocity.x = 200;	
//				if ( _onGround ) {
//					if ( _zoomModified ) {
//						this._ce.state.view.camera.setZoom( 1.0 );
//						_zoomModified = false;
//					}
//				}
			}

			//velocity.x = 0;
			_body.velocity = velocity;

			_updateAnimation();
		}

		private function _updateAnimation():void {

			if (_mobileInput.screenTouched) {

//				_animation = _body.velocity.y < 0 ? "jump" : "ascent";
				_animation = "mickeyjump2_";//_body.velocity.y < 0 ? "jump" : "ascent";

			} 
			else if (_onGround)
				_animation = "slice_";
//			else
//				_animation = "mickeythrow_";
		}

		override protected function createConstraint():void {

			super.createConstraint();

			_preListener = new PreListener(InteractionType.ANY, CbType.ANY_BODY, CbType.ANY_BODY, handlePreContact);
			_body.space.listeners.add(_preListener);
		}

		override public function handlePreContact(callback:PreCallback):PreFlag {

			if (callback.int2.userData.myData is Platform) {
				_onGround = true;
				
//				if ( _zoomModified ) {
//					this._ce.state.view.camera.setZoom( 1 );
//					_zoomModified = false;
//				}
			}

			return PreFlag.ACCEPT;
		}
	}
}
