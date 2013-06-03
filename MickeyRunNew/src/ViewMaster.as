package
{
	import com.playdom.gas.AnimList;
	import com.playdom.gas.anims.Normalizer;
	import com.playdom.gas.anims.Path;
	
	import flash.geom.Point;
	
	import citrus.core.CitrusEngine;
	import citrus.core.IState;
	import citrus.core.starling.StarlingState;
	import citrus.objects.CitrusSprite;
	import citrus.objects.platformer.nape.Hero;
	import citrus.objects.platformer.nape.Sensor;
	import citrus.view.starlingview.AnimationSequence;
	
	import objects.CustomBall;
	import objects.CustomCannonSensor;
	import objects.CustomCoin;
	import objects.CustomCrate;
	import objects.CustomEnemy;
	import objects.CustomMovingPlatform;
	import objects.CustomPlatform;
	import objects.CustomPortal;
	import objects.CustomPowerup;
	import objects.CustomSwitch;
	import objects.CustomVerticalPlatform;
	import objects.Particle;
	import objects.Pluto;
	import objects.pools.PoolParticle;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	import steamboat.data.metadata.MetaData;
	import steamboat.data.metadata.RowData;
	
	import views.GameBackground;
	

	public class ViewMaster
	{
		public var _mobileInput:TouchInput;
		private var _miscTextureAtlas:TextureAtlas;
		private var _context:GameContext;
		private var _state:IState;
		
		public var _cameraTracker:CitrusSprite;
		
		/** Game background object. */
		private var bg:GameBackground;

		public function ViewMaster( context:GameContext, state:IState )
		{
			_context = context;
			_state = state;
			_miscTextureAtlas = Assets.getMiscAtlas();
			
//			_context.startButton = new Button(Assets.getMiscAtlas().getTexture("button1"));
//			_context.startButton = new Button(Assets.getAtlas().getTexture("startButton"));
//			_context.startButton.fontColor = 0xffffff;
			starColorTexture = Assets.getMiscAtlas().getTexture( "star2small" );
			starBWTexture = Assets.getMiscAtlas().getTexture( "star2bwsmall" );
		}
		
		public function scaleTextures( animSequence:AnimationSequence, animArray:Array ):void
		{
			var mc:MovieClip;
			for each ( var anim:String in animArray )
			{
				mc = animSequence.mcSequences[ anim ] as MovieClip;
				mc.scaleX = _context.TEXTURE_SCALE;
				mc.scaleY = _context.TEXTURE_SCALE;
			}
			
		}
		
		private function createButton( buttonNum:int, x:int, y:int=-1 ):Button
		{
			var button:Button = new Button(Assets.getMiscAtlas().getTexture( "button" + buttonNum ));
			
			button.name = "button" + buttonNum;
//			button.fontColor = 0xffffff;
			
			button.x = CitrusEngine.getInstance().stage.stageWidth/2 - button.width/2 + x;
			
			if ( y == -1 ) {
				button.y = CitrusEngine.getInstance().stage.stageHeight/2 - button.height/2;
			}
			
			button.addEventListener( Event.TRIGGERED, onLevelButtonClick );
			( _state as StarlingState ).addChild( button );
			button.visible = false;
			
			var offset:int = ( buttonNum - 1 ) * 3;
			var starY:int = button.y + button.height;
			var starX:int = button.x + button.width / 2 - 12;
			createStar( 1 + offset - 1, starX - 25, starY, false );
			createStar( 2 + offset - 1, starX, starY, false );
			createStar( 3 + offset - 1, starX + 25, starY, false );
			
			return button;
		}
		
		private var stars:Array = [];
		private var starColorTexture:Texture;
		private var starBWTexture:Texture;
		// create stars under each button
		private function createStar( i:int, x:int, y:int, color:Boolean=false ):Image
		{
			stars[i] = new Image( color ? starColorTexture : starBWTexture );
			var image:Image = stars[ i ] as Image;
			
			image.x = x;
			image.y = y;
			image.width = 20;
			image.height = 19;
			
			image.visible = false;
			( _state as StarlingState ).addChild( image );
			return image;
		}
		
		// show stars under each button
		public function showStars( show:Boolean ):void
		{
			var image:Image;
			for (var i:int = 0; i < stars.length; i++) 
			{
				image = stars[ i ] as Image;
				if ( image ) image.visible = show;
			}
			
		}
		
		// set stars for each button
		public function setStars( buttonNum:int, numStars:int ):void
		{
			var image:Image;
			var offset:int = ( buttonNum - 1 ) * 3;
			for (var i:int = 0; i < 3; i++) 
			{
				image = stars[ i + offset ] as Image;
				if ( image ) {
					image.texture = ( i <= numStars - 1 ) ? starColorTexture : starBWTexture;
				}
			}
		}
		
		public function init():void 
		{
			_mobileInput = new TouchInput();
			_mobileInput.initialize();
			
			eatParticlesPool = new PoolParticle(eatParticleCreate, eatParticleClean, 20, 30);
			
			// Initialize particles-to-animate vectors.
			eatParticlesToAnimate = new Vector.<Particle>();
			eatParticlesToAnimateLength = 0;
			
			_context.levelButton1 = createButton( 1, -300 );
			setStars( 1, _context.levelNumStars[ 1 ] );
			
			_context.levelButton2 = createButton( 2, 0 );
			setStars( 2, _context.levelNumStars[ 2 ] );
			
			_context.levelButton3 = createButton( 3, +300 );
			setStars( 3, _context.levelNumStars[ 3 ] );
			
			_context.startButton = new Button(Assets.getAtlas().getTexture("startButton"));
			_context.startButton.x = CitrusEngine.getInstance().stage.stageWidth/2 - _context.startButton.width/2;
			_context.startButton.y = CitrusEngine.getInstance().stage.stageHeight/2 - _context.startButton.height/2;
			_context.startButton.addEventListener(Event.TRIGGERED, onStartButtonClick);
			( _state as StarlingState ).addChild(_context.startButton);
			_context.startButton.visible = false;
			
			_context.pauseButton = new Button(Assets.getAtlas().getTexture("pauseButton"));
			_context.pauseButton.scaleX = _context.pauseButton.scaleY = 1.5;			_context.pauseButton.x = CitrusEngine.getInstance().stage.stageWidth - _context.pauseButton.width - 20;
			_context.pauseButton.y = 20;//CitrusEngine.getInstance().stage.stageHeight/2 - _context.pauseButton.height/2;
//			_context.pauseButton.y = CitrusEngine.getInstance().stage.stageHeight/2 - _context.pauseButton.height/2;
//			_context.pauseButton.addEventListener(Event.TRIGGERED, onPauseButtonClick);
			_context.pauseButton.addEventListener(TouchEvent.TOUCH, onPauseButtonClick);
			( _state as StarlingState ).addChild(_context.pauseButton);
			_context.pauseButton.visible = true;
		}
		
		public function addBackground():void
		{
			if ( bg == null ) {
				bg = new GameBackground("background", null, _context._mickey, true, _context);
			}
			_state.add(bg);
		}
		
		private function onPauseButtonClick(event:TouchEvent):void
		{
			var touchStart:Touch = event.getTouch( _context.pauseButton, TouchPhase.BEGAN);
			
			if ( touchStart ) {
				event.stopImmediatePropagation();
				_context.pauseGame();
			}
		}
		
		private function onStartButtonClick(event:Event):void
		{
			CitrusEngine.getInstance().playing = true;
			_context.startButton.visible = false;
			_context.pauseButton.visible = true;
		}
		
		private function onLevelButtonClick(event:Event):void
		{
//			_context.startButton.removeEventListener(Event.TRIGGERED, onStartButtonClick);
			
			if ( event.target is Button ) {
				var btn:Button = event.target as Button;
				for ( var i:int = 1; i <= 3; i++ ) 
				{
					if ( btn.name == "button" + i ) {
						var rowData:RowData = MetaData.getSheetData( "Levels" ).findValue( "seq", i );
						if ( rowData ) {
							_context.currentLevel = rowData.uid;
						}
					}
				}
				
			}
			
			_context.levelButton1.removeEventListener( Event.TRIGGERED, onLevelButtonClick );
			_context.levelButton2.removeEventListener( Event.TRIGGERED, onLevelButtonClick );
			_context.levelButton3.removeEventListener( Event.TRIGGERED, onLevelButtonClick );
			
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
		
		public function addPortal( entryX:int, entryY:int, entryH:int, exitX:int, exitY:int, width:int=20, height:int=200 ):void
		{
			var endLevel:Sensor = new CustomPortal( "portal", { x: entryX, y: entryY, height: height, width: width },
				_context, exitX, exitY );
			_state.add( endLevel );
		}
		
		public function addEnemy( x:int, y:int ):void {
			
			var enemyAnimArray:Array = [ "petebwwalk_" ];
			var enemyAnim:AnimationSequence = new AnimationSequence(Assets.getCharactersTextureAtlas(), 
				enemyAnimArray, 
				"petebwwalk_", 12, true, "none");
			
			_context.viewMaster.scaleTextures( enemyAnim, enemyAnimArray );
			
			var enemy:CustomEnemy = new CustomEnemy("enemy", {x:x, y:y,
				radius:60, view:enemyAnim, group:1}, _context, enemyAnim );
			_state.add(enemy);
		}
		
		public function addPluto( x:int, y:int ):void {
			
			var plutoAnimArray:Array = [ "plutowalk_", "plutohappy_" ];
			var plutoAnim:AnimationSequence = new AnimationSequence(Assets.getCharactersTextureAtlas(), 
				plutoAnimArray, 
				"plutohappy_", 12, true );
			
			_context.viewMaster.scaleTextures( plutoAnim, plutoAnimArray );
			
			var pluto:Pluto = new Pluto("pluto", {x:x, y:y,
				radius:32, view:plutoAnim, group:1}, _context, plutoAnim );
			
			pluto.body.gravMass = 4;
			_context._pluto = pluto;
			
			_state.add(pluto);
		}
		
		public function addCrate(addSmallCrate:Boolean, veryLargeCrate:Boolean=false, 
								 x:int=-1, y:int=-1, spawnItem:String=null ):CustomCrate {
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
				x:x, y:y, width:width, height:height, view:image}, _context, spawnItem );
			_state.add(physicObject);	
			
			return physicObject;
		}
		
		public function addStar( starX:int, starY:int, bw:Boolean=false, secondPos:Point=null ):void {
			var image:Image;
			var width:int; var height:int;
			
			if ( !bw ) {
				image = new Image( _miscTextureAtlas.getTexture("star2") );
			} else {
				image = new Image( _miscTextureAtlas.getTexture("star2bw") );
			}
			
			width = 50; height = 47;

			var physicObject:CustomCoin = new CustomCoin("star", 
				{ x:starX, y:starY, width:width, height:height, view:image}, _context );
			_state.add(physicObject);	
			
			if ( secondPos && secondPos.x != 0 && secondPos.y != 0 )
			{
				var dur:int = Math.random() * 1000 + 500;
				var alist:AnimList = _context.animControl.attachAnimList( physicObject );
				var path:Path = Path.make( alist, physicObject.x - 100, physicObject.y, 700, dur );
				path.osc = true;
				path.easing = Normalizer.EASE_BOTH;
			}
		}
		
		public function addSwitch( switchX:int, switchY:int, doorId:String ):void {
			var width:int; var height:int;
			width = 26; height = 26;

			var physicObject:CustomSwitch = new CustomSwitch("switch", 
				{ x:switchX, y:switchY, width:width, height:height }, _context, doorId );
			_state.add(physicObject);	
		}
		
		public function addCannonSensor( cannonX:int, coinY:int ):void {
			var image:Image;
			var width:int; var height:int;
			
			width = 100; height = 20;

			var physicObject:CustomCannonSensor = new CustomCannonSensor("spring", 
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
		
		public function addFire( platID:String, x:int=0, y:int=0 ):void
		{
			var fireAnim:AnimationSequence = new AnimationSequence( _miscTextureAtlas, 
				[ "fire_" ], "fire_", 8, true );
			
			var fire:CitrusSprite = new CitrusSprite( platID, {
				x: x,
				y: y,
				view: fireAnim
			});
			
			_state.add( fire );
		}
		
		public function addVerticalPlatform( platID:String, platformX:int=0, platformY:int=0,
											 platWidth:int=0, platHeight:int=0, isDoor:Boolean=false ):CustomVerticalPlatform
		{
			var image:Image;
			
			if ( isDoor )
			{
				image = new Image( _miscTextureAtlas.getTexture("wooden_door") );
			}
			
			var floor:CustomVerticalPlatform = new CustomVerticalPlatform( platID, {
				x: platformX, 
				y: platformY,
				width:platWidth, 
				height: platHeight,
				view: image
			}, _context);
			
			floor.oneWay = false;
			_state.add(floor);
			
			return floor;
		}
									 
		public function addPlatform( platID:String, platformX:int=0, platWidth:int=0, 
									  platformY:int=0, ballAdd:Boolean=false, friction:Number=10,
									coinAdd:Boolean=false, rotation:Number=0 ):CustomPlatform {
			if ( Math.random() > 0.2 ) {
//				addSprite( platformX, platformY - 400, "tree" ); 
			}
			
			var numBushes:int = ( platWidth / 200 ) * Math.random();
			for (var i:int = 0; i < numBushes; i++) 
			{
//				addSprite( platformX + ((platWidth/2) * Math.random()) - platWidth/4, platformY - 97, "bush" );
			}
			
						
			var textureName:String = "platformNew" + platWidth;
//			var image:Image = new Image( _miscTextureAtlas.getTexture(textureName) );
//			image.scaleX = platWidth / 800;
			
//			image.rotation = rotation;
			
			var floor:CustomPlatform = new CustomPlatform( platID, {
				x: platformX, 
				y: platformY,
				width:platWidth, 
				height: 10//, 
//				friction:friction 
			}, _context);
//			floor.view = image;
			
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
		
		public function createLevelComponent( componentID:String ):void 
		{
			var componentData:RowData = MetaData.getRowData( "Components", componentID );
			
			var pos:Point = _context.locToPoint( componentData.getString( "pos" ) );
			pos.y += _context.groundLevel;
			
			var width:int = componentData.getInt( "width" );
			var height:int = componentData.getInt( "height" );
			var friction:Number = componentData.getNumber( "friction" );
			
			var secondPos:Point = _context.locToPoint( componentData.getString( "second_pos" ) );
			secondPos.y += _context.groundLevel;
			
			var type:String = componentData.getString( "type" );
			var spawnItem:String = componentData.getString( "spawn_item" );
			
			switch ( type ) {
				case GameConstants.COMPONENT_TYPE_PLATFORM:
					_context.viewMaster.addPlatform( 
						componentID, pos.x, width, pos.y, false, friction, true );
					break;
				case GameConstants.COMPONENT_TYPE_VERTICAL_PLATFORM:
					_context.viewMaster.addVerticalPlatform( 
						componentID, pos.x, pos.y, width, height );
					break;
				case GameConstants.COMPONENT_TYPE_FIRE:
					_context.viewMaster.addFire( 
						componentID, pos.x, pos.y );
					break;
				case GameConstants.COMPONENT_TYPE_DOOR:
					_context.viewMaster.addVerticalPlatform( 
						componentID, pos.x, pos.y, width, height, true );
					break;
				case GameConstants.COMPONENT_TYPE_PORTAL:
					_context.viewMaster.addPortal( pos.x, pos.y, height, secondPos.x, secondPos.y, width, height );
					break;
				case GameConstants.COMPONENT_TYPE_ENEMY:
					_context.viewMaster.addEnemy( pos.x, pos.y ); 
					break;
				case GameConstants.COMPONENT_TYPE_PLUTO:
					_context.viewMaster.addPluto( pos.x, pos.y );
					break;
				case GameConstants.COMPONENT_TYPE_SPRING:
					_context.viewMaster.addCannonSensor( pos.x, pos.y ); 
					break;
				case GameConstants.COMPONENT_TYPE_SWITCH:
					_context.viewMaster.addSwitch( pos.x, pos.y, spawnItem ); 
					break;
				case GameConstants.COMPONENT_TYPE_STAR:
					_context.viewMaster.addStar( pos.x, pos.y, false, secondPos );
					break;
				case GameConstants.COMPONENT_TYPE_BALL:
					_context.viewMaster.addBall( false, pos.x, pos.y );
					break;
				case GameConstants.COMPONENT_TYPE_POWERUP:
					_context.viewMaster.addPowerup( pos.x, pos.y );
					break;
				case GameConstants.COMPONENT_TYPE_CRATE:
					_context.viewMaster.addCrate( false, false, pos.x, pos.y, spawnItem );
					break;
				case GameConstants.COMPONENT_TYPE_LARGE_CRATE:
					_context.viewMaster.addCrate( false, true, pos.x, pos.y, spawnItem );
					break;
				default:
					break;
			}
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