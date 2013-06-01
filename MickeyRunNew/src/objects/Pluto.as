package objects
{
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Enemy;
	import citrus.objects.platformer.nape.Platform;
	import citrus.physics.nape.NapeUtils;
	import citrus.view.starlingview.AnimationSequence;
	
	import nape.callbacks.InteractionCallback;
	
	public class Pluto extends Enemy
	{
		//		private var _hero:MickeyHero = null;
		private var enemyAnim:AnimationSequence = null;
		private var _context:GameContext;
		public var _isMoving:Boolean;
		
		public function Pluto(name:String, params:Object=null, context:GameContext=null, 
									enemyAnim:AnimationSequence=null )
		{
			this._context = context;
			this.enemyKillVelocity = context.heroMaxSpeed;
			this.enemyAnim = enemyAnim;
			
			_isMoving = true;
			super(name, params);
			//			this._hero = _hero;
			//			this._body.mass += 500;
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			if ( !_isMoving )
			{
				body.velocity.x = 0;
			}
			//			if (_hero.x - this.x > 300 ) {
			//				this._ce.state.remove(this);
			//				this.destroy();
			//				trace( "removed body" + this.x );
			//			}
		}
		
		override protected function updateAnimation():void {
			if ( _isMoving )
			{
				_animation = "plutowalk_";
			}
			else 
			{
				_animation = "plutohappy_";
			}
			//			_animation = _hurt ? "die" : "petebwwalk_";
		}
		
		//		override public function destroy():void {
		//			if (enemyAnim) enemyAnim.destroy();
		//			super.destroy();
		//		}
		
		private var hasCollided:Boolean = false;
		override public function handleBeginContact(callback:InteractionCallback):void {
			var collider:NapePhysicsObject = NapeUtils.CollisionGetOther(this, callback);
			
			if (callback.arbiters.length > 0 && callback.arbiters.at(0).collisionArbiter) {
				
				var collisionAngle:Number = callback.arbiters.at(0).collisionArbiter.normal.angle * 180 / Math.PI;
				
//				if (collider is _enemyClass && collider.body.velocity.y != 0 && collider.body.velocity.y > enemyKillVelocity)
				if ( collider is _enemyClass )
				{
//					hurt();
					if ( !hasCollided ) 
					{
						var mickey:MickeyHero = collider as MickeyHero;
						
						if ( mickey.body.position.x < this.body.position.x )
						{
							if ( mickey.inverted ) {
								// Mickey and Pluto should face each other
								mickey.turn( true );
							}
							this._inverted = true;
						}
						else
						{
							if ( !mickey.inverted ) {
								mickey.turn( false );
							}
							this._inverted = false;
						}
						
						_context.endGame();
						hasCollided = true;
					}
				}
				else if ( (collider is CustomPlatform && collisionAngle != 90) 
					|| collider is Enemy
					|| collider is CustomVerticalPlatform )
				{
					turnAround();
				}
			}
			
			// if the object is a missile, you get hurt, of course!
			if ( collider is CustomMissile ) {
//				this.hurt();
//				( collider as CustomMissile ).kill = true;
			}
		}
	}
}