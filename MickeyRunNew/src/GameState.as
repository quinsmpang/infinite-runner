package {

	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import citrus.core.starling.StarlingState;
	import citrus.math.MathVector;
	import citrus.objects.CitrusSprite;
	import citrus.physics.nape.Nape;
	import citrus.view.starlingview.AnimationSequence;
	import citrus.view.starlingview.StarlingArt;
	
	import nape.geom.Vec2;
	
	import objects.CustomHills;
	
	import starling.display.Button;
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
		private var _mickey:MickeyHero;
		
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
			_context.groundLevel = stage.stageHeight;
			groundLevel = _context.groundLevel;
			
			_context.maxY = _context.groundLevel + 200;

			if ( _context.viewMaster == null ) {
				_context.viewMaster = new ViewMaster( _context, _ce.state );
			}
			
			_context.viewMaster.setState( this );
			
			_context.initNewLevel();
			
			mickeyTextureAtlas = Assets.getMickeyAtlas();
			heroAnim = new AnimationSequence(mickeyTextureAtlas, 
				[ "slice_", "mickeyjump2_", "mickeythrow_", 
					"mickeypush_", "mickeycarpet_", "mickeybubble_", "mickeyidle_", "mickeywatch_" ], 
				"slice_", 12, true, "none");
			
			StarlingArt.setLoopAnimations(["slice_", "mickeypush_", 
				"mickeycarpet_", "mickeybubble_", "mickeywatch_", "petebwwalk_", "plutowalk_" ]);

			
			_nape = new Nape("nape");
			_nape.gravity = Vec2.weak( 0, 1000 );
			add(_nape);
			
			_context._mickey = new MickeyHero( "hero", {x:50, y: 100, radius:37, view:heroAnim, group:1}, 
				_context, heroAnim );
			_mickey = _context._mickey;
			add(_mickey);
			
			_context.viewMaster.addBackground();
//			_hillsTexture = new HillsTexture();
			
//			_hills = new CustomHills("hills", 
//				{rider:_hero, sliceHeight:400, sliceWidth:100, currentYPoint:_context.groundLevel, //currentXPoint: 10, 
//					widthHills: stage.stageWidth + ( stage.stageWidth * 0.5 ), 
//					registration:"topLeft", view:_hillsTexture},
//				_context );
//			add(_hills);
			
//			_hills.visible = false;
			
			_cameraBounds = new Rectangle(100, _context.minY, int.MAX_VALUE, int.MAX_VALUE);
			
			// sprite that will track Starling camera
			_context.viewMaster._cameraTracker = new CitrusSprite( "cameraTracker", { width: 1, height: 1 } );

			view.camera.setUp( _context.viewMaster._cameraTracker, new MathVector(stage.stageWidth * 0.1, stage.stageHeight * 0.75), 
				_cameraBounds, new MathVector(0.15, 0.08));
			view.camera.allowZoom = true;
			
//			view.camera.zoomEasing = 0.01;
			view.camera.setZoom( _context.CAM_ZOOM );
			
			_context.hud = new GameHUD( _context );
			hud = _context.hud;
			this.addChild(hud);
			
			// Reset hud values and text fields.
			hud.foodScore = 0;
			hud.distance = 0;
			
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
			
			_mickey.x = heroPos.x;
			_mickey.y = heroPos.y;
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
			hud.distance = _mickey.x * 0.1;
			
			_context.viewMaster._cameraTracker.x = _mickey.body.position.x;
			_context.viewMaster._cameraTracker.y = _mickey.body.position.y;
//			_context.viewMaster._cameraTracker.x = _context._pluto.body.position.x;
//			_context.viewMaster._cameraTracker.y = _context._pluto.body.position.y;
			
			hud.foodScore = _mickey.numCoinsCollected;
			
			// game end distance
//			if ( _hero.x + _context.viewCamPosX > gameDistance ) {
//				_context.gameEnded();
//			}
			
			if ( _mickey.x - 100 > levelDistance ) {//|| _hero.y > stage.stageHeight + 500) {
//				_context.endGame();
				_mickey.x = 100;
//				if ( _mickey.y > _context.groundLevel - 100 ) {
					_mickey.y = _context.groundLevel - 100;
//				}
				_mickey._isMoving = false;
				_mickey._isFlying = false;
			}
			
			if ( _mickey.y > _context.maxY ) {
				if ( !_mickey._isFlying ) _mickey.startFlying( true, true, 1500 );
				_mickey.y = _context.maxY;
			}
			
			if ( _mickey.y < _context.minY + 200 ) {
				_mickey.y = _context.minY + 200;
			}
			
			if ( _mickey.onGround && _mickey.body.velocity.x > 50 ) {
				_context.viewMaster.createEatParticle( _mickey );
			}
			_context.viewMaster.animateEatParticles();
			
		}
	}
}
