package objectpooling {

	import citrus.core.State;
	import citrus.datastructures.PoolObject;
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Platform;
	import citrus.physics.nape.Nape;

	import flash.utils.setTimeout;

	/**
	 * @author Aymeric
	 */
	public class ObjectPoolingGameState extends State {
		
		private var _poolObject:PoolObject;

		public function ObjectPoolingGameState() {
			super();
		}

		override public function initialize():void {
			
			super.initialize();
			
			var nape:Nape = new Nape("nape");
			nape.visible = true;
			add(nape);
			
			add(new Platform("platformBot", {x:0, y:380, width:4000, height:20}));
			
			// all objects in a PoolObject must have the same type.
			_poolObject = new PoolObject(NapePhysicsObject, 50, 5, true);
			
			addPoolObject(_poolObject);
			
			for (var i:uint = 0; i < 5; ++i)
				_poolObject.create({x:i * 40 + 60, view:"crate.png"});
			
			refreshPoolObjectArt(_poolObject);
			
			setTimeout(removeAndAddObjects, 3000);
		}
		
		public function removeAndAddObjects():void {
			
			refreshPoolObjectArt(_poolObject, _poolObject.length);
			_poolObject.disposeAll();
				
			// reassign object
			for (var i:uint = 0; i < 7; ++i)
				_poolObject.create({x:i * 40 + 150, view:"muffin.png"});
			
			refreshPoolObjectArt(_poolObject);
		}

	}
}
