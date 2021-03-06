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
		
		private var _screenTouched:Boolean = false;
		public var _buttonClicked:Boolean = false;

		public function TouchInput() {
			super();
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

		public var touchPoint:Point = new Point();
		private function _touchEvent(tEvt:TouchEvent):void {
				
			var touchStart:Touch = tEvt.getTouch((_ce as StarlingCitrusEngine).starling.stage, TouchPhase.BEGAN);
			var touchEnd:Touch = tEvt.getTouch((_ce as StarlingCitrusEngine).starling.stage, TouchPhase.ENDED);
			
//			if ( tEvt.target is MickeyHero ) {
//				if ( touchStart ) _buttonClicked = true;
//				if ( touchEnd ) _buttonClicked = false;
//				return;
//			}
			
//			var touchHover:Touch = tEvt.getTouch((_ce as StarlingCitrusEngine).starling.stage, TouchPhase.HOVER);
			var touchMoved:Touch = tEvt.getTouch((_ce as StarlingCitrusEngine).starling.stage, TouchPhase.MOVED);

			if (touchStart) {
				_screenTouched = true;
//				trace( " touch began " );
			}
			
			if ( touchMoved ) {
				touchPoint = touchMoved.getLocation( (_ce.state as StarlingState) );
//				touchPoint.x = touchMoved.globalX;
//				touchPoint.y = touchMoved.globalY;
			}
			
//			if ( !touchHover && !touchMoved )
//				trace( " touch going on " );
			
			if (touchEnd) {
				_screenTouched = false;
//				trace( " touch ended " );
			}
		}

		public function get screenTouched():Boolean {
			return _screenTouched;
		}
	}
}
