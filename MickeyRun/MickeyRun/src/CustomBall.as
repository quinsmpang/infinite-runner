package
{
	import citrus.objects.platformer.nape.Crate;
	
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	
	public class CustomBall extends Crate
	{
		private var origX:int = 0;
		private var _hero:MickeyHero = null;
		
		public function CustomBall(name:String, params:Object=null, _hero:MickeyHero=null )
		{
			super(name, params);
			origX = this.x;
			this._hero = _hero;
			//			this._body.mass += 500;
//			this._body.mass /= 4;
			trace( "ball mass: " + this._body.mass );
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			if (_hero.x - this.x > 400 ) {
				this._ce.state.remove(this);
				this.destroy();
				//trace( "removed body" + this.x );
			}
		}
		
		override protected function createShape():void {
			
			trace( "ball mass: " + this._body.mass );
			_material = new Material( 10 );
//			_material = Material.rubber();
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