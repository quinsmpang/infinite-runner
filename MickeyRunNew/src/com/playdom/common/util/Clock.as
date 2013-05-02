package com.playdom.common.util
{
    import com.playdom.common.interfaces.ILog;
    
    import flash.utils.getTimer;

    public class Clock
    {
        public static var currentTimeMS:int;
        public static var deltaTimeMS:int;


        private var _stack:Array = [];
        private var _newCallbacks:Array = [];
        private var _stackDirty:Boolean = false;
        private var _sortDirty:Boolean = false;
        private var _hasEnterFrameEvents:Boolean = false;
        private static var _enterFrameCallbacks:CallbackCollection = new CallbackCollection();
        private static const _instance:Clock = new Clock();
		private static var _enterFrameDispatcher:EnterFrameDispatcher;

        public function Clock()
        {
            currentTimeMS = getTimer();
        }

		public static function init(enterFrameDispatcher:EnterFrameDispatcher):void{
			_enterFrameDispatcher = enterFrameDispatcher;
			_enterFrameDispatcher.regist( _instance._run );
		}
		
        public static function addEnterFrameCallBack(f:Function):void
        {
            _instance._hasEnterFrameEvents = true;
            _enterFrameCallbacks.add(f);
        }

        public static function removeEnterFrameCallBack(f:Function):void
        {
            _enterFrameCallbacks.remove(f);
        }

        public static function schedule(f:Function, time:int, log:ILog):uint
        {
            if (f === null)
            {
				if ( log )
				{
					log.error("scheduled callback was null", true);
				}
                return 0;
            }
            _instance._stackDirty = true;
            _instance._sortDirty = true;
            var callback:Callback = new Callback();
            callback.f = f;
            callback.time = currentTimeMS + time;
            callback.active = true;
            _instance._newCallbacks.push(callback);
            return callback.uid;
        }

        public static function reschedule(callbackId:uint, f:Function, time:uint, log:ILog):uint
        {
            cancel(callbackId);
            return schedule(f, time, log);
        }

        public static function cancel(id:uint):Boolean
        {
            var callBack:Callback = _instance._getCallbackById(id);
            if (callBack == null) return false;
            callBack.f = null;
            callBack.active = false;
            callBack.time = 0;
            return true
        }

        private function _run():void
        {
            var now:uint = getTimer();
            deltaTimeMS = currentTimeMS - now;
            currentTimeMS = now;

            if (_stackDirty) _cleanStack();
            if (_sortDirty) _cleanSort();

            var count:uint = _stack.length;
            while (count--)
            {
                var callback:Callback = _stack[count];
                if (currentTimeMS <= callback.time) break;
                _stack.pop();
                if (callback.active) callback.f();
                callback.f = null;
            }

            if (_hasEnterFrameEvents)
            {
                _enterFrameCallbacks.call();
            }
        }

        private function _cleanStack():void
        {
            _stack = _stack.concat(_newCallbacks);
            _newCallbacks.length = 0;
            _stackDirty = false;
        }

        private function  _cleanSort():void
        {
            _stack = _stack.concat(_newCallbacks);
            _stack.sortOn("time", 18); //Array.NUMERIC | Array.DESCENDING);
            _sortDirty = false;
        }

        private function _getCallbackById(id:uint):Callback
        {
            for each (var cb:Callback in _stack)
            {
                if (cb.uid === id) return cb;
            }
            for each (var pcb:Callback in _newCallbacks)
            {
                if (pcb.uid === id) return pcb;
            }
            return null;
        }
    }
}class Callback
{
    private static var NEXT_UID:uint = 1000;
    internal var uid:uint;
    // must be public for use with Array.SortOn
    public var time:int;
    internal var f:Function;
    internal var active:Boolean = true;
    function Callback():void
    {
        uid = NEXT_UID++;
    }
}
