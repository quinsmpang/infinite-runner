package {
	
	
	import citrus.objects.NapePhysicsObject;
	
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Polygon;
	
	/**
	 * @author Aymeric
	 * <p>This is a class created by the software http://www.physicseditor.de/</p>
	 * <p>Just select the CitrusEngine template, upload your png picture, set polygons and export.</p>
	 * <p>Be careful, the registration point is topLeft !</p>
	 * @param peObject : the name of the png file
	 */
	public class PhyEPlatform285 extends NapePhysicsObject {
		
		[Inspectable(defaultValue="")]
		public var peObject:String = "";
		
		private var _tab:Array;
		private var _hero:MickeyHero;
		
		public function PhyEPlatform285(name:String, params:Object = null, _hero:MickeyHero=null ) {
			
			this._hero = _hero;
			super(name, params);
			
			_body.position.x = this.x;
			_body.position.y = this.y;
		}
		
		override public function destroy():void {
			
			super.destroy();
		}
		
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			if ( _hero != null ) {
				if (_hero.x - this.x > 200 ) {
					this._ce.state.remove(this);
					this.destroy();
					//				trace( "removed body" + this.x );
				}
				
//				this.x = _hero.x + 100;
			}
		}
		
		override protected function createShape():void {
			
			_createVertices();
			
			_body = new Body(BodyType.STATIC);
			_body.userData.myData = this;
			
			for (var i:uint = 0; i < _tab.length; ++i) {
				
				var polygonShape:Polygon = new Polygon(_tab[i]);
				_shape = polygonShape;
				_body.shapes.add(_shape);
			}
			
			_body.translateShapes(Vec2.weak(-_body.bounds.width * 0.5, -_body.bounds.height * 0.5));
			
			_body.position.x = this.x;
			_body.position.y = this.y;
			
			_body.position.x += _body.bounds.width * 0.5;
			_body.position.y += _body.bounds.height * 0.5;
		}
		
		override protected function createMaterial():void {
			
			_material = new Material();
		}
		
		protected function _createVertices():void {
			
			_tab = [];
			var vertices:Array = [];
			
			vertices.push(Vec2.weak(264, 35.5));
			vertices.push(Vec2.weak(51, 37.5));
			vertices.push(Vec2.weak(58, 2.5));
			vertices.push(Vec2.weak(256, 3.5));
			vertices.push(Vec2.weak(273.5, 7));
			vertices.push(Vec2.weak(280.5, 22));
			
			_tab.push(vertices);
			vertices = new Array();
			
			vertices.push(Vec2.weak(13, 6.5));
			vertices.push(Vec2.weak(58, 2.5));
			vertices.push(Vec2.weak(51, 37.5));
			vertices.push(Vec2.weak(9, 35));
			vertices.push(Vec2.weak(4, 17));
			
			_tab.push(vertices);
		}
		
		protected function _getDensity():Number {
			return 1;
		}
		
		protected function _getFriction():Number {

			return 0.6;
		}
		
		protected function _getRestitution():Number {

			return 0.3;
		}
	}
}