package awayphysics.platformer3d {

	import away3d.controllers.HoverController;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;

	import citrus.core.away3d.Away3DCitrusEngine;
	import citrus.core.away3d.Away3DState;
	import citrus.objects.AwayPhysicsObject;
	import citrus.objects.platformer.awayphysics.Hero;
	import citrus.objects.platformer.awayphysics.Platform;
	import citrus.objects.platformer.awayphysics.Sensor;
	import citrus.physics.awayphysics.AwayPhysics;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;

	/**
	 * @author Aymeric
	 */
	public class Platformer3DGameState extends Away3DState {
		
		// navigation variables
		private var _cameraController:HoverController;

		private var _move:Boolean = false;
		private var _lastPanAngle:Number;
		private var _lastTiltAngle:Number;
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		private var _lookAtPosition:Vector3D = new Vector3D();

		public function Platformer3DGameState() {
			super();
		}

		override public function initialize():void {

			super.initialize();

			var awayPhysics:AwayPhysics = new AwayPhysics("AwayPhysics");
			awayPhysics.visible = true;
			add(awayPhysics);
			
			var floor:Platform = new Platform("floor", {width:600, height:0, depth:600});
			add(floor);
			
			var cube1:Mesh = new Mesh(new CubeGeometry(30, 60, 30), new ColorMaterial(0x0000FF));
			var hero:Hero = new Hero("hero", {height:60, y:30, view:cube1});
			add(hero);
			
			var sensor:Sensor = new Sensor("sensor", {z:150, y:50});
			add(sensor);
			
			var object:AwayPhysicsObject = new AwayPhysicsObject("object", {z:100, y:300});
			add(object);
			
			_cameraController = new HoverController((_ce as Away3DCitrusEngine).away3D.camera, null, 175, 20, 500);
			
			_ce.stage.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			_ce.stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
			_ce.stage.addEventListener(Event.MOUSE_LEAVE, _onMouseUp);
			_ce.stage.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
		}
		
		override public function destroy():void {

			_ce.stage.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			_ce.stage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
			_ce.stage.removeEventListener(Event.MOUSE_LEAVE, _onMouseUp);
			_ce.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
			
			super.destroy();
		}
		
		override public function update(timeDelta:Number):void {

			super.update(timeDelta);

			if (_move) {
				_cameraController.panAngle = 0.3 * (_ce.stage.mouseX - _lastMouseX) + _lastPanAngle;
				_cameraController.tiltAngle = 0.3 * (_ce.stage.mouseY - _lastMouseY) + _lastTiltAngle;
			}

			_cameraController.lookAtPosition = _lookAtPosition;
		}
		
		private function _onMouseDown(mEvt:MouseEvent):void {
			_lastPanAngle = _cameraController.panAngle;
			_lastTiltAngle = _cameraController.tiltAngle;
			_lastMouseX = _ce.stage.mouseX;
			_lastMouseY = _ce.stage.mouseY;
			_move = true;
		}

		private function _onMouseUp(evt:Event):void {
			_move = false;
		}

		private function _onMouseWheel(mEvt:MouseEvent):void {

			_cameraController.distance -= mEvt.delta * 5;

			if (_cameraController.distance < 100)
				_cameraController.distance = 100;
			else if (_cameraController.distance > 2000)
				_cameraController.distance = 2000;
		}
	}
}
