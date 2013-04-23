package {

	import flash.geom.Point;
	
	import citrus.core.CitrusEngine;
	import citrus.core.starling.StarlingCitrusEngine;
	import citrus.core.starling.StarlingState;
	import citrus.input.Input;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	/**
	 * @author Aymeric
	 */
	public class TouchInput extends Input {
		
		private var _screenRightTouched:Boolean = false;
		private var _screenLeftTouched:Boolean = false;
		public var _buttonClicked:Boolean = false;
		
		private var _context:GameContext;
		
		public function TouchInput() {
			super();
			_context = GameContext.getInstance();
		}
			
		override public function destroy():void {
			
			(_ce as StarlingCitrusEngine).starling.stage.removeEventListener(TouchEvent.TOUCH, _touchEvent);
			
			super.destroy();
		}

		override public function set enabled(value:Boolean):void {
			
			super.enabled = value;

			_ce = CitrusEngine.getInstance();

			if (enabled)
				(_ce as StarlingCitrusEngine).starling.stage.addEventListener(TouchEvent.TOUCH, _touchEvent);
			else
				(_ce as StarlingCitrusEngine).starling.stage.removeEventListener(TouchEvent.TOUCH, _touchEvent);
		}

		override public function initialize():void {
			
			super.initialize();

			_ce = CitrusEngine.getInstance();

			(_ce as StarlingCitrusEngine).starling.stage.addEventListener(TouchEvent.TOUCH, _touchEvent);
		}

		public var touchStartPoint:Point = new Point();
		public var touchEndPoint:Point = new Point();
		private function _touchEvent(tEvt:TouchEvent):void {
				
			var touchStart:Touch = tEvt.getTouch((_ce as StarlingCitrusEngine).starling.stage, TouchPhase.BEGAN);
			var touchEnd:Touch = tEvt.getTouch((_ce as StarlingCitrusEngine).starling.stage, TouchPhase.ENDED);
			
//			if ( tEvt.target is MickeyHero ) {
//				if ( touchStart ) _buttonClicked = true;
//				if ( touchEnd ) _buttonClicked = false;
//				return;
//			}
			
//			var touchHover:Touch = tEvt.getTouch((_ce as StarlingCitrusEngine).starling.stage, TouchPhase.HOVER);
//			var touchMoved:Touch = tEvt.getTouch((_ce as StarlingCitrusEngine).starling.stage, TouchPhase.MOVED);

			if (touchStart) {
				touchStartPoint = touchStart.getLocation( (_ce.state as StarlingState) );
				
				_screenRightTouched = true;
					
//				if ( _context.isTouchSideRight( touchStartPoint ) ) {
//					_screenRightTouched = true;
//				} else {
//					_screenLeftTouched = true;
//				}
			}
			
//			if ( touchMoved ) {
//				touchStartPoint = touchMoved.getLocation( (_ce.state as StarlingState) );
//				touchPoint.x = touchMoved.globalX;
//				touchPoint.y = touchMoved.globalY;
//			}
			
//			if ( !touchHover && !touchMoved )
//				trace( " touch going on " );
			
			if (touchEnd) {
				touchEndPoint = touchEnd.getLocation( (_ce.state as StarlingState) );
				_screenRightTouched = false;
				
//				if ( _context.isTouchSideRight( touchEndPoint ) ) {
//					_screenRightTouched = false;
//				} else {
//					_screenLeftTouched = false;
//				}
			}
		}

		public function get screenTouchedRight():Boolean {
			return _screenRightTouched;
		}
		
		public function get screenTouchedLeft():Boolean {
			return _screenLeftTouched;
		}
	}
}
