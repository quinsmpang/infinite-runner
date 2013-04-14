package steamboat.data
{
	

	public class LoaderQueue
	{
		private var _context:GameContext;
		private var _delay:int = 0;
		private var _delayInc:int;
		
		public function LoaderQueue( context:GameContext )
		{
			_context = context;
			
			_delayInc = 0;
			_handler = _context.assetMgr;
		}
		
		public function loadItem( key:String, url:String, preloadId:String, type:String, block:Boolean=false ):void
		{
			var item:Object = _handler.loadItem( key, url, type, preloadId, handleItem );
			item.progressListener = handleItemProgress;
			item.retryable = true;
		}	
		
		private function handleItemProgress( item:Object ):void
		{
			
		}
		
		private var _handler:AssetManager;
		private function handleItem( item:Object ):void
		{
			if ( item.error )
			{
				//				if ( ++_retries <= RETRY_LIMIT )
				//				{
				//					stime = alist.control.time;
				//					wait = _retryDelay + Math.random() * _retryDelay / 2;
				//					_retryDelay *= 2;
				//					_context.log.info( ".handleItem: (" + _retries + ") retrying " + item.url + " in " + wait + " ms", this );
				//					_loading = false;
				//
				////					if ( _retries == 2 )	// for testing only
				////					{
				////						_url = _url.substr( 3 );
				////					}
				//				}
				//				else
				//				{
				//					_context.log.error( ".handleItem: retries failed for " + _url, this );;
				//				}
			}
			else
			{
				_handler.putItem( item );
//				destroy();
			}
		}
		
		public function resetDelay( v:int=0 ):void
		{
			_delay = v;
		}
		
	}
}