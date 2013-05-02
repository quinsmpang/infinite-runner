/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
package com.playdom.common.util 
 {
 	/**
	 * Processes a list of tasks in sequential order.
	 * 
	 * @author Rob Harris
	 */
	public class TaskSequence extends Object
	{
		/** The list of tasks. */
		private var processors:Array;
		
		/**
         * Constructor. 
		 */
		public function TaskSequence()
		{
			processors = [];
		}
		
		/**
		 * Releases all resources for garbage collection. 
		 */
		public function destroy():void
		{
			processors = null;
		}
		
		/**
		 * Adds a task to the sequence.
		 *  
		 * @param processor  The task function.
		 */
		public function addTask( processor:Function ):void
		{
			processors.push( processor );
		}
		
		/**
		 * Starts the sequence.
		 * 
		 * @param listener  Optional listener to be called when the sequence is complete.
		 */
		public function start( listener:Function ):void
		{
			if ( listener != null )
			{
				addTask( listener );
			}
			nextTask();
		}
		
		/**
		 * Called when a task is completed.
		 * 
		 * @param parm1	Dummy argument so that event dispatchers can call this method.
		 * @param parm2	Dummy argument so that event dispatchers can call this method.
		 */
		public function taskCompleted( parm1:Object=null, parm2:Object=null ):void
		{
			nextTask();
		}
		
		/**
		 * Starts the next task in the sequence.
		 */
		private function nextTask():void
		{
			if ( processors && processors.length > 0 )
			{
				var processor:Function = processors.shift();
				if ( processor != null )
				{
					processor();
					if ( processors && processors.length == 0 )
					{
						destroy();
					}
				}
			}
		}

	}
}