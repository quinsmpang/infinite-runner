package objects
{
	import citrus.objects.platformer.nape.Enemy;
	import citrus.view.starlingview.AnimationSequence;

	public class CustomEnemy extends Enemy
	{
//		private var _hero:MickeyHero = null;
		private var enemyAnim:AnimationSequence = null;
		
		public function CustomEnemy(name:String, params:Object=null, context:GameContext=null, 
			enemyAnim:AnimationSequence=null )
		{
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
	}
}