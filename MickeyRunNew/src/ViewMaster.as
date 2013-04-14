package
{
	import citrus.core.IState;
	
	import objects.CustomBall;
	import objects.CustomCannonSensor;
	import objects.CustomCoin;
	import objects.CustomCrate;
	import objects.CustomMovingPlatform;
	import objects.CustomPlatform;
	import objects.CustomPowerup;
	
	import starling.display.Image;
	import starling.textures.TextureAtlas;
	

	public class ViewMaster
	{
		private var _miscTextureAtlas:TextureAtlas;
		private var _context:GameContext;
		private var _state:IState;
		
		public function ViewMaster( context:GameContext, state:IState )
		{
			_context = context;
			_state = state;
			_miscTextureAtlas = Assets.getMiscAtlas();
		}
		
		public function setState( state:IState ):void
		{
			_state = state;
		}
		
		public function addBall( addLargeBall:Boolean = false, x:int=-1, y:int=-1 ):void {
			var image:Image;
			var width:int; var height:int;
			
			if ( addLargeBall ) {
				image = new Image( _miscTextureAtlas.getTexture("large_ball") );
				width = 100; height = 100;
			} else {
				image = new Image( _miscTextureAtlas.getTexture("ball") );
				width = 50; height = 50;
			}
			
			var physicObject:CustomBall = new CustomBall("physicobject", 
				{ x:x, y:y, width:width, height:height, view:image}, _context );
			_state.add(physicObject);	
		}
		
		public function addCrate(addSmallCrate:Boolean, veryLargeCrate:Boolean=false, x:int=-1, y:int=-1 ):CustomCrate {
			var image:Image;
			var width:int; var height:int;
			
			if ( addSmallCrate ) {
				image = new Image( _miscTextureAtlas.getTexture("small_crate") );
				width = 35; height = 38;
			} else if ( veryLargeCrate ) {
				image = new Image( _miscTextureAtlas.getTexture("very_large_crate") );
				width = 140; height = 152;
			} else {
				image = new Image( _miscTextureAtlas.getTexture("large_crate") );
				width = 70; height = 76;
			}
			
			var physicObject:CustomCrate = new CustomCrate("physicobject", { 
				x:x, y:y, width:width, height:height, view:image}, _context );
			_state.add(physicObject);	
			
			return physicObject;
		}
		
		public function addCoin( coinX:int, coinY:int, largeCoin:Boolean=false ):void {
			var image:Image;
			var width:int; var height:int;
			
			image = new Image( _miscTextureAtlas.getTexture("coin") );
			
			if ( !largeCoin ) {
				width = 40; height = 40;
			} else {
				image.scaleX = image.scaleY = 2;
				width = 80; height = 80;
			}

			var physicObject:CustomCoin = new CustomCoin("physicobject", 
				{ x:coinX, y:coinY, width:width, height:height, view:image}, _context );
			_state.add(physicObject);	
		}
		
		public function addCannonSensor( cannonX:int, coinY:int ):void {
			var image:Image;
			var width:int; var height:int;
			
			image = new Image( _miscTextureAtlas.getTexture("cannon") );
			
//			image.scaleX = image.scaleY = 2;
			width = 102; height = 156;

			var physicObject:CustomCannonSensor = new CustomCannonSensor("physicobject", 
				{ x:cannonX, y:coinY, width:width, height:height, view:image}, _context );
			_state.add(physicObject);	
		}
		
		public function addPowerup( coinX:int, coinY:int ):void {
			var image:Image;
			var width:int; var height:int;
			
			image = new Image( _miscTextureAtlas.getTexture("small_crate") );
			width = 35; height = 38;
			
			var physicObject:CustomPowerup = new CustomPowerup("powerup", 
				{ x:coinX, y:coinY, width:width, height:height, view:image}, _context );
			_state.add(physicObject);	
		}
		
		public function addPlatform( platformX:int=0, platWidth:int=0, 
									  platformY:int=0, ballAdd:Boolean=false, friction:Number=10,
									coinAdd:Boolean=false, rotation:Number=0 ):CustomPlatform {
			var textureName:String = "platformNew800";
			var image:Image = new Image( _miscTextureAtlas.getTexture(textureName) );
			image.scaleX = platWidth / 800;
			
//			image.rotation = rotation;
			
			var floor:CustomPlatform = new CustomPlatform("floor", {
				x: platformX, 
				y: platformY,
				width:platWidth, 
				height: 50//, 
//				friction:friction 
			}, _context);
			floor.view = image;
			
			floor.body.rotation = rotation;
			
			floor.oneWay = true;
			_state.add(floor);
			
			if ( ballAdd ) {
				addBall( false, floor.x + 200, floor.y - 100 );
			}
			
			if ( coinAdd ) {
				addCannonSensor( floor.x + 100, floor.y - 70 ); 
			}

			return floor;
		}
		
		public function addMovingPlatform( x:int, y:int, endX:int, endY:int, platWidth:int, 
										   friction:Number=1, wait:Boolean=true, speed:int=50 ):void {
			var textureName:String = "platformNew800";
			var image:Image = new Image( _miscTextureAtlas.getTexture(textureName) );
			image.scaleX = platWidth / 800;
			
			var floor:CustomMovingPlatform = new CustomMovingPlatform("moving1", 
				{x:x, y:y, width:platWidth,
					startX:x, startY:y, endX: endX, endY:endY, height: 50, friction:friction },
				_context );
			floor.view = image;
			floor.speed = speed;
			floor.waitForPassenger = wait;
			floor.enabled = true;
			_state.add(floor);
		}
	}
}