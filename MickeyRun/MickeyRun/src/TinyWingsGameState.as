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
		
		[Embed(source="/../embed/mickey/mickeyall.xml", mimeType="application/octet-stream")]
		public static const MickeyConfig:Class;
		
		[Embed(source="/../embed/mickey/mickeyall.png")]
		public static const MickeyPng:Class;
		
		[Embed(source="/../embed/mickey/misc.xml", mimeType="application/octet-stream")]
		public static const MiscConfig:Class;
		
		[Embed(source="/../embed/mickey/misc.png")]
		public static const MiscPng:Class;
		

		
		[Embed(source="/../embed/small_crate.png")]
		private var _cratePng:Class;
		
		[Embed(source="/../embed/large_crate.png")]
		private var _largeCratePng:Class;
		
//		[Embed(source="/../embed/coin.png")]
//		private var _coinPng:Class;
		
//		[Embed(source="/../embed/platform500.png")]
//		private var platform500:Class;
		
//		[Embed(source="/../embed/platformMonsters.png")]
//		private var platformMonsters:Class;
		
		private var _nape:Nape;
		private var _hero:MickeyHero;
		
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
		
		public function TinyWingsGameState() {
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
			
//			// Draw background.
//			bg = new GameBackground("background", null, _hero, true);
//			add(bg);
			
			
			var bitmap:Bitmap = new MickeyPng();
			//bitmap.smoothing = TextureSmoothing.BILINEAR;
			var texture:Texture = Texture.fromBitmap(bitmap, false, false, 1);
			var xml:XML = XML(new MickeyConfig());
			var sTextureAtlas:TextureAtlas = new TextureAtlas(texture, xml);
			var heroAnim:AnimationSequence = new AnimationSequence(sTextureAtlas, ["slice_", "mickeyjump2_", "mickeythrow_", "mickeypush_", "mickeycarpet_", "mickeybubble_"], "slice_", 15, true, "none");
			StarlingArt.setLoopAnimations(["slice_", "mickeypush_", "mickeycarpet_", "mickeybubble_"]);
			
			bitmap = new MiscPng();
			texture = Texture.fromBitmap( bitmap, false, false, 1 );
			xml = XML( new MiscConfig() );
			_miscTextureAtlas = new TextureAtlas( texture, xml );
			
//			var filter:BlurFilter;// = new BlurFilter(1, 1, 1);
//			filter = BlurFilter.createGlow(0x000000);//0x000000, 1, 0.2, 1);
			//filter = BlurFilter.createDropShadow(4, 0, 0x000000, 1, 0, 1);
//			filter.blurX = filter.blurY = 1;
//			filter.setUniformColor(true, 0x000000, 1);
			
//			heroAnim.filter = filter;
			
			_hero = new MickeyHero("hero", {x:stage.stageWidth * 0.2, radius:40, view:heroAnim, group:1});
			add(_hero);
			
			bg = new GameBackground("background", null, _hero, true);
			add(bg);
			
//			bg.setHero( _hero );
			
			_hillsTexture = new HillsTexture();
			
//			fallSensor = new CustomFallSensor("fallSensor", {x:_hero.x, y: stage.stageHeight * 0.85, width:stage.stageWidth + ( stage.stageWidth * 0.5 ),
//				height: 20}, _hero);
//			fallSensor.view = new Quad( fallSensor.width, fallSensor.height, 0x00dd11);
//			fallSensor.onBeginContact.add(_fallSensorTouched);
//			add( fallSensor );
			
			// small safety platform that follows Mickey
			var fallSensor:CustomPlatform = new CustomPlatform("fallSensor", {x:_hero.x, y: stage.stageHeight * 0.85, width:400,
				height: 20}, _hero);
			fallSensor.view = new Quad( fallSensor.width, fallSensor.height, 0x88dd11);
			//fallSensor.onBeginContact.add(_fallSensorTouched);
			add( fallSensor );
				

//			_hills = new CustomHills("hills", 
//				{rider:_hero, sliceHeight:300, sliceWidth:70, currentYPoint:stage.stageHeight * 0.85, //currentXPoint: 10, 
//					widthHills: stage.stageWidth + ( stage.stageWidth * 0.5 ), 
//					registration:"topLeft", view:_hillsTexture});
//			add(_hills);
			
//			var floor:Platform = new Platform("floor", {x:-100, y:stage.stageHeight - 100, width:5000, height: 250});
//			floor.view = new Quad(5100, 250, 0x00dd11);
//			add(floor);
			
			// Draw background.
			fg = new GameBackground("foreground", null, _hero, false);
			add(fg);
//			
//			fg.setHero( _hero );
			
//			_cameraBounds = new Rectangle(0, -500, int.MAX_VALUE, int.MAX_VALUE);
			
			_cameraBounds = new Rectangle(0, -500, int.MAX_VALUE, int.MAX_VALUE);

			view.camera.setUp( _hero, new MathVector(stage.stageWidth * 0.05, stage.stageHeight * 0.6), _cameraBounds, new MathVector(0.05, 0.05));
			view.camera.allowZoom = true;
			
			// particle effects
			particleCoffee = new CitrusSprite("particleCoffee", {view:new PDParticleSystem(XML(new ParticleAssets.ParticleCoffeeXML()), Texture.fromBitmap(new ParticleAssets.ParticleTexture()))});
			add(particleCoffee);
			
			particleMushroom = new CitrusSprite("particleMushroom", {view:new PDParticleSystem(XML(new ParticleAssets.ParticleMushroomXML()), Texture.fromBitmap(new ParticleAssets.ParticleTexture()))});
			add(particleMushroom);
			
//			var pePlatform:PhyEPlatform285 = new PhyEPlatform285( "customPlat", { x: stage.stageWidth, y: 500, width: 285, height: 50 }, _hero );
//			pePlatform.view = new Image( _miscTextureAtlas.getTexture("platformGreen") );
//			add( pePlatform );
			
			
//			var downTimer:Timer = new Timer( 5000 );
//			downTimer.addEventListener( TimerEvent.TIMER, handleTimeEvent );
//			downTimer.start();
			
//			view.camera.zoom( 1.2 );
			
			//view.camera.zoomFit( stage.stageWidth, stage.stageHeight );

			//stage.addEventListener(TouchEvent.TOUCH, _addObject);
			
			addPlatform( _ce.state.view.camera.camPos + 1000, 2500, stage.stageHeight - 100 );
			
			
			((view.getArt(particleCoffee) as StarlingArt).content as PDParticleSystem).start(30);
//			((view.getArt(particleMushroom) as StarlingArt).content as PDParticleSystem).start(60);
			
			hud = new HUD();
			this.addChild(hud);
			
			// Reset hud values and text fields.
			hud.foodScore = 0;
			hud.distance = 0;
//			hud.lives = 0;
		}
		
		private function _fallSensorTouched(callback:InteractionCallback):void
		{
			trace( "Hero fell down!" );
			_hero.y -= 800; // temp reset
			_hero.x += 500;
			
		}
		
		protected function handleTimeEvent(event:TimerEvent):void
		{
			_hero._isFlying = !_hero._isFlying;
			//addPlatform();
			//addCrate( true );
			
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
		
		private function addCurvedPlatform():void {
			
		}
		
		private function addCrate(addSmallCrate:Boolean):void {
			var image:Image;
			var width:int; var height:int;
			
			if ( addSmallCrate ) {
				image = new Image(Texture.fromBitmap(new _cratePng()));
				width = 35; height = 38;
			} else {
				image = new Image(Texture.fromBitmap(new _largeCratePng()));
				width = 70; height = 76;
			}
			
			var physicObject:CrateObject = new CrateObject("physicobject", { x:_hero.x + stage.stageWidth, y:_hero.y - 100, width:width, height:height, view:image}, _hero );
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
			
			coins.push( physicObject );
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
		private var particleMushroom:CitrusSprite;
		
		private function addPlatform( platformX:int=0, platWidth:int=0, platformY:int=0 ):Platform {
			var platformWidth:int = platWidth > 0 ? platWidth : 285;//Math.random() * 400 + 300;
			
			var textureName:String = platWidth == 100 ? "platformGreen100" : "platformGreen";
			
			var floor:Platform = new SmallPlatform("floor", {
				x: platformX,// == 0 ? _hero.x + stage.stageWidth : platformX, 
//				y:stage.stageHeight * 0.7 - platformY - ( Math.random() * 200 ),
				y: platformY == 0? _hero.y - platformY - ( Math.random() * 100 ) : platformY,
				width:platformWidth, height: 30}, _hero);
			floor.view = //platformWidth == 285 ? 
//				new Image(Texture.fromBitmap(new platformMonsters())) : 
				//new Image( _miscTextureAtlas.getTexture(textureName) )// :
				new Quad( platformWidth, 20, 0x08CC18 );
			floor.oneWay = true;
			add(floor);
			
			platformY += Math.random() * 50;
			
			if ( floor.y < 300 ) platformY = 0;
			
			if ( floor.y < _hero.y - 700 ) platformY = 0;
			
			var coinX:int = floor.x - ( Math.random() * floor.width ) + 100;// floor.width/2;
//			addCoin( coinX + 100, floor.y - 50 );
//			addCoin( coinX + 200, floor.y - 50 );
			if ( Math.random() > 0.5 )  { 

				for ( var i:int = 0; i<10; i++ ) {
					addCoin( coinX + 200, floor.y - 50 ); 
					coinX += 45;
				}
			}
			else 
				if ( Math.random() > 0.9 ) addPowerup( coinX + 300, floor.y - 50 );
			
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
//			prevPlatform1Y = _hills.currentYPoint - 200;
			
//			prevPlatform1Y = _hero.y;
			prevPlatform1Y = stage.stageHeight - 200;
			
			prevPlatform2Y = prevPlatform1Y - 300;
			
			prevPlatform3Y = prevPlatform2Y - 300;
			
			
			if ( initialPosX < 0 || initialPosX - prevPlatform1X > 150 ) {
				
				//add a new platform
				prevPlatform1 = addPlatform( initialPosX + 400, 
					( Math.random() > 0.8 ) ? 1000 : 800, 
					prevPlatform1Y + ( ( Math.random() * 100 ) * ( Math.random() > 0.5 ? -1 : 1 ) ) );
				prevPlatform1X = prevPlatform1.x + prevPlatform1.width/2;
				prevPlatform1Y = prevPlatform1.y;
				
				prevPlatform2X = prevPlatform1X - 200;
				//add a new platform
				prevPlatform2 = addPlatform( initialPosX + 150, 
					( Math.random() > 0.8 ) ? 900 : 600, 
					prevPlatform2Y + ( ( Math.random() * 100 ) * ( Math.random() > 0.5 ? -1 : 1 ) ) );
				prevPlatform2X = prevPlatform2.x + prevPlatform2.width/2;
				prevPlatform2Y = prevPlatform2.y;
				
				//lowermost platform
				prevPlatform3X = prevPlatform2X - 200;
				//prevPlatform3X = -250;
//				if ( camPosX + camLensWidth > prevPlatform3X ) {
					//add a new platform
				prevPlatform3 = addPlatform( initialPosX + 50, 
					( Math.random() > 0.8 ) ? 700 : 400, 
					prevPlatform3Y + ( ( Math.random() * 100 ) * ( Math.random() > 0.5 ? -1 : 1 ) ) );
				prevPlatform3X = prevPlatform3.x + prevPlatform3.width/2;
				prevPlatform3Y = prevPlatform3.y;	
//				}
			}
			
			initialPosX = camPosX + camLensWidth;
		}
		
		private var pePlatform:PhyEPlatform285;
		private function createCustomShape():void {
			pePlatform = new PhyEPlatform285( "customPlat", { x: _hero.x + stage.stageWidth, y: _hero.y - 100, 
				width: 285, height: 50}, _hero );
			pePlatform.view = new Image( _miscTextureAtlas.getTexture("platformGreen") );
			add( pePlatform );	
		}
		
		private var numLives:int = 3;
		private var gameOver:Boolean = false;
		private var tempCoin:Coin;
		private var scoreDistance:Number = 0;
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			elapsed = timeDelta;
			
			// update the hills here to remove the displacement made by StarlingArt. Called after all operations done.
			_hillsTexture.update();
			
			((view.getArt(particleCoffee) as StarlingArt).content as PDParticleSystem).emitterX = _hero.x + _hero.width * 0.5 * 0.5;
			((view.getArt(particleCoffee) as StarlingArt).content as PDParticleSystem).emitterY = _hero.y;
			
			((view.getArt(particleMushroom) as StarlingArt).content as PDParticleSystem).emitterX = _hero.x + _hero.width * 0.5 * 0.5;
			((view.getArt(particleMushroom) as StarlingArt).content as PDParticleSystem).emitterY = _hero.y;
			
			// generate platforms
			platformGenerator();
			
			if ( _hero.y > stage.stageHeight ) {
				if ( !gameOver ) _hero.y = stage.stageHeight;
				
//				numLives--;
//				
//				if ( numLives > 0 ) 
//					_hero._isFlying = true;
//				else 
				if ( !_hero._isFlying ) {
					setTimeout( function():void { 
						_ce.state = new TinyWingsGameState();
						//_ce.playing = true;
					}, 500 );
					//_ce.playing = false;
					gameOver = true;
				}
			}
			
			if ( _hero.y < -400 ) _hero.y = -400;
			
			if ( _hero.velocity.x == 0 ) {
				_hero.y -= 1;
			}
			
//			if ( Math.random() > 0.9 ) addCoin( view.camera.camPos.x + view.camera.cameraLensWidth, _hero.y - 50 );
			
//			if ( Math.random() > 0.9 ) createCustomShape();
			
//			if ( Math.random() > 0.9 ) addCrate( false );
			
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
		}
	}
}
