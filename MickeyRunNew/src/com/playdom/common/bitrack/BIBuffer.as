package com.playdom.common.bitrack
{
	import com.playdom.common.interfaces.ILoader;
	import com.playdom.common.util.NameValuesContainer;
	import com.playdom.common.util.Quiesce;
	
	import flash.events.Event;
	import flash.net.URLRequest;

	/**
	 * Buffers tracking requests. 
	 * @author Ikhabazian
	 * 
	 */
	public class BIBuffer
	{
		/**
		 * Default string for analytics requests
		 */
		internal static const URL_STRING:String = "http://weblogger-dynamic-lb.playdom.com/flash_log?";
		
		internal var headerNVC:NameValuesContainer;
		
		private var queue:Array /* of NameValueContainer */ ;
		
		private var shouldFlushOnInterval:Boolean;
		
		private static const TIMEOUT_MS:uint = 0;
		
		private var _flushInterval:int;
		
		private static const FLUSH_MISSES_BEFORE_ERROR:uint = 3;
		
		/**
		 * Errors 
		 */
		private static const FLUSH_MISS_ERROR:String = "BIBuffer does not have header information"
		
		private var flushMisses:uint = 0;
		
		private var quiesce:Quiesce;
		
		private var loader:ILoader;
		
		/**
		 * Constructor 
		 * @param flushOnInterval if true flushes happen on interval, if false flushes happen with every add
		 * 
		 */
		public function BIBuffer(shouldFlushOnInterval:Boolean, loader:ILoader)
		{
			this.loader = loader;
			this.shouldFlushOnInterval = shouldFlushOnInterval;
			if (shouldFlushOnInterval)
			{
				queue = [];
			}
			
		}
		
		internal function start(flushInterval: uint):void
		{
			if (shouldFlushOnInterval)
			{
				if (quiesce != null)
				{
					quiesce.destroy();
				}
				quiesce = new Quiesce(flush, flushInterval, BITrack.instance.log);
				this._flushInterval = flushInterval;
				quiesce.reset();
			}
		}
		
		internal function get flushInterval():uint
		{
			return _flushInterval;
		}
		
		internal function pushNVC(nvc:NameValuesContainer, forceFlush:Boolean): void
		{
			queue.push(nvc);
			if ((forceFlush) || (!shouldFlushOnInterval))
			{
				flush();
			}
		}
	
		internal function flush(): void
		{
			if (headerNVC)
			{
				while (queue.length>0)
				{
					var logNVC:NameValuesContainer = queue.pop();
					logNVC.addNVC(headerNVC);
					sendToBI(logNVC.toURL());
				}
			}
			else 
			{
				flushMisses++;
				if (flushMisses > FLUSH_MISSES_BEFORE_ERROR)
				{
					BITrack.instance.log.error(FLUSH_MISS_ERROR + " flush misses: " + flushMisses);
				}
			}
			quiesce.reset();
		}
		
		private function sendToBI(logString:String): void
		{
			var completeURL:String = URL_STRING + logString;
		
//			var req:URLRequest = new URLRequest(completeURL);
//			new WebLoader(req, TIMEOUT_MS);
			loader.loadResource( completeURL, TIMEOUT_MS );
			var callback:Function =BITrack.instance.sendCallback; 
			if (callback !== null)
			{
				callback(completeURL);
			}
		}
		
		/**
		 * 
		 * @param event
		 */
		private function onAnalysisError(event:Event): void
		{
			BITrack.instance.log.error("BIBuffer.onAnalysisError:" + event);
		}
		
		/**
		 * 
		 * @param event
		 */
		private function onAnalysisSuccess(event:Event): void
		{
			
		}
	}
}