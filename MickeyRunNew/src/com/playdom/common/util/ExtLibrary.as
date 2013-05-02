/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
package com.playdom.common.util 
{
	import com.playdom.common.interfaces.ILog;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.media.Sound;
	 
	/**
	 * Manages all external SWF libraries.
	 * 
	 * @author Rob Harris
	 */
	public class ExtLibrary extends Object 
	{
		public var loaderInfo:LoaderInfo;
		
		private var logger:ILog;
		
		/**
		 * Creates an instance of this class.
		 */
		public function ExtLibrary() 
		{
		}
		
		public function init(logger:ILog, loaderInfo:LoaderInfo):void
		{
			this.logger = logger;
			this.loaderInfo = loaderInfo;
		}
		
		/**
		 * Creates a DisplayObject object from a library symbol in an external SWF.
		 *  
		 * @param swf  The external SWF object.
		 * @param sym  The symbol name.
		 * 
		 * @return     A new DisplayObject object.
		 */				
		public function makeLibraryDisplayObject(sym:String, loaderInfo:LoaderInfo=null, logger:ILog=null):DisplayObject 
		{
			if (loaderInfo == null)
			{
				loaderInfo = this.loaderInfo;
			}
			return makeDisplayObject(sym, loaderInfo, logger);
		}		
		
		/**
		 * Creates a DisplayObject object from a library symbol in an external SWF.
		 *  
		 * @param swf  The external SWF object.
		 * @param sym  The symbol name.
		 * 
		 * @return     A new DisplayObject object.
		 */				
		public static function makeDisplayObject(sym:String, loaderInfo:LoaderInfo=null, logger:ILog=null):DisplayObject 
		{
			var asClass:Class = loaderInfo != null ? getClass(sym, loaderInfo, logger) : null;
			return asClass ? new asClass() as DisplayObject : null;
		}		
		
		/**
		 * Creates a BitmapData object from a library symbol in an external SWF.
		 *  
		 * @param swf  The external SWF object.
		 * @param sym  The symbol name.
		 * 
		 * @return     A new BitmapData object.
		 */				
		public static function makeBitmapData(sym:String, loaderInfo:LoaderInfo=null, logger:ILog=null):BitmapData 
		{
			var asClass:Class = loaderInfo != null ? getClass(sym, loaderInfo, logger) : null;
			return asClass ? new asClass() as BitmapData : null;
		}		
						
		/**
		 * Creates a Bitmapdata object from a library symbol in an external SWF.
		 *  
		 * @param swf  The external SWF object.
		 * @param sym  The symbol name.
		 * 
		 * @return     A new BitmapData object.
		 */
		public function makeLibraryBitmapData(sym:String, loaderInfo:LoaderInfo=null):BitmapData 
		{
			if (loaderInfo == null)
			{
				loaderInfo = this.loaderInfo;
			}
//			var asClass:Class = loaderInfo != null ? getClass(sym, loaderInfo, logger) : null;
//			return asClass ? new asClass() as BitmapData: null;
			return makeBitmapData(sym, loaderInfo, logger);
		}		
						
		/**
		 * Creates a Sound object from a library symbol in an external SWF.
		 *  
		 * @param sym  The symbol name.
		 * 
		 * @return     A new Sound object.
		 */
		public function makeLibrarySound(sym:String):Sound 
		{
			var asClass:Class = loaderInfo != null ? getClass(sym, loaderInfo, logger) : null;
			return asClass ? new asClass() as Sound : null;
		}	
									
		/**
		 * Locates the class object associated with a library symbol in an external SWF.
		 *  
		 * @param sym  The symbol name.
		 * 
		 * @return     A new Sound object.
		 */
		public function getLibraryClass(sym:String):Class 
		{
			return loaderInfo != null ? getClass(sym, loaderInfo, logger) : null;
		}		
				
		/**
		 * Fetches a class from the library.
		 *  
		 * @param className  The class name.
		 * @param loaderInfo The SWF's loader info.
		 * 
		 * @return The associated class or null if not found. 
		 * 
		 */
		public static function getClass(className:String, loaderInfo:LoaderInfo, logger:ILog):Class 
		{
			if (className != null)
			{
				try
				{
					return loaderInfo.applicationDomain.getDefinition(className) as Class;
				}
				catch (err:Error)
				{
					if (logger)
					{
//						logger.warning(".getClass: error loading "+className+" ("+err+")", "ExtLibrary");
					}
				}
			}			
			return null;
		}		
	}
}