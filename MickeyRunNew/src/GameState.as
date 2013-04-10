package {

	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import citrus.core.starling.StarlingState;
	import citrus.math.MathVector;
	import citrus.objects.platformer.nape.Coin;
	import citrus.physics.nape.Nape;
	import citrus.view.starlingview.AnimationSequence;
	import citrus.view.starlingview.StarlingArt;
	
	import objects.CustomHills;
	
	import starling.display.Button;
	import starling.events.Event;
	import starling.textures.TextureAtlas;
	
	import views.GameBackground;
	import views.GameHUD;
	import views.HillsTexture;

	/**
	 * @author Aymeric
	 */
	public class GameState extends StarlingState {
		
		private var _nape:Nape;
		private var _hero:MickeyHero;
		
		private var _hillsTexture:HillsTexture;
		
		private var _cameraBounds:Rectangle;
		
		private var _hills:CustomHills;
		
		/** Game background object. */
		private var bg:GameBackground;

		/** HUD Container. */		
		private var hud:GameHUD;
		
		/** Time calculation for animation. */
		private var elapsed:Number;
		
		private var _miscTextureAtlas:TextureAtlas;
		
		private var heroAnim:AnimationSequence;
		private var enemyAnim:AnimationSequence;
		private var sTextureAtlas:TextureAtlas;
		
		private var downTimer:Timer;
		
		private var _context:GameContext;
		private var startButton:Button;
		private var fireButton:Button;
		
		private var viewCamPosX:Number = -1;
		private var viewCamLensWidth:Number = -1;
		
		private var gameDistance:int = 0;
		
		private var groundLevel:int = 0;
		
		public function GameState( context:GameContext ) 
		{
			_context = context;
			super();
		}

		override public function initialize():void 
		{
			super.initialize();
			
			// ground level y
			groundLevel = stage.stageHeight * 0.9;

			if ( _context.viewMaster == null ) {
				_context.viewMaster = new ViewMaster( _context, _ce.state );
			}
			
			_context.viewMaster.setState( this );
			
			_nape = new Nape("nape");
			add(_nape);
			
			sTextureAtlas = Assets.getMickeyAtlas();
			heroAnim = new AnimationSequence(sTextureAtlas, ["slice_", "mickeyjump2_", "mickeythrow_", "mickeypush_", "mickeycarpet_", "mickeybubble_"], "slice_", 15, true, "none");
			StarlingArt.setLoopAnimations(["slice_", "mickeypush_", "mickeycarpet_", "mickeybubble_"]);
			
			_miscTextureAtlas = Assets.getMiscAtlas() ;
			
			_hero = new MickeyHero( "hero", {x:50, y: 100, radius:40, view:heroAnim, group:1}, 
				_context, heroAnim );
			add(_hero);
			
			bg = new GameBackground("background", null, _hero, true);
			add(bg);
			
//			_hillsTexture = new HillsTexture();
			
//			_hills = new CustomHills("hills", 
//				{rider:_hero, sliceHeight:400, sliceWidth:100, currentYPoint:groundLevel, //currentXPoint: 10, 
//					widthHills: stage.stageWidth + ( stage.stageWidth * 0.5 ), 
//					registration:"topLeft", view:_hillsTexture},
//				_context );
//			add(_hills);
			
//			_hills.visible = false;
			
			_cameraBounds = new Rectangle(0, -800, int.MAX_VALUE, int.MAX_VALUE);

			view.camera.setUp( _hero, new MathVector(stage.stageWidth * 0.15, stage.stageHeight * 0.75), 
				_cameraBounds, new MathVector(0.20, 0.10));
			view.camera.allowZoom = true;
			
			view.camera.zoomEasing = 0.01;
			view.camera.setZoom( 0.8 );
			
			hud = new GameHUD();
			this.addChild(hud);
			
			// Reset hud values and text fields.
			hud.foodScore = 0;
			hud.distance = 0;
			
			_context.initNewLevel();
			_context.gameEndedSig.add( gameEndedControl );
			
//			gameDistance = _context.getAndIncGameDistance();
			
			_ce.playing = true;
			
			startButton = new Button(Assets.getAtlas().getTexture("startButton"));
			startButton.fontColor = 0xffffff;
			startButton.x = stage.stageWidth/2 - startButton.width/2;
			startButton.y = stage.stageHeight/2 - startButton.height/2;
			startButton.addEventListener(Event.TRIGGERED, onStartButtonClick);
			this.addChild(startButton);
			startButton.visible = false;
			
			//first level:
			gameDistance = generateLevel( _context.currentLevel );
		}
		
		private function onFireButtonClick(event:Event):void
		{
			event.stopPropagation();
			event.stopImmediatePropagation();
		}
		
		private function onStartButtonClick(event:Event):void
		{
			_context.currentLevel += 1;
			if ( _context.currentLevel > _context.maxLevel ) _context.currentLevel = 1;
			_ce.state = new GameState( _context );
		}
		
		private function gameEndedControl():void
		{
			_context.hasGameEnded = true;
			
//			view.camera.target = null;
			view.camera.bounds = new Rectangle( 0, -800, 
//				view.camera.camPos.x + view.camera.cameraLensWidth
				view.camera.camPos.x + ( view.camera.cameraLensWidth + view.camera.cameraLensWidth  * ( 1 - view.camera.getZoom() ) )
					, int.MAX_VALUE );
		}
		
		private function onGameEnded():void
		{
			this._ce.playing = false;
			startButton.visible = true;
		}
		
		private function generateLevel( level:int ):int
		{
			var levelDistance:int = 1000;
			switch ( level ) {
				case 1:
					levelDistance = generateFirstLevel();
					break;
				case 2:
					levelDistance = generateSecondLevel();
					break;
				default:
					break;
			}
			
			return levelDistance;
		}
		
		private function generateFirstLevel():int {
			
			// ground
			_context.viewMaster.addPlatform( 2000, 4000, groundLevel, false, 0.5 );
			
			_context.viewMaster.addPlatform( 1500, 600, groundLevel - 200, false, 0, true );
			_context.viewMaster.addPlatform( 2200, 600, groundLevel - 200, true, 0, true );
			_context.viewMaster.addPlatform( 3000, 600, groundLevel - 500, false, 0, true );
			
			return 3600;
		}
		
		private function generateSecondLevel():int {
			// ground
			_context.viewMaster.addPlatform( 1000, 6000, groundLevel, false, 0.5 );
			
			_context.viewMaster.addPlatform( 1000, 300, groundLevel - 200, false, 0, true );
			_context.viewMaster.addPlatform( 1500, 600, groundLevel - 200, true, 0 );
			_context.viewMaster.addPlatform( 2000, 600, groundLevel - 500, true, 0, true );
			_context.viewMaster.addPlatform( 2500, 600, groundLevel - 200, false, 0 );
			_context.viewMaster.addPlatform( 3000, 600, groundLevel - 100, false, 0, true );
			
			_context.viewMaster.addMovingPlatform( 2500, groundLevel - 500, 
				3000, groundLevel - 500, 50 );
				
			_context.viewMaster.addCrate( false, true, 2000, groundLevel - 200 );
			
			return 4400;
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			_context.viewCamPosX = view.camera.camPos.x;
			
			elapsed = timeDelta;
			
			// update the hills here to remove the displacement made by StarlingArt. Called after all operations done.
//			_hillsTexture.update();
			
			// update HUD
			hud.distance = _hero.x * 0.1;
			
			hud.foodScore = _hero.numCoinsCollected;
			
			// game end distance
			if ( _hero.x + _context.viewCamPosX > gameDistance ) {
				_context.gameEnded();
			}
			
			if ( _context.hasGameEnded ) {
				if ( viewCamPosX == -1 ) viewCamPosX = view.camera.camPos.x;
				if ( viewCamLensWidth == -1 ) 
					viewCamLensWidth = view.camera.cameraLensWidth + view.camera.cameraLensWidth  * ( 1 - view.camera.getZoom() );
//					viewCamLensWidth = view.camera.cameraLensWidth;
				
				if ( _hero.x - 100 > 
					viewCamPosX + ( viewCamLensWidth ) ) {
					onGameEnded();
				}
			}
		}
	}
}
