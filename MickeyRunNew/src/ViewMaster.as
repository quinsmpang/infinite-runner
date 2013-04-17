package
{
	import citrus.core.CitrusEngine;
	import citrus.core.IState;
	import citrus.core.starling.StarlingState;
	import citrus.objects.CitrusSprite;
	import citrus.objects.platformer.nape.Hero;
	import citrus.objects.platformer.nape.Sensor;
	import citrus.view.starlingview.AnimationSequence;
	import citrus.view.starlingview.StarlingArt;
	
	import objects.CustomBall;
	import objects.CustomCannonSensor;
	import objects.CustomCoin;
	import objects.CustomCrate;
	import objects.CustomEnemy;
	import objects.CustomMovingPlatform;
	import objects.CustomPlatform;
	import objects.CustomPortal;
	import objects.CustomPowerup;
	import objects.Particle;
	import objects.Pluto;
	import objects.pools.PoolParticle;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.events.Event;
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
			
			_context.startButton = new Button(Assets.getAtlas().getTexture("startButton"));
			_context.startButton.fontColor = 0xffffff;
		}
		
		public function init():void 
		{
			eatParticlesPool = new PoolParticle(eatParticleCreate, eatParticleClean, 20, 30);
			
			// Initialize particles-to-animate vectors.
			eatParticlesToAnimate = new Vector.<Particle>();
			eatParticlesToAnimateLength = 0;
			
//			var startButton:Button = _context.startButton;
			_context.startButton = new Button(Assets.getAtlas().getTexture("startButton"));
			_context.startButton.fontColor = 0xffffff;
			_context.startButton.x = CitrusEngine.getInstance().stage.stageWidth/2 - _context.startButton.width/2;
			_context.startButton.y = CitrusEngine.getInstance().stage.stageHeight/2 - _context.startButton.height/2;
			_context.startButton.addEventListener(Event.TRIGGERED, onStartButtonClick);
			( _state as StarlingState ).addChild(_context.startButton);
			_context.startButton.visible = false;
		}
		
		private function onStartButtonClick(event:Event):void
		{
			_context.startButton.removeEventListener(Event.TRIGGERED, onStartButtonClick);
			CitrusEngine.getInstance().state = new GameState( _context );
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
		
		public function addPortal( entryX:int, entryY:int, entryH:int, exitX:int, exitY:int ):void
		{
			var endLevel:Sensor = new CustomPortal( "portal", { x: entryX, y: entryY, height: entryH },
				_context, exitX, exitY );
			_state.add( endLevel );
		}
		
		public function addEnemy( x:int, y:int ):void {
			
			var enemyAnim:AnimationSequence = new AnimationSequence(Assets.getCharactersTextureAtlas(), 
				[ "petebwwalk_" ], 
				"petebwwalk_", 12, true, "none");
			
			var enemy:CustomEnemy = new CustomEnemy("enemy", {x:x, y:y,
				radius:60, view:enemyAnim, group:1}, _context, enemyAnim );
			_state.add(enemy);
		}
		
		public function addPluto( x:int, y:int ):void {
			
			var plutoAnim:AnimationSequence = new AnimationSequence(Assets.getCharactersTextureAtlas(), 
				[ "plutowalk_" ], 
				"plutowalk_", 12, true, "none");
			
			var pluto:Pluto = new Pluto("pluto", {x:x, y:y,
				radius:40, view:plutoAnim, group:1}, _context, plutoAnim );
			_state.add(pluto);
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
			
			width = 50; height = 50;

			var physicObject:CustomCannonSensor = new CustomCannonSensor("physicobject", 
				{ x:cannonX, y:coinY, width:width, height:height, view:image}, _context );
			_state.add(physicObject);	
		}
		
		public function addSprite( coinX:int, coinY:int, spriteName:String ):void {
			var image:Image;
			var width:int; var height:int;
			
			image = new Image( _miscTextureAtlas.getTexture( spriteName ) );
//			width = 35; height = 38;
			
			var physicObject:CitrusSprite = new CitrusSprite("powerup", 
				{ x:coinX, y:coinY, view:image} );
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
			if ( Math.random() > 0.2 ) {
				addSprite( platformX, platformY - 400, "tree" ); 
			}
			
			var numBushes:int = ( platWidth / 200 ) * Math.random();
			for (var i:int = 0; i < numBushes; i++) 
			{
				addSprite( platformX + ((platWidth/2) * Math.random()) - platWidth/4, platformY - 97, "bush" );
			}
			
						
			var textureName:String = "platformNew" + platWidth;
			var image:Image = new Image( _miscTextureAtlas.getTexture(textureName) );
//			image.scaleX = platWidth / 800;
			
//			image.rotation = rotation;
			
			var floor:CustomPlatform = new CustomPlatform("floor", {
				x: platformX, 
				y: platformY,
				width:platWidth, 
				height: 100//, 
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
//				addCannonSensor( floor.x + 100, floor.y - 70 ); 
//				addEnemy( floor.x + 100, floor.y - 300 ); 
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
		
		private var eatParticlesPool:PoolParticle;
		private var eatParticlesToAnimate:Vector.<Particle>;
		private var eatParticlesToAnimateLength:uint = 0;
		public function createEatParticle(itemToTrack:Hero, count:int = 2):void
		{
			var eatParticleToTrack:Particle;
			
			if ( eatParticlesToAnimateLength > 5 ) return;
			
			while (count > 0)
			{
				count--;
				
				// Create eat particle object.
				eatParticleToTrack = eatParticlesPool.checkOut();
				
				if (eatParticleToTrack)
				{
					// Set the position of the particle object with a random offset.
					eatParticleToTrack.x = itemToTrack.x + Math.random() * 40 - 20;
					eatParticleToTrack.y = itemToTrack.y + itemToTrack.height ;
					
					// Set the speed of a particle object. 
					eatParticleToTrack.speedY = Math.random() * 10 - 5;
					eatParticleToTrack.speedX = Math.random() * 2 + 1;
					
					// Set the spinning speed of the particle object.
					eatParticleToTrack.spin = Math.random() * 20 - 5;
					
					// Set the scale of the eat particle.
					eatParticleToTrack.view.scaleX = eatParticleToTrack.view.scaleY = Math.random() * 0.3 + 0.3;
					
					// Animate the eat particle.
					eatParticlesToAnimate[eatParticlesToAnimateLength++] = eatParticleToTrack;
				}
			}
		}
		
		private function eatParticleCreate():Particle
		{
			var eatParticle:Particle = new Particle("eatParticle", {typeParticle:GameConstants.PARTICLE_TYPE_1});
			eatParticle.x = 0;
			_state.add(eatParticle);
			
			return eatParticle;
		}
		
		private function eatParticleClean(eatParticle:Particle):void
		{
			eatParticle.x = 0;
		}
		
		public function disposeEatParticleTemporarily(animateId:uint, particle:Particle):void
		{
			eatParticlesToAnimate.splice(animateId, 1);
			eatParticlesToAnimateLength--;
			eatParticlesPool.checkIn(particle);
		}
		
		public function animateEatParticles():void
		{
			var eatParticleToTrack:Particle;
			
			for(var i:uint = 0;i < eatParticlesToAnimateLength;i++)
			{
				eatParticleToTrack = eatParticlesToAnimate[i];
				
				if (eatParticleToTrack)
				{
					eatParticleToTrack.view.scaleX -= 0.03;
					
					// Make the eat particle get smaller.
					eatParticleToTrack.view.scaleY = eatParticleToTrack.view.scaleX;
					// Move it horizontally based on speedX.
					eatParticleToTrack.y -= eatParticleToTrack.speedY; 
					// Reduce the horizontal speed.
					eatParticleToTrack.speedY -= eatParticleToTrack.speedY * 0.2;
					// Move it vertically based on speedY.
					eatParticleToTrack.x += eatParticleToTrack.speedX;
					// Reduce the vertical speed.
					eatParticleToTrack.speedX--; 
					
					// Rotate the eat particle based on spin.
					eatParticleToTrack.rotation += eatParticleToTrack.spin; 
					// Increase the spinning speed.
					eatParticleToTrack.spin *= 1.1; 
					
					// If the eat particle is small enough, remove it.
					if (eatParticleToTrack.view.scaleY <= 0.02)
					{
						disposeEatParticleTemporarily(i, eatParticleToTrack);
					}
				}
			}
		}
		
	}
}