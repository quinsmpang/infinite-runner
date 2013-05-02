package com.playdom.common.util
{
	import com.playdom.common.interfaces.ILog;

    public class Quiesce
    {
        private var _useFunction:Function;
        private var _timeOutMS:int;
		private var _timeOutId:uint = 0;
		private var _log:ILog;
        //use reset
        public function Quiesce(runFunction:Function, timeout:int, log:ILog)
        {
			_log = log;
//            trace("************** Quiesce");
            if (timeout <0)
            {
                timeout = 0;
				if ( _log )
				{
					_log.warning("Quiesce was instantiated with a negitive wait time");
				}
            }
            _timeOutMS = timeout;
            _useFunction = runFunction;
            if (_useFunction == null && _log)
			{	
				_log.error("quiesce Function is null", true);
			}
        }

        public function reset():void
        {
//            trace("************** reset");
            _timeOutId = Clock.reschedule(_timeOutId, _execute, _timeOutMS, _log);
        }

        public function stop():void
        {
//            trace("************** stop");
            Clock.cancel(_timeOutId);
            _timeOutId = 0;
        }

        public function destroy():void
        {
//            trace("************** destroy");
            stop();
            _useFunction = null;
        }

        private function _execute():void
        {
//            trace("************** _execute");
            stop();
            _useFunction();
        }
    }
}
