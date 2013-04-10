package objectpooling {

	import citrus.core.State;
	import citrus.datastructures.DoublyLinkedListNode;
	import citrus.datastructures.PoolObject;
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Platform;
	import citrus.physics.nape.Nape;
	import citrus.view.spriteview.SpriteArt;

	import flash.utils.setTimeout;

	/**
	 * @author Aymeric
	 */
	public class ObjectPoolingGameState2 extends State {
		
		private var _poolPhysics:PoolObject;
		private var _poolGraphic:PoolObject;

		public function ObjectPoolingGameState2() {
			super();
		}

		override public function initialize():void {
			
			super.initialize();
			
			// THIS POOL OBJECT EXAMPLE IS NOT RENDERED BY THE STATE
			
			var nape:Nape = new Nape("nape");
			nape.visible = true;
			add(nape);
			
			add(new Platform("platformBot", {x:0, y:380, width:4000, height:20}));
			
			// the Citrus Engine separates physics from art so we use two PoolObjects.
			// all objects in a PoolObject must have the same type.
			// PoolObject isn't render through the state, you have to manage it in your GameState.
			_poolPhysics = new PoolObject(NapePhysicsObject, 50, 5, true);
			_poolGraphic = new PoolObject(SpriteArt, 50, 5, false);
			
			for (var i:uint = 0; i < 5; ++i) {
				
				var physicsNode:DoublyLinkedListNode = _poolPhysics.create({x:i * 40 + 60, view:"crate.png"});
				addChild(_poolGraphic.create(physicsNode.data).data);
				// in the SpriteArt class, we need the Citrus Object as an argument. That's why here it is physicsNode.data and not physicsNode.data.view
			}
			
			setTimeout(removeAndAddObjects, 3000);
		}
			
		override public function destroy():void {
			
			_poolPhysics.disposeAll();
			
			// for the graphic pool, we have to removeChild each object, it can't be made in the PoolObject since it's not a display object.
			while (_poolGraphic.head)
				removeChild(_poolGraphic.disposeNode(_poolGraphic.head).data);
			
			super.destroy();
		}
		
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			// update pool objects
			_poolPhysics.updatePhysics(timeDelta);
			_poolGraphic.updateArt(view);
		}
		
		public function removeAndAddObjects():void {
			
			_poolPhysics.disposeAll();
			
			while (_poolGraphic.head)
				removeChild(_poolGraphic.disposeNode(_poolGraphic.head).data);
				
			// reassign object
			for (var i:uint = 0; i < 7; ++i) {
				var physicsNode:DoublyLinkedListNode = _poolPhysics.create({x:i * 40 + 150, view:"muffin.png"});
				addChild(_poolGraphic.create(physicsNode.data).data);
			}
			
		}

	}
}
