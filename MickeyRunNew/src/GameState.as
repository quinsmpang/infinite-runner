package {

	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import citrus.core.starling.StarlingState;
	import citrus.math.MathVector;
	import citrus.physics.nape.Nape;
	import citrus.view.starlingview.AnimationSequence;
	import citrus.view.starlingview.StarlingArt;
	
	import nape.geom.Vec2;
	
	import objects.CustomHills;
	
	import starling.display.Button;
	import starling.events.Event;
	import starling.textures.TextureAtlas;
	
	import steamboat.data.metadata.MetaData;
	import steamboat.data.metadata.RowData;
	
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
		
		/** HUD Container. */		
		private var hud:GameHUD;
		
		private var downTimer:Timer;
		
		private var _context:GameContext;
//		private var startButton:Button;
		private var fireButton:Button;
		
		private var viewCamPosX:Number = -1;
		private var viewCamLensWidth:Number = -1;
		
		private var gameDistance:int = 0;
		
		public var heroAnim:AnimationSequence;
		private var mickeyTextureAtlas:TextureAtlas;
		
		private var groundLevel:int;
		
//		private var _portalEntryParticleSystem:ParticleSystem;
		
		public function GameState( context:GameContext ) 
		{
			_context = context;
			super();
		}

		override public function initialize():void 
		{
			super.initialize();
			
			// ground level y
			_context.groundLevel = stage.stageHeight * 0.9;
			groundLevel = _context.groundLevel;

			if ( _context.viewMaster == null ) {
				_context.viewMaster = new ViewMaster( _context, _ce.state );
			}
			
			_context.viewMaster.setState( this );
			
			mickeyTextureAtlas = Assets.getMickeyAtlas();
			heroAnim = new AnimationSequence(mickeyTextureAtlas, 
				[ "slice_", "mickeyjump2_", "mickeythrow_", 
					"mickeypush_", "mickeycarpet_", "mickeybubble_", "mickeyidle_", "mickeywatch_" ], 
				"slice_", 15, true, "none");
			
			StarlingArt.setLoopAnimations(["slice_", "mickeypush_", 
				"mickeycarpet_", "mickeybubble_", "mickeywatch_", "petebwwalk_", "plutowalk_" ]);

			
			_nape = new Nape("nape");
			_nape.gravity = Vec2.weak( 0, 1000 );
			add(_nape);
			
			_context._hero = new MickeyHero( "hero", {x:50, y: 100, radius:37, view:heroAnim, group:1}, 
				_context, heroAnim );
			_hero = _context._hero;
			add(_hero);
			
			_context.viewMaster.addBackground();
//			_hillsTexture = new HillsTexture();
			
//			_hills = new CustomHills("hills", 
//				{rider:_hero, sliceHeight:400, sliceWidth:100, currentYPoint:_context.groundLevel, //currentXPoint: 10, 
//					widthHills: stage.stageWidth + ( stage.stageWidth * 0.5 ), 
//					registration:"topLeft", view:_hillsTexture},
//				_context );
//			add(_hills);
			
//			_hills.visible = false;
			
			_cameraBounds = new Rectangle(0, _context.minY, int.MAX_VALUE, int.MAX_VALUE);

			view.camera.setUp( _hero, new MathVector(stage.stageWidth * 0.1, stage.stageHeight * 0.65), 
				_cameraBounds, new MathVector(0.05, 0.03));
			view.camera.allowZoom = true;
			
//			view.camera.zoomEasing = 0.01;
			view.camera.setZoom( _context.CAM_ZOOM );
			
			_context.hud = new GameHUD( _context );
			hud = _context.hud;
			this.addChild(hud);
			
			// Reset hud values and text fields.
			hud.foodScore = 0;
			hud.distance = 0;
			
			_context.initNewLevel();
//			_context.gameEndedSig.add( gameEndedControl );
			
			//first level:
			gameDistance = generateLevel( _context.currentLevel );
			
			_context.setViewCamLensWidth( view.camera.cameraLensWidth + ( view.camera.cameraLensWidth  * ( 1 - view.camera.getZoom() )) );
			
			_ce.playing = true;
		}
		
		private var levelDistance:int = 1000;
		private function generateLevel( level:String ):int
		{
			var rowData:RowData = MetaData.getRowData( "Levels", level );
			
			_context.currentLevelNum = rowData.getInt( "seq" );
			levelDistance = rowData.getInt( "distance" );
			
			var heroPos:Point = _context.locToPoint( rowData.getString( "hero_pos" ) );
			heroPos.y += _context.groundLevel;
			
			_hero.x = heroPos.x;
			_hero.y = heroPos.y;
			_ce.state.view.camera.update();
				
//			_context.nextLevel = rowData.getString( "next_level" );
			
			var levelComponents:Array = rowData.getArray( "components" );
			
			for (var i:int = 0; i < levelComponents.length; i++) 
			{
				var component:String = levelComponents[ i ];
				_context.viewMaster.createLevelComponent( component );
			}
			
			view.camera.bounds = new Rectangle( 0, _context.minY, 
					levelDistance , int.MAX_VALUE );
			
			return levelDistance;
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			_context.viewCamPos = view.camera.camPos;
			_context.viewCamLeftX = view.camera.camPos.x;
//			_context.viewCamRightX = _context.viewCamLeftX + _context.viewCamLensWidth;
			
			// update the hills here to remove the displacement made by StarlingArt. Called after all operations done.
//			_hillsTexture.update();
			
			// update HUD
			hud.distance = _hero.x * 0.1;
			
			hud.foodScore = _hero.numCoinsCollected;
			
			// game end distance
//			if ( _hero.x + _context.viewCamPosX > gameDistance ) {
//				_context.gameEnded();
//			}
			
			if ( _hero.x - 100 > levelDistance ) {//|| _hero.y > stage.stageHeight + 500) {
				_context.endGame();
			}
			
			if ( _hero.y > groundLevel + 500 ) {
				if ( !_hero._isFlying ) _hero.startFlying( true, true, 3000 );
				_hero.y = groundLevel + 500;
			}
			
			if ( _hero.onGround && _hero.body.velocity.x > 50 ) {
				_context.viewMaster.createEatParticle( _hero );
			}
			_context.viewMaster.animateEatParticles();
			
		}
	}
}
