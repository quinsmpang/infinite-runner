/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.gas.AnimControl;
    import com.playdom.gas.AnimList;

	/**
	 * Performs a series of tasks.
	 * 
	 * @author Rob Harris
	 */
	public class TaskAnim extends AnimBase	
	{
		/** Special value to indicate no arguments associated with a task. */
		private static const NO_ARGS:String = "--"
			
		/** The recycling pool. */
		private static var _pool:Array = [];
		
		/** The stack of task handlers */
		private var taskStack:Array = [];
		
		/** The stack of arguments */
		private var argsStack:Array = [];
		
		/**
		 * Creates or reuses an instance of this class.
		 *   
		 * @param alist The parent animation list.
		 * @param wait  The wait period before starting.
		 * 
		 * @return  An instance of this class. 
		 */
		public static function make( alist:AnimList, wait:int=0 ):TaskAnim 
		{
			// recycle or create an instance
			if (_pool.length > 0)
			{
				var anim:TaskAnim = _pool.pop();
			}
			else
			{
				anim = new TaskAnim();
			}
			// initialize the variables
			anim.wait = wait;
			anim.stime = 0;
			
			// add it to the parent list
			alist.add(anim);
			return anim;
		}
		
		/**
		 * Adds a task to the sequence.
		 *  
		 * @param processor  The task function.
		 * @param args       Optional argument object.
		 */
		public function addTask( processor:Function, args:Object=null ):void
		{
			taskStack.push( processor );
			argsStack.push( args == null ? NO_ARGS : args );
		}
                						
		/**
		 * Updates the animation at a regular interval.
		 * 
		 * @return True if the animation has completed. 
		 */
		override public function animate():Boolean
		{
			var control:AnimControl = alist.control;
			if (stime == 0)
			{
                stime = control.time;
			}
			if (control.time >= stime+wait)
			{
				return nextTask();
			}
			return false;
		}
		
		/**
		 * Starts the next task in the sequence.
		 */
		private function nextTask():Boolean
		{
			if ( taskStack && taskStack.length > 0 )
			{
				var processor:Function = taskStack.shift();
				var args:Object = argsStack.shift();
				if ( processor != null )
				{
					if ( args == NO_ARGS )
					{
						processor();
					}
					else
					{
						processor( args );
					}
					if ( taskStack && taskStack.length == 0 )
					{
						return true;
					}
				}
			}
			return false;
		}
		
		/**
		 * Frees all resources for garbage collection.
		 */
		override public function destroy():void 
		{
			taskStack.length = 0;
			argsStack.length = 0;
			
			super.destroy();
			
			if (_pool.indexOf(this) == -1) 
			{
				_pool.push(this);
			}
		}	

	}
}