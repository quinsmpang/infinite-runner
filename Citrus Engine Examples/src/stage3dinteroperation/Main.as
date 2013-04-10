package stage3dinteroperation {

	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.events.Stage3DEvent;

	import away3dbox2d.Away3DGameState;

	import citrus.core.away3d.Away3DCitrusEngine;

	import starling.core.Starling;

	import flash.events.Event;


	[SWF(frameRate="60")]

	/**
	 * @author Aymeric
	 */
	public class Main extends Away3DCitrusEngine {
		
		public var stage3DManager:Stage3DManager;
		public var stage3DProxy:Stage3DProxy;
		
		public var starlingSceneBack:Starling;
		public var starlingSceneFront:Starling;

		public function Main() {

			stage3DManager = Stage3DManager.getInstance(stage);

			// Create a new Stage3D proxy to contain the separate views
			stage3DProxy = stage3DManager.getFreeStage3DProxy();
			stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, _onContextCreated);
			stage3DProxy.antiAlias = 8;
			stage3DProxy.color = 0x0;
		}

		private function _onContextCreated(evt:Stage3DEvent):void {
			
			setUpAway3D(true, 4, null, stage3DProxy);

			state = new Away3DGameState();
			
			starlingSceneBack = new Starling(StarlingBG, stage, stage3DProxy.viewPort, stage3DProxy.stage3D);
			starlingSceneFront = new Starling(StarlingFront, stage, stage3DProxy.viewPort, stage3DProxy.stage3D);
		}

		override protected function handleEnterFrame(e:Event):void {
			
			starlingSceneBack.nextFrame();
			
			super.handleEnterFrame(e);
			
			starlingSceneFront.nextFrame();
		}
	}
}