package objects
{
	import citrus.objects.platformer.nape.Crate;
	
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	
	public class CustomBall extends Crate
	{
		private var _context:GameContext = null;
		
		public function CustomBall(name:String, params:Object=null, context:GameContext=null )
		{
			super(name, params);
			this._context = context;
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
//			if ( this.x + this.width < _context.viewCamLeftX ) {
//				this.kill = true;
//			}
			_body.velocity.x = _inverted ? -100 : 100;
		}
		
		public function turn( left:Boolean=true ):void
		{
			_inverted = !left;
		}
		
		override protected function createShape():void {
			
			_material = new Material( 10 );
			_radius = _width/2;
			if (_radius != 0)
				_shape = new Circle(_radius, null, _material);
			else
				_shape = new Polygon(Polygon.box(_width, _height), _material);
			
			_body.shapes.add(_shape);
		}
		
		public function destroyThis():void {
			this._ce.state.remove( this );
			this.destroy();
		}
	}
}