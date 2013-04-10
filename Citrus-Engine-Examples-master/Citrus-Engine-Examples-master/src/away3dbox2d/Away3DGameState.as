package away3dbox2d {

	import away3d.controllers.HoverController;
	import away3d.entities.Mesh;
	import away3d.library.AssetLibrary;
	import away3d.loaders.parsers.MD2Parser;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.SphereGeometry;

	import citrus.core.away3d.Away3DCitrusEngine;
	import citrus.core.away3d.Away3DState;
	import citrus.math.MathVector;
	import citrus.objects.Box2DPhysicsObject;
	import citrus.objects.CitrusSprite;
	import citrus.objects.platformer.box2d.Coin;
	import citrus.objects.platformer.box2d.Hero;
	import citrus.objects.platformer.box2d.Platform;
	import citrus.physics.box2d.Box2D;
	import citrus.view.ACitrusView;
	import citrus.view.away3dview.AnimationSequence;
	import citrus.view.away3dview.Away3DArt;
	import citrus.view.away3dview.Away3DView;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	/**
	 * @author Aymeric
	 */
	public class Away3DGameState extends Away3DState {

		[Embed(source="/../embed/3D/pknight3.png")]
		public static var PKnightTexture3:Class;

		[Embed(source="/../embed/3D/pknight.md2", mimeType="application/octet-stream")]
		public static var PKnightModel:Class;

		// navigation variables
		private var _cameraController:HoverController;

		private var _move:Boolean = false;
		private var _lastPanAngle:Number;
		private var _lastTiltAngle:Number;
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		private var _lookAtPosition:Vector3D = new Vector3D();

		private var _heroArt:AnimationSequence;
		private var _hero:Hero;

		private var _clickMe:Sprite;

		public function Away3DGameState() {
			super();
		}

		override public function initialize():void {

			super.initialize();

			var box2D:Box2D = new Box2D("box2D");
			//box2D.visible = true;
			add(box2D);

			AssetLibrary.enableParser(MD2Parser);
			_heroArt = new AnimationSequence(new PKnightModel(), new PKnightTexture3());
			_heroArt.scale(2);

			var cube1:Mesh = new Mesh(new CubeGeometry(300, 300, 0), new ColorMaterial(0x0000FF));
			var cube2:Mesh = new Mesh(new SphereGeometry(15), new ColorMaterial(0xFFFF00));
			var cube3:Mesh = new Mesh(new CubeGeometry(2500, 10, 300), new ColorMaterial(0xFFFFFF));

			var cloud:CitrusSprite = new CitrusSprite("cloud", {x:150, y:50, width:300, height:300, view:cube1, parallaxX:0.3, parallaxY:0.3});
			add(cloud);
			(view.getArt(cloud) as Away3DArt).z = 300;
			// equivalent to -> cube1.z = 300;

			add(new Platform("platformBottom", {x:_ce.stage.stageWidth / 2, y:_ce.stage.stageHeight - 30, width:2500, height:10, view:cube3}));

			_hero = new Hero("hero", {x:150, y:50, width:80, height:90, view:_heroArt});
			add(_hero);

			var coin:Coin = new Coin("coin", {x:300, y:200, width:30, height:30, view:cube2});
			add(coin);

			view.camera.setUp(_hero, new MathVector(320, 240), new Rectangle(0, 0, 1550, 450), new MathVector(.25, .05));
			_cameraController = new HoverController((_ce as Away3DCitrusEngine).away3D.camera, null, 175, 20, 500);

			_clickMe = new Sprite();
			_clickMe.y = _ce.stage.stageHeight - 50;
			_ce.stage.addChild(_clickMe);
			_clickMe.graphics.beginFill(0xFF0000);
			_clickMe.graphics.drawRect(10, 0, 40, 40);
			_clickMe.graphics.endFill();
			_clickMe.buttonMode = true;

			_ce.stage.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			_ce.stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
			_ce.stage.addEventListener(Event.MOUSE_LEAVE, _onMouseUp);
			_ce.stage.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);

			_clickMe.addEventListener(MouseEvent.CLICK, _addBoxes);
		}

		// Make sure and call this override to specify Away3D view.
		override protected function createView():ACitrusView {

			return new Away3DView(this, "2D");
		}

		override public function destroy():void {

			_ce.stage.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			_ce.stage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
			_ce.stage.removeEventListener(Event.MOUSE_LEAVE, _onMouseUp);
			_ce.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);

			_clickMe.addEventListener(MouseEvent.CLICK, _addBoxes);
			_ce.stage.removeChild(_clickMe);

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

		private function _addBoxes(mEvt:MouseEvent):void {
			add(new Box2DPhysicsObject("box" + new Date().time, {x:Math.random() * _ce.stage.stageWidth, view:new Mesh(new CubeGeometry(30, 30, 30), new ColorMaterial(Math.random() * 0xFFFFFF))}));
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
