package com.playdom.common.util
{
	
	import flash.display.MovieClip;
	
	public class EnterFrameDispatcher
	{
		// Embeded two frame movieclip
		[Embed(source="/../../../../twoFrameMC.swf", symbol='TwoFrame')]
		private var TwoFrame:Class;
		
		// Collection of functions to be called
		private var _callbacks:CallbackCollection = new CallbackCollection();
		
		// Instance of the two frame movieclip
		private var _twoFrame:MovieClip;
		
		public function EnterFrameDispatcher()
		{
			_twoFrame = new TwoFrame();
			_twoFrame.addFrameScript(0, enterFrameHandler, 1, enterFrameHandler); // Add script to both frame. Each frame call the other one creating a loop
		}
		
		/**
		 * Call all functions registered
		 */
		private function enterFrameHandler():void
		{
			_callbacks.call(); // Call all functions
		}
		
		/**
		 * Regist a function into the collection
		 */
		public function regist(f:Function):void{
			_callbacks.add(f); // Regist a function into the colecction
		}
		
		/**
		 * Unregist a function from the collection
		 */
		public function unregist(f:Function):void{
			_callbacks.remove(f);
		}
		
		/**
		 * Clear the collection. Removing all functions registered
		 */
		public function clear():void{
			_callbacks.clear();
		}
		
		/**
		 * Get the two frame movieclip instance
		 */
		public function get mc():MovieClip{
			return _twoFrame;
		}
	}
}