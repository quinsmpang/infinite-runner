package objects {
	
	import citrus.objects.NapePhysicsObject;
	
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Polygon;
	
	import views.HillsTexture;
	
	/**
	 * This class creates perpetual hills like the games Tiny Wings, Ski Safari...
	 * Write a class to manage graphics, and extends this one to call graphics function.
	 * For more information, check out CE's Tiny Wings example.
	 * Thanks to <a href="http://www.lorenzonuvoletta.com/create-an-infinite-scrolling-world-with-starling-and-nape/">Lorenzo Nuvoletta</a>.
	 */
	public class CustomHills extends NapePhysicsObject {
		
		/**
		 * This is the height of a slice. 
		 */
		public var sliceHeight:uint = 600;
		
		/**
		 * This is the width of a slice. 
		 */
		public var sliceWidth:uint = 30;
		
		/**
		 * This is the height of the first point.
		 */
		public var currentYPoint:Number = 200;
		
		public var currentXPoint:Number = 0;
		/**
		 * This is the width of the hills visible. Most of the time your stage width. 
		 */
		public var widthHills:Number = 550;
		
		/**
		 * This is the physics object from which the Hills read its position and create/delete hills. 
		 */
		public var rider:NapePhysicsObject;
		
		protected var _slicesCreated:uint;
		protected var _currentAmplitude:Number;
		protected var _nextYPoint:Number;
		protected var _slicesInCurrentHill:uint;
		protected var _indexSliceInCurrentHill:uint;
		protected var _slices:Vector.<Body>;
		protected var _sliceVectorConstructor:Vector.<Vec2>;
		
		private var _context:GameContext;
		
		public function CustomHills(name:String, params:Object = null, context:GameContext = null ) {
			super(name, params);
			
			_context = context;
		}
		
		override public function initialize(poolObjectParams:Object = null):void {
			
			super.initialize(poolObjectParams);
			
			_prepareSlices();
		}
		
		protected function _prepareSlices():void {
			
			if (view)
				(view as HillsTexture).init(sliceWidth, sliceHeight);
			
			_slices = new Vector.<Body>();
			
			// Generate a rectangle made of Vec2
			_sliceVectorConstructor = new Vector.<Vec2>();
			_sliceVectorConstructor.push(new Vec2(0, sliceHeight));
			_sliceVectorConstructor.push(new Vec2(0, 0));
			_sliceVectorConstructor.push(new Vec2(sliceWidth, 0));
			_sliceVectorConstructor.push(new Vec2(sliceWidth, sliceHeight));
			
			// fill the stage with slices of hills
			for (var i:uint = 0; i < widthHills / sliceWidth * 1.2; ++i) {
				_createSlice();
			}
		}
		
		protected function _createSlice():void {
			
			// Every time a new hill has to be created this algorithm predicts where the slices will be positioned
			if (_indexSliceInCurrentHill >= _slicesInCurrentHill) {
				_slicesInCurrentHill = Math.random() * 10 + 10;
				_currentAmplitude = Math.random() * 60 - 20;
//				_slicesInCurrentHill = Math.random() * 30 + 30;
				// a slope that goes downward forever
//				_currentAmplitude = Math.random() * 20 + 30;
//				_currentAmplitude = ( Math.random() * 60 ) - 10;
//				_currentAmplitude = Math.random() * 30 - 10;
				if ( Math.random() > 0.8 ) {
//					_currentAmplitude = -10;
//					_slicesInCurrentHill = 10;
				}
				
				if ( currentYPoint < _ce.stage.stageHeight / 2 ) {
					_currentAmplitude = 50;
				} else if ( currentYPoint > _ce.stage.stageHeight * 3 ) {
					_currentAmplitude = -30;
				}
				
				_indexSliceInCurrentHill = 0;
				currentXPoint = 0;
			}
			// Calculate the position of the next slice
			//sin(x) + 3.5 * sin(x/2*pi) + 2 * cos(x/pi)
//			_nextYPoint = Math.sin(((Math.PI / 180) * (-1)));// + (3.5 * Math.sin(currentYPoint/2* Math.PI * (Math.PI/180))) + (Math.cos(180 * (currentYPoint))) ;
			
			// the standard equation:
//			_nextYPoint = currentYPoint + (Math.sin(((Math.PI / _slicesInCurrentHill) * _indexSliceInCurrentHill)) * _currentAmplitude);
			
			_nextYPoint = currentYPoint;// + (Math.sin((( ( Math.PI / 180 ) * currentYPoint) * _indexSliceInCurrentHill)) * _currentAmplitude);
			
			// generates 'sine wave' hills:
//			_nextYPoint = currentYPoint + (Math.sin(((Math.PI / 180 * _slicesInCurrentHill * 4) * _indexSliceInCurrentHill * 4)) * _currentAmplitude);
			
//			_nextYPoint = currentYPoint + (Math.sin( (Math.PI / 180 * 10) * _indexSliceInCurrentHill ) * _currentAmplitude);
			
			_sliceVectorConstructor[2].y = _nextYPoint - currentYPoint;
			var slicePolygon:Polygon = new Polygon(_sliceVectorConstructor);
//			slicePolygon.material = new Material( 0, 0.3, 0, 1, 0);
//			slicePolygon.material = Material.ice();
			_body = new Body(BodyType.STATIC);
			_body.userData.myData = this;
			_body.shapes.add(slicePolygon);
			_body.position.x = _slicesCreated * sliceWidth;
			_body.position.y = currentYPoint;
			_body.space = _nape.space;
			
			currentXPoint = _body.position.x;
			
			_pushHill();
		}
		
		protected function _pushHill():void {
			
			if (view)
				(view as HillsTexture).createSlice(_body, _nextYPoint, currentYPoint);
			
			_slicesCreated++;
			_indexSliceInCurrentHill++;
			currentYPoint = _nextYPoint;
			
			_slices.push(_body);
		}
		
		protected function _checkHills():void {
			
//			if (!rider)
//				rider = _ce.state.getFirstObjectByType(Hero) as Hero;
			
			var length:uint = _slices.length;
			
			for (var i:uint = 0; i < length; ++i) {
				
				if (rider.body.position.x - _slices[i].position.x > widthHills * 0.5 + 100) {
					
					if ( !_context.hasGameEnded ) {
						_deleteHill(i);
						--i;
						_createSlice();
					}
					
				} else
					break;
			}
		}
		
		protected function _deleteHill(index:uint):void {
			
			(view as HillsTexture).deleteHill(index);
			
			_nape.space.bodies.remove(_slices[index]);
			_slices.splice(index, 1);
		}
		
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			_checkHills();
		}
		
		/**
		 * Bodies are generated automatically, those functions aren't needed.
		 */
		override protected function defineBody():void {
		}
		
		override protected function createBody():void {
		}
		
		override protected function createMaterial():void {
		}
		
		override protected function createShape():void {
		}
		
		override protected function createFilter():void {
		}
		
		override protected function createConstraint():void {
		}
	}
}