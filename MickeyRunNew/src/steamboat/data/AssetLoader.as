package steamboat.data
{
	import com.playdom.common.interfaces.ILog;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	[SWF(width='760',height='590',backgroundColor='0xaaaaaa',frameRate='30')]
	
	public class AssetLoader extends Sprite
	{
		private var showResourceLoading:Boolean;
		
		/** Resource type: XML. */
		public static const TYPE_XML:String = "xml";
		
		/** Resource type: image. */
		public static const TYPE_IMAGE:String = "img";
		
		/** Resource type: SWF. */
		public static const TYPE_SWF:String = "swf";
		
		/** Resource type: text. */
		public static const TYPE_TEXT:String = "txt";
		
		/** Resource type: binary. */
		public static const TYPE_BINARY:String = "bin";
		
		/** Resource type: sound. */
		public static const TYPE_SOUND:String = "snd";

//		private var logger:Function;
		
		private var log:ILog;
		
		private var urlPrefix:String = "";

		private var pendingList:Dictionary = new Dictionary();
		
		public function AssetLoader( log:ILog, showResourceLoading:Boolean )
		{
			this.log = log;
			this.showResourceLoading = showResourceLoading;
		}
		
		/**
		 * Loads an external text file.
		 *  
		 * @param key  The asset key.
		 * @param url  The file's URL.
		 */
		public function loadText(key:String, url:String, listener:Function=null):Object 
		{
			return load({key:key, listener:listener, errorListener:listener, url:url, type:TYPE_TEXT}, new URLLoader());
		}	
		
		/**
		 * Loads an external text file.
		 *  
		 * @param key  The asset key.
		 * @param url  The file's URL.
		 */
		public function loadBinary(key:String, url:String, listener:Function=null):Object 
		{
			return load({key:key, listener:listener, errorListener:listener, url:url, type:TYPE_BINARY}, new URLLoader());
		}	
		
		/**
		 * Loads an external SWF file.
		 *  
		 * @param key  The asset key.
		 * @param url  The file's URL.
		 */
		public function loadSWF(key:String, url:String, listener:Function=null):Object {
			var loader:Loader = new Loader();
			return load({key:key, listener:listener, errorListener:listener, url:url, type:TYPE_SWF}, loader, loader.contentLoaderInfo);
		}
		
		/**
		 * Loads an external image file.
		 *  
		 * @param key  The asset key.
		 * @param url  The file's URL.
		 * 
		 */
		public function loadImage(key:String, filename:String, listener:Function=null):Object {
			var loader:Loader = new Loader();
			
//			var context:LoaderContext = new LoaderContext();
//			context.checkPolicyFile = true; 
			
			return load( {type:TYPE_IMAGE, listener:listener, errorListener:listener, key:key, url:filename}, loader, loader.contentLoaderInfo );
		}
		
		/**
		 * Loads an external sound file.
		 *  
		 * @param key  A key to associate with the image.
		 * @param filename  The file name.
		 */
		public function loadSound(key:String, filename:String, listener:Function=null):Object {
			var loader:Sound = new Sound();
			return load( {listener:listener, key:key, url:filename, type:TYPE_SOUND}, loader );
		}
		
		/**
		 * Loads a resource from a URL.
		 *  
		 * @param item  A data object describing the resouce (type, url, listener, errorListener, progressListener).
		 * @param loader  The loader object.
		 * @param dispatcher  The dispatcher object (if null, loader is used)
		 */
		public function load(item:Object, loader:Object, dispatcher:EventDispatcher=null, loadContext:LoaderContext=null):Object 
		{
			if (item.url == null || item.url == "null" || item.url == "undefined") 
			{
				log.warning("load: url is null" );
			}
			var suffix:String = "";
			item.dispatcher = dispatcher == null ? loader as EventDispatcher : dispatcher;
			pendingList[item.dispatcher] = item;
			item.dispatcher.addEventListener(ProgressEvent.PROGRESS, handleProgress); 
			item.dispatcher.addEventListener(Event.COMPLETE, handleComplete);
			item.dispatcher.addEventListener(IOErrorEvent.IO_ERROR, handleError);
			item.dispatcher.addEventListener(ErrorEvent.ERROR, handleError);
			
			try 
			{
				if (showResourceLoading) 
				{
					log.info( ".load: "+urlPrefix+item.url+suffix );
				}
				loader.load(new URLRequest(urlPrefix+item.url+suffix));
			}
			catch (err:Error) 
			{
				log.error("load error: "+err );
			}
			return item;
		}
		
		/**
		 * Handles load progress.
		 *  
		 * @param evt  The associated error.
		 */
		private function handleProgress(evt:ProgressEvent):void 
		{
			var item:Object = pendingList[evt.target];
//			if (progressWatcher)
//			{
//				progressWatcher.watchItemProgress(item, evt.bytesLoaded, evt.bytesTotal)
//			}
//			if (evt.bytesLoaded > 0 && evt.bytesLoaded < evt.bytesTotal) 
//			{
				if (item.progressListener != null) 
				{
					item.bytes = evt.bytesLoaded;
					item.percent = Math.floor(evt.bytesLoaded*100/evt.bytesTotal);
					item.progressListener( item );
				} 
//			}
		}
		
		/**
		 * Handles a completed load.
		 *  
		 * @param evt  The associated error.
		 */
		private function handleComplete(evt:Event):void 
		{
			var item:Object = pendingList[evt.target];
			if (item.listener != null) 
			{
				if ( item.type == TYPE_BINARY )
				{
					var data:ByteArray = evt.target.data as ByteArray;
					var loader:URLLoader = URLLoader(evt.target);
//					trace("completeHandler: " + loader.data);
					
//					var vars:URLVariables = new URLVariables(loader.data);
					var obj:Object = loader.data;
//					trace("The answer is " + vars.answer);

					item.listener( evt.target.data );
				}
				else
				{
					setData(item, evt);
					item.percent = 100;
					if (showResourceLoading) 
					{
						log.info(".handleComplete: "+item.url);
					}
					item.listener(item);
				}
			}
			destroyItem(item);
		}	
		
		/**
		 * Frees an item's resources for garbage collection.
		 * 
		 * @param item  A data item for a resource.
		 */
		private function destroyItem(item:Object):void {
			if (item.hasOwnProperty("dispatcher")) 
			{
				delete pendingList[item.dispatcher];
				removeEventListeners(item.dispatcher);
			}
			delete item.dispatcher;
			delete item.listener;
			delete item.progressListener;
			delete item.errorListener;
			delete item.type;
			delete item.data;
			delete item.url;
			delete item.key;
			delete item.preload;
			delete item.percent;
			delete item.error;
			delete item.context;
			delete item.h;
			delete item.scale9;
			delete item.w;
			delete item.preloadId;
			delete item.retrying;
		}
		
		/**
		 * Removes event listeners from a dispatcher.
		 * 
		 * @param item  The event dispatcher.
		 */
		private function removeEventListeners(dispatcher:EventDispatcher):void 
		{
			dispatcher.removeEventListener(ProgressEvent.PROGRESS, handleProgress); 
			dispatcher.removeEventListener(Event.COMPLETE, handleComplete);
			dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, handleError);
			dispatcher.removeEventListener(ErrorEvent.ERROR, handleError);
		}
		
		/**
		 * Sets the file info data property based on asset type.
		 *  
		 * @param item  The item info.
		 * @param evt   The associated event.
		 */
		private function setData(item:Object, evt:Event):void 
		{
			switch (item.type) 
			{
				case TYPE_IMAGE:
					item.data = Bitmap(evt.target.content).bitmapData;
					break;
				case TYPE_SOUND:
					item.data = evt.target;
					break;
				case TYPE_SWF:
					item.data = evt.target.content;
					break;
				case TYPE_XML:
					try
					{
						item.data = new XML(evt.target.data);
					}
					catch (err:Error)
					{
						log.error(".setData: "+err.message+" in "+item.url);
					}
					break;
				case TYPE_BINARY:
					var loader:URLLoader = URLLoader(evt.target);
					item.data = loader.data;
					break;
				case TYPE_TEXT:
					item.data = evt.target.data;
					break;
				default:
					break;
			}
		}           

		/**
		 * Handles error events.
		 *  
		 * @param evt  The associated error.
		 */
		private function handleError(evt:ErrorEvent):void 
		{
			try 
			{
				var key:Object = evt.target;
//				var key:Object = findPendingItemKey(evt.text);
//				if (key) 
//				{
					var item:Object = pendingList[key];
					if (item) 
					{
						delete pendingList[key];
						if ( item.retryable )
						{
							log.info(".handleError: "+item.url+"' could not be loaded ("+evt.text+")", this);
						}
						else
						{
							log.error(".handleError: "+item.url+"' could not be loaded ("+evt.text+")", this);
						}
						item.error = evt.text;
						item.percent = 100;
						if (item.errorListener != null) 
						{
							item.errorListener(item);
						} 
						destroyItem(item);
						return;
					}
//				}
//				log.error(".handleError: "+evt.text);
			}
			catch (err:Error) 
			{
				log.error(".handleError error: "+err.message);
				
				for each (item in pendingList) 
				{
					log.error(".handleError error: pending item " + item.url);
				}
				
			}
			removeEventListeners(evt.target as EventDispatcher);
		}
		
		/**
		 * Finds an item key in the pending list based on an error string; one 
		 * parameter should be null and the other non-null.
		 *  
		 * @param errorMsg  Error message containing item's URL; should be NULL if key is NOT NULL.
		 * @param key  The key to search for (used for sounds); ignored if errorMsg is NOT NULL.
		 * @return  The associated Dictionary key or null if not found.
		 */
		private function findPendingItemKey(errorMsg:String, itemKey:String=null):Object 
		{
			for (var key:Object in pendingList) 
			{
				var item:Object = pendingList[key];
				if (errorMsg) 
				{
					var url:String = item.url.indexOf("../") == 0 ? item.url.substring(3) : item.url;
					var idx:int = errorMsg.indexOf(url); 
					if (idx != -1 && idx == errorMsg.length-url.length) 
					{
						return key;
					}
				}
				else if (item && item.key == itemKey) 
				{
					return key;
				}
			}
			return null;
		}
		
	}
}