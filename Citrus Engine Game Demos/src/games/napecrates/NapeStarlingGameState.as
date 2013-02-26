package  games.napecrates
{
	
	import citrus.core.starling.StarlingState;
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Platform;
	import citrus.physics.nape.Nape;
	
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author Aymeric
	 */
	public class NapeStarlingGameState extends StarlingState 
	{
		[Embed(source="/../embed/small_crate.png")]
		private var _cratePng:Class;
		
		public function NapeStarlingGameState() 
		{
			super();
		}
		
		override public function initialize():void {
			
			super.initialize();
			
			var nape:Nape = new Nape("nape");
			//nape.visible = true;
			add(nape);
			
			add(new Platform("borderBottom", { x:0, y:stage.stageHeight - 10, width:stage.stageWidth, height:10 } ));
			add(new Platform("borderLeft", { x:0, y:0, width:10, height:stage.stageHeight } ));
			add(new Platform("borderRight", { x:stage.stageWidth - 10, y:0, width:10, height:stage.stageHeight } ));
			
			stage.addEventListener(TouchEvent.TOUCH, _addObject);
		}
		
		private function _addObject(tEvt:TouchEvent):void {
			
			var touch:Touch = tEvt.getTouch(stage, TouchPhase.BEGAN);
			
			if (touch) {
				
				var image:Image = new Image(Texture.fromBitmap(new _cratePng()));
			
				var physicObject:NapePhysicsObject = new NapePhysicsObject("physicobject", { x:touch.getLocation(this).x, y:touch.getLocation(this).y, width:35, height:38, view:image} );
				add(physicObject);
			}
			
		}
		
	}

}