package com.playdom.common.util
{
	import flash.utils.Dictionary;
	
	public class CallbackCollection
	{
		private var _d:Dictionary;
		
		public function CallbackCollection()
		{
		}
		
		public function add(f:Function):void
		{
			if (_d === null) _d = new Dictionary();
			_d[f] = f;
		}
		
		/**
		 * Returns true iff no more callbacks are in this collection.
		 */
		public function remove(f:Function):Boolean
		{
			if (_d === null) return true;
			delete _d[f];
			for each (var f0:Function in _d)
			{
				return false;
			}
			_d = null;
			return true;
		}
		
		public function call():void
		{
			if (_d === null) return;
			for each (var f:Function in _d)
			{
				f();
			}
		}
		
		public function callWithArgument(arg:Object):void
		{
			if (_d === null) return;
			for each (var f:Function in _d)
			{
				f(arg);
			}
		}
		
		public function clear():void
		{
			_d = null;
		}
		
	}
}