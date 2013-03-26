package {

	import flash.display.Bitmap;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import citrus.core.starling.StarlingState;
	import citrus.math.MathVector;
	import citrus.objects.CitrusSprite;
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Coin;
	import citrus.objects.platformer.nape.MovingPlatform;
	import citrus.objects.platformer.nape.Platform;
	import citrus.objects.platformer.nape.Sensor;
	import citrus.physics.nape.Nape;
	import citrus.view.ACitrusCamera;
	import citrus.view.starlingview.AnimationSequence;
	import citrus.view.starlingview.StarlingArt;
	import citrus.view.starlingview.StarlingView;
	
	import games.hungryhero.ParticleAssets;
	
	import nape.callbacks.InteractionCallback;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Polygon;
	
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.particles.PDParticleSystem;
	import starling.filters.BlurFilter;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.textures.TextureSmoothing;

	/**
	 * @author Aymeric
	 */
	public class TinyWingsGameState extends StarlingState {
		
//		[Embed(source="/../embed/1x/heroMobile.xml", mimeType="application/octet-stream")]
//		public static const HeroConfig:Class;
//
//		[Embed(source="/../embed/1x/heroMobile.png")]
//		public static const HeroPng:Class;
		
//		[Embed(source="/../embed/mickey/mickeyrun.xml", mimeType="application/octet-stream")]
//		public static const MickeyRunConfig:Class;
//		
//		[Embed(source="/../embed/mickey/mickeyrun.png")]
//		public static const MickeyRunPng:Class;
		
//		[Embed(source="/../embed/mickey/mickeyrunshoebox.xml", mimeType="application/octet-stream")]
//		public static const MickeyRunConfig:Class;
//		
//		[Embed(source="/../embed/mickey/mickeyrunshoebox.png")]
//		public static const MickeyRunPng:Class;
		

		

		
		[Embed(source="/../embed/small_crate.png")]
		private var _cratePng:Class;
		
		[Embed(source="/../embed/large_crate.png")]
		private var _largeCratePng:Class;
		
		[Embed(source="/../embed/very_large_crate.png")]
		private var _veryLargeCratePng:Class;
		
//		[Embed(source="/../embed/coin.png")]
//		private var _coinPng:Class;
		
//		[Embed(source="/../embed/platform500.png")]
//		private var platform500:Class;
		
//		[Embed(source="/../embed/platformMonsters.png")]
//		private var platformMonsters:Class;
		
		private var _nape:Nape;
		private var _hero:MickeyHero;
		private var _enemy:CustomEnemy;
		
		private var _hillsTexture:HillsTexture;
		
		private var _cameraBounds:Rectangle;
		
		private var _hills:CustomHills;
		
		/** Game background object. */
		private var bg:GameBackground;
		
		private var fg:GameBackground;
		
		private var fallSensor:CustomFallSensor;

		/** HUD Container. */		
		private var hud:HUD;
		
		/** Time calculation for animation. */
		private var elapsed:Number;
		
		private var _miscTextureAtlas:TextureAtlas;
		
		private var heroAnim:AnimationSequence;
		private var enemyAnim:AnimationSequence;
		private var sTextureAtlas:TextureAtlas;
		
		private var downTimer:Timer;
		
		private var _context:GameContext;
		
		public function TinyWingsGameState( context:GameContext ) {
			_context = context;
			
			super();
		}

		override public function initialize():void {
			
			super.initialize();

			_nape = new Nape("nape");
			//_nape.visible = true;
			//_nape.gravity.y -= 200;
			add(_nape);
			
//			var bitmap:Bitmap = new HeroPng();
//			var texture:Texture = Texture.fromBitmap(bitmap);
//			var xml:XML = XML(new HeroConfig());
//			var sTextureAtlas:TextureAtlas = new TextureAtlas(texture, xml);
//			var heroAnim:AnimationSequence = new AnimationSequence(sTextureAtlas, ["fly", "descent", "stop", "ascent", "throughPortal", "jump", "ground"], "fly", 30, true);
//			StarlingArt.setLoopAnimations(["fly"]);
			
			
//			var bitmap:Bitmap = new _context.MickeyPng();
			//bitmap.smoothing = TextureSmoothing.BILINEAR;
//			var texture:Texture = Texture.fromBitmap(bitmap, false, false, 1);
//			var xml:XML = XML(new _context.MickeyConfig());
			sTextureAtlas = Assets.getMickeyAtlas();//new TextureAtlas(texture, xml);
			heroAnim = new AnimationSequence(sTextureAtlas, ["slice_", "mickeyjump2_", "mickeythrow_", "mickeypush_", "mickeycarpet_", "mickeybubble_"], "slice_", 15, true, "none");
			StarlingArt.setLoopAnimations(["slice_", "mickeypush_", "mickeycarpet_", "mickeybubble_"]);
			
			enemyAnim = new AnimationSequence(sTextureAtlas, ["slice_"], "slice_", 15, true, "none");
			
//			bitmap = new _context.MiscPng();
//			texture = Texture.fromBitmap( bitmap, false, false, 1 );
//			xml = XML( new _context.MiscConfig() );
			_miscTextureAtlas = Assets.getMiscAtlas() ;//new TextureAtlas( texture, xml );
			
//			var filter:BlurFilter;// = new BlurFilter(1, 1, 1);
//			filter = BlurFilter.createGlow(0x000000);//0x000000, 1, 0.2, 1);
			//filter = BlurFilter.createDropShadow(4, 0, 0x000000, 1, 0, 1);
//			filter.blurX = filter.blurY = 1;
//			filter.setUniformColor(true, 0x000000, 1);
			
//			heroAnim.filter = filter;
			
			_hero = new MickeyHero( "hero", {x:stage.stageWidth * 0.2, radius:40, view:heroAnim, group:1}, 
				_context, heroAnim );
			add(_hero);
			
//			bg = new GameBackground("background", null, _hero, true);
//			add(bg);
			
//			bg.setHero( _hero );
			
			_hillsTexture = new HillsTexture();
			
//			fallSensor = new CustomFallSensor("fallSensor", {x:_hero.x, y: stage.stageHeight * 0.85, width:stage.stageWidth + ( stage.stageWidth * 0.5 ),
//				height: 20}, _hero);
//			fallSensor.view = new Quad( fallSensor.width, fallSensor.height, 0x00dd11);
//			fallSensor.onBeginContact.add(_fallSensorTouched);
//			add( fallSensor );
			
			// small safety platform that follows Mickey
//			var fallSensor:CustomPlatform = new CustomPlatform("fallSensor", {x:_hero.x, y: stage.stageHeight * 0.85, width:500,
//				height: 20}, _hero);
////			fallSensor.view = new Quad( fallSensor.width, fallSensor.height, 0x88dd11);
//			fallSensor.view = new Image( _miscTextureAtlas.getTexture("platformNew500") );
//			//fallSensor.onBeginContact.add(_fallSensorTouched);
//			add( fallSensor );
				

			_hills = new CustomHills("hills", 
				{rider:_hero, sliceHeight:400, sliceWidth:100, currentYPoint:stage.stageHeight * 0.85, //currentXPoint: 10, 
					widthHills: stage.stageWidth + ( stage.stageWidth * 0.5 ), 
					registration:"topLeft", view:_hillsTexture},
				_context );
			add(_hills);
			
//			var floor:Platform = new Platform("floor", {x:-100, y:stage.stageHeight - 100, width:5000, height: 250});
//			floor.view = new Quad(5100, 250, 0x00dd11);
//			add(floor);
			
			// Draw background.
//			fg = new GameBackground("foreground", null, _hero, false);
//			add(fg);
//			
//			fg.setHero( _hero );
			
//			_cameraBounds = new Rectangle(0, -500, int.MAX_VALUE, int.MAX_VALUE);
			
			_cameraBounds = new Rectangle(0, -500, int.MAX_VALUE, int.MAX_VALUE);

			view.camera.setUp( _hero, new MathVector(stage.stageWidth * 0.15, stage.stageHeight * 0.65), 
				_cameraBounds, new MathVector(1.00, 0.08));
			view.camera.allowZoom = true;
			
			
			// particle effects
			particleCoffee = new CitrusSprite("particleCoffee", {view:new PDParticleSystem(XML(new ParticleAssets.ParticleCoffeeXML()), Texture.fromBitmap(new ParticleAssets.ParticleTexture()))});
			add(particleCoffee);
			
			particleMushroom = new CitrusSprite("particleMushroom", {view:new PDParticleSystem(XML(new ParticleAssets.ParticleMushroomXML()), Texture.fromBitmap(new ParticleAssets.ParticleTexture()))});
			add(particleMushroom);
			
			if ( particleCoffeePD == null ) 
				particleCoffeePD = ((view.getArt(particleCoffee) as StarlingArt).content as PDParticleSystem);
			
			_hero.setFlyingPD( particleCoffeePD );
			
//			var pePlatform:PhyEPlatform285 = new PhyEPlatform285( "customPlat", { x: stage.stageWidth, y: 500, width: 285, height: 50 }, _hero );
//			pePlatform.view = new Image( _miscTextureAtlas.getTexture("platformGreen") );
//			add( pePlatform );
			
			
			downTimer= new Timer( 250 );
			downTimer.addEventListener( TimerEvent.TIMER, handleTimeEvent );
			downTimer.start();
			
			view.camera.zoom( 1.0 );
			view.camera.zoomEasing = 0.05;
			
			//view.camera.zoomFit( stage.stageWidth, stage.stageHeight );

			//stage.addEventListener(TouchEvent.TOUCH, _addObject);
			
//			addPlatform( _ce.state.view.camera.camPos + 1000, 800, stage.stageHeight - 100 );
			
			
//			((view.getArt(particleCoffee) as StarlingArt).content as PDParticleSystem).start(30);
//			((view.getArt(particleMushroom) as StarlingArt).content as PDParticleSystem).start(60);
			
			hud = new HUD();
			this.addChild(hud);
			
			// Reset hud values and text fields.
			hud.foodScore = 0;
			hud.distance = 0;
//			hud.lives = 0;
			
			_context.initNewLevel();
			_context.gameEndedSig.add( gameEndedControl );
			
			setTimeout( addGameEndedSensor, _context.getAndIncGameDuration() );
			
			_ce.playing = true;
		}
		
		private function _fallSensorTouched(callback:InteractionCallback):void
		{
			trace( "Hero fell down!" );
			_hero.y -= 800; // temp reset
			_hero.x += 500;
			
		}
		
		private var crateTimer:int = 0;
		protected function handleTimeEvent(event:TimerEvent):void
		{
//			_hero._isFlying = !_hero._isFlying;
			//addPlatform();
			crateTimer++;
		
			if ( crateTimer > 10 ) {
				if ( Math.random() > 0.5 ) {
	//				addPowerup( view.camera.camPos.x + view.camera.cameraLensWidth,
	//				_hills.currentYPoint - 100 );
					addCoinFormation();
					addCrate( false, false, view.camera.camPos.x + view.camera.cameraLensWidth + 200,
						_hills.currentYPoint - 100 );//, Math.random() > 0.5 );
				}
				else
				{
//					addPlatform( _hills.currentXPoint + 30, 500, _hills.currentYPoint - 300 );
				}
	//			else
	//				addEnemy();
				
				crateTimer = 0;
			} else {
				addCoin( _hills.currentXPoint + 30, _hills.currentYPoint - 70 );
			}
			
		}
		
		private function addCoinFormation():void {
			addCoin( view.camera.camPos.x + view.camera.cameraLensWidth,
			_hills.currentYPoint - 200 );
			addCoin( view.camera.camPos.x + view.camera.cameraLensWidth + 60,
			_hills.currentYPoint - 260 );
			addCoin( view.camera.camPos.x + view.camera.cameraLensWidth + 120,
			_hills.currentYPoint - 320 );
			addCoin( view.camera.camPos.x + view.camera.cameraLensWidth + 180,
			_hills.currentYPoint - 380 );
			addCoin( view.camera.camPos.x + view.camera.cameraLensWidth + 240,
			_hills.currentYPoint - 320 );
			addCoin( view.camera.camPos.x + view.camera.cameraLensWidth + 300,
			_hills.currentYPoint - 260 );
			addCoin( view.camera.camPos.x + view.camera.cameraLensWidth + 360,
			_hills.currentYPoint - 200 );
		}
		
		private function gameEndedControl():void
		{
			_context.hasGameEnded = true;
			view.camera.bounds = new Rectangle( 0, -500, 
				view.camera.camPos.x + ( view.camera.cameraLensWidth + view.camera.cameraLensWidth  * ( 1 - view.camera.getZoom() ) )
					, int.MAX_VALUE );
		}
		
		private function onGameEnded():void
		{
			this._ce.playing = false;
//			bg.gamePaused = true;
			
			downTimer.stop();
			downTimer.removeEventListener( TimerEvent.TIMER, handleTimeEvent );
			
//			_ce.state = new TinyWingsGameState( _context );
		}
		
//		private function _addObject(tEvt:TouchEvent):void {
//			
//			var touch:Touch = tEvt.getTouch(stage, TouchPhase.BEGAN);
//			
//			if (touch) {
//				
//				var image:Image = new Image(Texture.fromBitmap(new _cratePng()));
//				
//				var physicObject:CrateObject = new CrateObject("physicobject", { x:stage.stageWidth + 100, y:touch.getLocation(this).y, width:35, height:38, view:image} );
//				add(physicObject);
//			}
//			
//		}
		
		private function addEnemy():void {
			enemyAnim = new AnimationSequence(sTextureAtlas, ["slice_"], "slice_", 15, true, "none");
			_enemy = new CustomEnemy("enemy", {x:_hero.x + stage.stageWidth, y: _hero.y,
				radius:40, view:enemyAnim, group:1}, _hero);
			add(_enemy);
		}
		
		private function addGameEndedSensor():void {
			var image:Image;
			var width:int; var height:int;
			
			image = new Image(Texture.fromBitmap(new _veryLargeCratePng()));
			width = 140; height = 152;
			
			var sensor:CustomGameEndSensor = new CustomGameEndSensor("gameEndedSensor", 
				{ x:_hero.x + stage.stageWidth, y:_hero.y - 200, width:width, height:height, view:image}, 
				_hero );
			add(sensor);	
		}
		
		private function addCrate(addSmallCrate:Boolean, veryLargeCrate:Boolean=false, x:int=-1, y:int=-1 ):void {
			var image:Image;
			var width:int; var height:int;
			
			if ( addSmallCrate ) {
				image = new Image(Texture.fromBitmap(new _cratePng()));
				width = 35; height = 38;
			} else if ( veryLargeCrate ) {
				image = new Image(Texture.fromBitmap(new _veryLargeCratePng()));
				width = 140; height = 152;
			} else {
				image = new Image(Texture.fromBitmap(new _largeCratePng()));
				width = 70; height = 76;
			}
			
			if ( x == -1 ) x = _hero.x + stage.stageWidth;
			if ( y == -1 ) y = _hero.y - 100;
			
			var physicObject:CrateObject = new CrateObject("physicobject", { x:x, y:y, width:width, height:height, view:image}, _hero );
			add(physicObject);	
		}
		
		private var coins:Vector.<Coin> = new Vector.<Coin>();
		private function addCoin( coinX:int, coinY:int ):void {
			var image:Image;
			var width:int; var height:int;
			
//			image = new Image(Texture.fromBitmap(new _coinPng()));
			image = new Image( _miscTextureAtlas.getTexture("coin") );
			width = 40; height = 40;

			var physicObject:Coin = new CustomCoin("physicobject", { x:coinX, y:coinY, width:width, height:height, view:image}, _hero );
			add(physicObject);	
			
//			coins.push( physicObject );
		}
		
		private function addPowerup( coinX:int, coinY:int ):void {
			var image:Image;
			var width:int; var height:int;
			
			image = new Image(Texture.fromBitmap(new _cratePng()));
//			image = new Image( _miscTextureAtlas.getTexture("coin") );
			width = 35; height = 38;
			
			var physicObject:Coin = new CustomPowerup("powerup", { x:coinX, y:coinY, width:width, height:height, view:image}, _hero );
			add(physicObject);	
			
			//coins.push( physicObject );
		}
		
		private var platformY:int = 0;
		private var particleCoffee:CitrusSprite;
		private var particleCoffeePD:PDParticleSystem;
		
		private var particleMushroom:CitrusSprite;
		private var particleMushroomPD:PDParticleSystem;
		
		private function addPlatform( platformX:int=0, platWidth:int=0, platformY:int=0 ):Platform {
			var platformWidth:int = platWidth > 0 ? platWidth : 285;//Math.random() * 400 + 300;
			
			var textureName:String = "platformNew" + platWidth;
//			var textureName:String = platWidth == 100 ? "platformGreen100" : "platformGreen";
			
			var floor:Platform = new SmallPlatform("floor", {
				x: platformX,// == 0 ? _hero.x + stage.stageWidth : platformX, 
//				y:stage.stageHeight * 0.7 - platformY - ( Math.random() * 200 ),
				y: platformY == 0? _hero.y - platformY - ( Math.random() * 100 ) : platformY,
				width:platformWidth, height: 30}, _hero);
			floor.view = //platformWidth == 285 ? 
//				new Image(Texture.fromBitmap(new platformMonsters())) : 
				new Image( _miscTextureAtlas.getTexture(textureName) )// :
//				new Quad( platformWidth, 20, 0x08CC18 );
			floor.oneWay = true;
			add(floor);
			
			platformY += Math.random() * 50;
			
			if ( floor.y < 300 ) platformY = 0;
			
			if ( floor.y < _hero.y - 700 ) platformY = 0;
			
			var coinX:int = floor.x - ( Math.random() * floor.width ) + 100;// floor.width/2;
//			addCoin( coinX + 100, floor.y - 50 );
//			addCoin( coinX + 200, floor.y - 50 );

			var i:int = 0;
//			for ( i = 0; i<10; i++ ) {
//				addCoin( coinX + 200, -400 ); 
//				coinX += 45;
//			}
			
			if ( Math.random() > 0.5 )  { 

				coinX = floor.x - floor.width/2 + 50;
				for ( i = 0; i<10; i++ ) {
					addCoin( coinX, floor.y - 50 ); 
					coinX += 45;
				}
			}
			else 
				if ( Math.random() > 0.8 )
					addPowerup( coinX + 300, floor.y - 50 );
			
			return floor;
		}
		
		private function addMovingPlatform():void {
			var floor:Platform = new SmallMovingPlatform("floor", 
				{x:_hero.x + stage.stageWidth, y:_hero.y - 100, width:200,
					startX:_hero.x + stage.stageWidth, startY:300, endX: _hero.x, endY:500, height: 5}, _hero);
			floor.view = new Quad(200, 5, 0x1158D4);
			//floor.oneWay = true;
			add(floor);
		}
		
		private var prevPlatform1X:int = 0;
		private var prevPlatform1Y:int = 0;
		private var prevPlatform1:Platform = null;
		
		private var prevPlatform2X:int = 0;
		private var prevPlatform2Y:int = 0;
		private var prevPlatform2:Platform = null;
		
		private var prevPlatform3X:int = 0;
		private var prevPlatform3Y:int = 0;
		private var prevPlatform3:Platform = null;
		
		private var camPosX:Number = 0;
		private var camLensWidth:Number = 0;
		
		private var initialPosX:Number = -1500;

		private function platformGenerator():void {
			camPosX = _ce.state.view.camera.camPos.x;
			camLensWidth = _ce.state.view.camera.cameraLensWidth;
			
//			if ( prevPlatform1Y < _hero.y - 500 ) prevPlatform1Y = _hero.y - 100;
			prevPlatform1Y = _hills.currentYPoint - 300;
			
//			prevPlatform1Y = _hero.y;
//			prevPlatform1Y = stage.stageHeight - 400;
			
			prevPlatform2Y = prevPlatform1Y - 300;
			
			prevPlatform3Y = prevPlatform2Y - 300;
			
			
			if ( initialPosX < 0 || initialPosX - prevPlatform1X > 150 ) {
				
				//add a new platform
				prevPlatform1 = addPlatform( initialPosX + 400, 
					800,//( Math.random() > 0.8 ) ? 1000 : 800, 
					prevPlatform1Y + ( ( Math.random() * 100 ) * ( Math.random() > 0.5 ? -1 : 1 ) ) );
				prevPlatform1X = prevPlatform1.x + prevPlatform1.width/2;
				prevPlatform1Y = prevPlatform1.y;
				
				
//				if ( Math.random() > 0.8 ) {
//					createCustomShape();
//				}
				if ( Math.random() > 0.2 ) {

					prevPlatform2X = prevPlatform1X - 200;
					//add a new platform
					prevPlatform2 = addPlatform( initialPosX + 150, 
						500,//( Math.random() > 0.8 ) ? 900 : 600, 
						prevPlatform2Y + ( ( Math.random() * 100 ) * ( Math.random() > 0.5 ? -1 : 1 ) ) );
					prevPlatform2X = prevPlatform2.x + prevPlatform2.width/2;
					prevPlatform2Y = prevPlatform2.y;
					
					//lowermost platform
					prevPlatform3X = prevPlatform2X - 200;
					//prevPlatform3X = -250;
	//				if ( camPosX + camLensWidth > prevPlatform3X ) {
						//add a new platform
					prevPlatform3 = addPlatform( initialPosX + 50, 
						300,//( Math.random() > 0.8 ) ? 700 : 400, 
						prevPlatform3Y + ( ( Math.random() * 100 ) * ( Math.random() > 0.5 ? -1 : 1 ) ) );
					prevPlatform3X = prevPlatform3.x + prevPlatform3.width/2;
					prevPlatform3Y = prevPlatform3.y;	
				}
//				}
			}
			
			initialPosX = _hills.currentXPoint;
//			initialPosX = camPosX + camLensWidth;
		}
		
//		private var pePlatform:PhyEPlatform285;
		private function createCustomShape():void {
			var pePlatform:PhyEPlatform285 = new PhyEPlatform285( "customPlat", { x: camPosX + camLensWidth + 1000, y: 700, 
				width: 285, height: 50}, _hero );
			pePlatform.view = new Image( _miscTextureAtlas.getTexture("platformNew300") );
			add( pePlatform );	
			
			pePlatform = new PhyEPlatform285( "customPlat1", { x: camPosX + camLensWidth + 1000, y: 500, 
				width: 285, height: 50}, _hero );
			pePlatform.view = new Image( _miscTextureAtlas.getTexture("platformNew500") );
			add( pePlatform );	
		}
		
		private var numLives:int = 3;
		private var gameOver:Boolean = false;
		private var tempCoin:Coin;
		private var scoreDistance:Number = 0;
		private var viewCamPosX:Number = -1;
		private var viewCamLensWidth:Number = -1;
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			elapsed = timeDelta;
			
			// update the hills here to remove the displacement made by StarlingArt. Called after all operations done.
			_hillsTexture.update();
			
			particleCoffeePD.emitterX = _hero.x + _hero.width + 5;
			((view.getArt(particleCoffee) as StarlingArt).content as PDParticleSystem).emitterY = _hero.y;
			
			((view.getArt(particleMushroom) as StarlingArt).content as PDParticleSystem).emitterX = _hero.x + _hero.width * 0.5 * 0.5;
			((view.getArt(particleMushroom) as StarlingArt).content as PDParticleSystem).emitterY = _hero.y;
			
			// generate platforms
			platformGenerator();
			
			if ( _hero.y > stage.stageHeight + 500 ) {
//				if ( !gameOver ) _hero.y = stage.stageHeight + 500;
				
//				numLives--;
//				
//				if ( numLives > 0 ) 
//					_hero._isFlying = true;
//				else 
				if ( !_hero._isFlying ) {
					setTimeout( function():void { 
						//_ce.state = new TinyWingsGameState();
						//_ce.playing = true;
					}, 500 );
					//_ce.playing = false;
//					gameOver = true;
				}
			}
			
			if ( _hero.y < -400 ) _hero.y = -400;
			
			if ( _hero.velocity.x == 0 ) {
				_hero.y -= 1;
			}
			
//			var z:Number = view.camera.zoomEasing;
			
			if ( !_context.hasGameEnded ) {
				if ( _hero._isFlying ) {
					view.camera.setZoom( 0.8 );
//					if ( view.camera.getZoom() > 0.8 ) {
//						view.camera.setZoom( view.camera.getZoom() * 0.995 );
//					}
				} else {
					view.camera.setZoom( 1.0 );
//					if ( view.camera.getZoom() < 1.0 ) {
//						view.camera.setZoom( view.camera.getZoom() * 1.005 );
//					}
				}
			}
			
//			if ( Math.random() > 0.95 ) addCoin( view.camera.camPos.x + view.camera.cameraLensWidth, 
//				_hills.currentYPoint - 400 );
			
//			if ( Math.random() > 0.995 ) addPowerup( view.camera.camPos.x + view.camera.cameraLensWidth,
//				_hills.currentYPoint - 100 );
			
//			if ( Math.random() > 0.99 ) addEnemy();
			
//			if ( Math.random() > 0.999 ) addCrate( false );
			
			// coin magnet code
//			for ( var i:int = 0; i<coins.length; i++ ) {
//				tempCoin = coins[i];
//				
//				if (tempCoin == null) {
//					coins.splice(i, 1);
//					continue;
//				}
//				// Move the item towards the player.
//				tempCoin.x -= (tempCoin.x - _hero.x - 25) * 0.2;
//				tempCoin.y -= (tempCoin.y - _hero.y - 25) * 0.2;
//			}
//			var aa:int;
//			
//			aa = view.camera.camPos.x;
//			aa = view.camera.camPos.y;
//			aa = view.camera.cameraLensWidth;
//			aa = view.camera.cameraLensHeight;
			
//			if (Math.random() > 0.99) addCrate(false);
//			
//			if (Math.random() > 0.99) addPlatform();
			
//			if (_cameraBounds.y < _hills.currentYPoint - 590) {
//				_cameraBounds.y += 3;
//			} else if ( _cameraBounds.y > _hills.currentYPoint - 610 ) {
//				_cameraBounds.y -= 3;
//			}
			//view.camera.bounds = _cameraBounds;
			// Set the background's speed based on hero's speed.
			//bg.speed = _hero.velocity.x;
//			bg.y = _hero.y;
//			bg.x = _hero.x;
			
			// update HUD
//			scoreDistance += (_hero.velocityX * elapsed) * 0.1;
//			hud.distance = Math.round(scoreDistance);
			hud.distance = _hero.x * 0.1;
			
			hud.foodScore = _hero.numCoinsCollected;
			
			if ( _context.hasGameEnded ) {
				if ( viewCamPosX == -1 ) viewCamPosX = view.camera.camPos.x;
				if ( viewCamLensWidth == -1 ) 
					viewCamLensWidth = view.camera.cameraLensWidth + view.camera.cameraLensWidth  * ( 1 - view.camera.getZoom() );
				
				if ( _hero.x - 200 > 
					viewCamPosX + ( viewCamLensWidth ) ) {
					onGameEnded();
				}
			}
		}
	}
}
