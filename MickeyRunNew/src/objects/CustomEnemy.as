package objects
{
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Enemy;
	import citrus.objects.platformer.nape.Platform;
	import citrus.physics.nape.NapeUtils;
	import citrus.view.starlingview.AnimationSequence;
	
	import nape.callbacks.InteractionCallback;

	public class CustomEnemy extends Enemy
	{
//		private var _hero:MickeyHero = null;
		private var enemyAnim:AnimationSequence = null;
		
		public function CustomEnemy(name:String, params:Object=null, context:GameContext=null, 
			enemyAnim:AnimationSequence=null )
		{
			this.enemyKillVelocity = context.heroMaxSpeed;
			this.enemyAnim = enemyAnim;
			super(name, params);
//			this._hero = _hero;
			//			this._body.mass += 500;
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			
//			if (_hero.x - this.x > 300 ) {
//				this._ce.state.remove(this);
//				this.destroy();
				//				trace( "removed body" + this.x );
//			}
		}
		
		override protected function updateAnimation():void {
			_animation = "petebwwalk_";
//			_animation = _hurt ? "die" : "petebwwalk_";
		}
		
//		override public function destroy():void {
//			if (enemyAnim) enemyAnim.destroy();
//			super.destroy();
//		}
		
		override public function handleBeginContact(callback:InteractionCallback):void {
			var collider:NapePhysicsObject = NapeUtils.CollisionGetOther(this, callback);
			
			if (callback.arbiters.length > 0 && callback.arbiters.at(0).collisionArbiter) {
				
				var collisionAngle:Number = callback.arbiters.at(0).collisionArbiter.normal.angle * 180 / Math.PI;
				
				if (collider is _enemyClass && collider.body.velocity.y != 0 && collider.body.velocity.y > enemyKillVelocity)
					hurt();
				else if ((collider is Platform && collisionAngle != 90) || collider is Enemy)
					turnAround();
			}
				
			// if the object is a missile, you get hurt, of course!
			if ( collider is CustomMissile ) {
				this.hurt();
			}
		}
	}
}