package {

    import Box2DAS.Collision.Shapes.b2PolygonShape;
	import Box2DAS.Common.V2;

	import com.citrusengine.objects.PhysicsObject;

	/**
	 * @author Aymeric
	 * <p>This is a class created by the software http://www.physicseditor.de/</p>
	 * <p>Just select the CitrusEngine template, upload your png picture, set polygons and export.</p>
	 * <p>Be careful, the registration point is topLeft !</p>
	 * @param peObject : the name of the png file
	 */
    public class PhysicsEditorObjects extends PhysicsObject {
		
		[Inspectable(defaultValue="")]
		public var peObject:String = "";

		private var _tab:Array;

		public function PhysicsEditorObjects(name:String, params:Object = null) {

			super(name, params);
		}

		override public function destroy():void {

			super.destroy();
		}

		override public function update(timeDelta:Number):void {

			super.update(timeDelta);
		}

		override protected function defineFixture():void {
			
			super.defineFixture();
			
			_createVertices();

			_fixtureDef.density = _getDensity();
			_fixtureDef.friction = _getFriction();
			_fixtureDef.restitution = _getRestitution();
			
			for (var i:uint = 0; i < _tab.length; ++i) {
				var polygonShape:b2PolygonShape = new b2PolygonShape();
				polygonShape.Set(_tab[i]);
				_fixtureDef.shape = polygonShape;

				body.CreateFixture(_fixtureDef);
			}
		}
		
        protected function _createVertices():void {
			
			_tab = [];
			var vertices:Vector.<V2> = new Vector.<V2>();

			switch (peObject) {
				
				case "bite sized 1":
											
			        vertices.push(new V2(-28/_box2D.scale, 486/_box2D.scale));
					vertices.push(new V2(-28/_box2D.scale, 446/_box2D.scale));
					vertices.push(new V2(768/_box2D.scale, 436/_box2D.scale));
					
					_tab.push(vertices);
											
			        vertices.push(new V2(1292/_box2D.scale, 350/_box2D.scale));
					vertices.push(new V2(1278/_box2D.scale, 460/_box2D.scale));
					vertices.push(new V2(866/_box2D.scale, 430/_box2D.scale));
					
					_tab.push(vertices);
											
			        vertices.push(new V2(0/_box2D.scale, 772/_box2D.scale));
					vertices.push(new V2(-30/_box2D.scale, 722/_box2D.scale));
					vertices.push(new V2(1350/_box2D.scale, 710/_box2D.scale));
					
					_tab.push(vertices);
					
					break;
			
			}
		}

		protected function _getDensity():Number {

			switch (peObject) {
				
				case "bite sized 1":
					return 1;return 1;return 1;
					break;
			
			}

			return 1;
		}
		
		protected function _getFriction():Number {
			
			switch (peObject) {
				
				case "bite sized 1":
					return 0.6;return 0.6;return 0.6;
					break;
			
			}

			return 0.6;
		}
		
		protected function _getRestitution():Number {
			
			switch (peObject) {
				
				case "bite sized 1":
					return 0.3;return 0.3;return 0.3;
					break;
			
			}

			return 0.3;
		}
	}
}
