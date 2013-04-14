package {

	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import citrus.core.starling.StarlingState;
	import citrus.math.MathVector;
	import citrus.objects.platformer.nape.Sensor;
	import citrus.physics.nape.Nape;
	import citrus.view.starlingview.AnimationSequence;
	import citrus.view.starlingview.StarlingArt;
	
	import nape.constraint.WeldJoint;
	import nape.geom.Vec2;
	
	import objects.CustomCrate;
	import objects.CustomHills;
	
	import starling.display.Button;
	import starling.events.Event;
	import starling.extensions.particles.PDParticleSystem;
	import starling.extensions.particles.ParticleSystem;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	import steamboat.data.metadata.MetaData;
	import steamboat.data.metadata.RowData;
	
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
		
		private var downTimer:Timer;
		
		private var _context:GameContext;
		private var startButton:Button;
		private var fireButton:Button;
		
		private var viewCamPosX:Number = -1;
		private var viewCamLensWidth:Number = -1;
		
		private var gameDistance:int = 0;
		
		private var groundLevel:int = 0;
		
		public var heroAnim:AnimationSequence;
		private var mickeyTextureAtlas:TextureAtlas;
		public var enemyAnim:AnimationSequence;
		private var peteTextureAtlas:TextureAtlas;
		
		private var _particleSystem:ParticleSystem;
		
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
			
			_context.setViewCamLensWidth( view.camera.cameraLensWidth );// + view.camera.cameraLensWidth  * ( 1 - view.camera.getZoom() );

			if ( _context.viewMaster == null ) {
				_context.viewMaster = new ViewMaster( _context, _ce.state );
			}
			
			_context.viewMaster.setState( this );
			
			mickeyTextureAtlas = Assets.getMickeyAtlas();
			heroAnim = new AnimationSequence(mickeyTextureAtlas, 
				[ "slice_", "mickeyjump2_", "mickeythrow_", 
					"mickeypush_", "mickeycarpet_", "mickeybubble_", "mickeyidle_", "mickeywatch_" ], 
				"slice_", 15, true, "none");
			
			peteTextureAtlas = Assets.getPeteAtlas();
			
//			enemyAnim = new AnimationSequence(peteTextureAtlas, 
//				[ "petebwwalk_" ], 
//				"petebwwalk_", 12, true, "none");
			
			StarlingArt.setLoopAnimations(["slice_", "mickeypush_", 
				"mickeycarpet_", "mickeybubble_", "mickeywatch_", "petebwwalk_" ]);

			
			_nape = new Nape("nape");
			_nape.gravity = Vec2.weak( 0, 1000 );
			add(_nape);
			
			_hero = new MickeyHero( "hero", {x:50, y: 100, radius:40, view:heroAnim, group:1}, 
				_context, heroAnim );
			add(_hero);
			
			
//			_enemy = new CustomEnemy("enemy", {x:4000, y: _hero.y - 100,
//				radius:60, view:enemyAnim, group:1}, _hero);
//			add(_enemy);
//			_enemy = new CustomEnemy("enemy", {x:6000, y: _hero.y - 100,
//				radius:60, view:enemyAnim, group:1}, _hero);
//			add(_enemy);
			
			bg = new GameBackground("background", null, _hero, true);
//			add(bg);
			
//			_hillsTexture = new HillsTexture();
			
//			_hills = new CustomHills("hills", 
//				{rider:_hero, sliceHeight:400, sliceWidth:100, currentYPoint:groundLevel, //currentXPoint: 10, 
//					widthHills: stage.stageWidth + ( stage.stageWidth * 0.5 ), 
//					registration:"topLeft", view:_hillsTexture},
//				_context );
//			add(_hills);
			
//			_hills.visible = false;
			
			_cameraBounds = new Rectangle(0, _context.minY, int.MAX_VALUE, int.MAX_VALUE);

			view.camera.setUp( _hero, new MathVector(stage.stageWidth * 0.15, stage.stageHeight * 0.55), 
				_cameraBounds, new MathVector(0.05, 0.05));
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
			
			
			startButton = new Button(Assets.getAtlas().getTexture("startButton"));
			startButton.fontColor = 0xffffff;
			startButton.x = stage.stageWidth/2 - startButton.width/2;
			startButton.y = stage.stageHeight/2 - startButton.height/2;
			startButton.addEventListener(Event.TRIGGERED, onStartButtonClick);
			this.addChild(startButton);
			startButton.visible = false;
			
			//first level:
			gameDistance = generateLevel( _context.currentLevel );
			
			var psconfig:XML = Assets.getParticleConfig();
			var psTexture:Texture = Assets.getTexture( "_particlePng" );

			_particleSystem = new PDParticleSystem(psconfig, psTexture);
			_particleSystem.start();
			
			endLevel = new Sensor( "endLevel", { x: 3000, y: groundLevel - 100, height: 200 } );
			endLevel.view = _particleSystem;
			endLevel.onBeginContact.add( onSensorTouched );
//			endLevel.onBeginContact.add( onGameEnded );
			add( endLevel );
			
//			temp();
			_ce.playing = true;
		}
		 
		private var endLevel:Sensor;
		private function onFireButtonClick(event:Event):void
		{
			event.stopPropagation();
			event.stopImmediatePropagation();
		}
		
		public override function destroy():void
		{
			endLevel = null;
			_particleSystem = null;
			super.destroy();
		}
		
		private function onStartButtonClick(event:Event):void
		{
			startButton.removeEventListener(Event.TRIGGERED, onStartButtonClick);
//			_context.currentLevel += 1;
//			if ( _context.currentLevel > _context.maxLevel ) _context.currentLevel = 1;
			_ce.state = new GameState( _context );
		}
		
		private function gameEndedControl():void
		{
			_context.hasGameEnded = true;
			
//			view.camera.target = null;
//			view.camera.bounds = new Rectangle( 0, -800, 
////				view.camera.camPos.x + view.camera.cameraLensWidth
//				view.camera.camPos.x + ( view.camera.cameraLensWidth + view.camera.cameraLensWidth  * ( 1 - view.camera.getZoom() ) )
//					, int.MAX_VALUE );
		}
		
		private function onSensorTouched(obj:Object=null):void
		{
			_hero.x = endLevel.x - 1500;
			_hero.y = endLevel.y - 50;
		}
		
		private function onGameEnded(obj:Object=null):void
		{
			endLevel.onBeginContact.removeAll();
			_context.gameEnded();
			this._ce.playing = false;
			startButton.visible = true;
		}
		
		private var levelDistance:int = 1000;
		private function generateLevel( level:String ):int
		{
			var rowData:RowData = MetaData.getRowData( "Levels", level );
			
			levelDistance = rowData.getInt( "distance" );
			
			var levelComponents:Array = rowData.getArray( "components" );
			
			for (var i:int = 0; i < levelComponents.length; i++) 
			{
				var component:String = levelComponents[ i ];
				var componentData:RowData = MetaData.getRowData( "Components", component );
				
				var pos:Point = _context.locToPoint( componentData.getString( "pos" ) );
				pos.y += groundLevel;
				
				var width:int = componentData.getInt( "width" );
				var height:int = componentData.getInt( "height" );
				var friction:Number = componentData.getNumber( "friction" );
				
				_context.viewMaster.addPlatform( 
					pos.x, width, pos.y, false, friction, true );
			}
			
			view.camera.bounds = new Rectangle( 0, _context.minY, 
					levelDistance , int.MAX_VALUE );
			
			return levelDistance;
		}
		
		private function temp():void
		{
			var crate1:CustomCrate = _context.viewMaster.addCrate( false, true, 1000, groundLevel - 152 );
			var crate2:CustomCrate = _context.viewMaster.addCrate( false, true, 900, groundLevel - 305 );
			
			var joint1:WeldJoint = new WeldJoint( crate1.body, crate2.body,
//				Vec2.weak( 2050, groundLevel - 153 ),
				crate1.body.worldPointToLocal(
					Vec2.weak( crate1.x + crate1.width / 2, crate1.y + crate1.height / 2 )
					), 
				crate2.body.worldPointToLocal(
					Vec2.weak( crate2.x + crate2.width / 2, crate2.y + crate2.height / 2 )
				), 
				Math.PI/2 );
			joint1.space = _nape.space;
//			joint1.stiff = false;
			
//			joint1.active =  false;
			
//			joint1.damping = 0.001;
//			joint1.frequency = 5000;
		}
		
		private function generateFirstLevel():int {
			
			// ground
			_context.viewMaster.addPlatform( 1000, 2000, groundLevel, false, 1, false );
			_context.viewMaster.addPlatform( 2500, 500, groundLevel - 500, false, 1, false, 0 );
			_context.viewMaster.addPlatform( 4000, 2000, groundLevel, false, 1 );
			
//			_context.viewMaster.addPlatform( 5500, 1000, groundLevel - 400, false, 1 );
			_context.viewMaster.addMovingPlatform( 5500, groundLevel - 400, 6000, groundLevel - 400, 1000, 1, true, 100 );
//			_context.viewMaster.addPlatform( 7250, 1000, groundLevel - 200, false, 1 );
			_context.viewMaster.addMovingPlatform( 7250, groundLevel - 400, 7250, groundLevel - 1200, 1000, 1, true, 100 );
			
			_context.viewMaster.addPlatform( 9000, 2000, groundLevel - 1200, false, 1 );
			
			return 10000;
		}
		
		private function generateThirdLevel():int {
			
			// ground
			_context.viewMaster.addPlatform( 2000, 4000, groundLevel, false, 1 );
			_context.viewMaster.addPlatform( 6200, 4000, groundLevel, false, 1 );
//			_context.viewMaster.addPlatform( 10000, 20000, groundLevel, false, 1 );
			
			_context.viewMaster.addPlatform( 1500, 600, groundLevel - 200, false, 0, true, 0 );
//			_context.viewMaster.addPlatform( 2200, 600, groundLevel - 200, true, 0, true );
			_context.viewMaster.addPlatform( 2500, 1000, groundLevel - 700, false, 0, false );
//			_context.viewMaster.addPlatform( 3800, 1000, groundLevel - 400, false, 0, false, Math.PI/4 );
			_context.viewMaster.addMovingPlatform( 4000, groundLevel - 800, 4000, groundLevel - 1200, 1000, 1, false, 30 );
			_context.viewMaster.addMovingPlatform( 5300, groundLevel - 400, 5300, groundLevel - 600, 1000, 1, false, 30 );
			
			_context.viewMaster.addPlatform( 5500, 600, groundLevel - 200, false, 0, true, 0 );
			_context.viewMaster.addPlatform( 6800, 1000, groundLevel - 700, false, 0, false );
			
			_context.viewMaster.addPlatform( 9500, 600, groundLevel - 200, false, 0, true, 0 );
			_context.viewMaster.addPlatform( 10800, 1000, groundLevel - 700, false, 0, false );
			
			return 12000;
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
			
			return 3800;
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			_context.viewCamPos = view.camera.camPos;
			_context.viewCamPosX = view.camera.camPos.x;
			
			
			elapsed = timeDelta;
			
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
				onGameEnded();
			}
			
			if ( _hero.y > groundLevel + 500 ) {
				if ( !_hero._isFlying ) _hero._isFlying = true;
				_hero.y = groundLevel + 500;
			}
			
//			if ( _context.hasGameEnded ) {
////				if ( viewCamPosX == -1 ) viewCamPosX = view.camera.camPos.x;
//				if ( viewCamLensWidth == -1 ) 
//					viewCamLensWidth = view.camera.cameraLensWidth + view.camera.cameraLensWidth  * ( 1 - view.camera.getZoom() );
////					viewCamLensWidth = view.camera.cameraLensWidth;
//				
//				if ( _hero.x - 100 > levelDistance ) {
//					onGameEnded();
//				}
//			}
		}
	}
}
