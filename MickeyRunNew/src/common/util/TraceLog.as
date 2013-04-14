package common.util {
	import common.interfaces.ILog;

	/**
	 * A super simple implementation if <code>ILog</code> that writes messages to 
	 * <code>trace()</code> prefixed with the log level. This is the default logging
	 * implementation used by the CMS library.
	 * 
	 * @see Log
	 * @see ILog
	 */
	public class TraceLog implements ILog {
		/**
		 * @inheritDoc
		 */
		public function error(message:String, caller:Object=null):void {
			trace("CMS ERROR: " + message);
		}
		/**
		 * @inheritDoc
		 */
		public function warning(message:String, caller:Object=null):void {
			trace("CMS WARN: " + message);
		}
		/**
		 * @inheritDoc
		 */
		public function info(message:String, caller:Object=null):void {
			trace("CMS INFO: " + message);
		}
		/**
		 * @inheritDoc
		 */
		public function verbose(message:String, caller:Object=null):void {
			trace("CMS VERBOSE: " + message);
		}
	}
}