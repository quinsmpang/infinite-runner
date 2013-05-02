/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.gas.AnimControl;
    import com.playdom.gas.AnimList;
    import com.playdom.steamboat.SteamboatContext;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;

	/**
	 * Proccesses a series of SWFs.
	 * 
	 * @author Rob Harris
	 */
	public class SwfProcessor extends AnimBase	
	{
		/** The recycling pool */
		private static var _pool:Array = [];
		
		private var _context:SteamboatContext;
		
		private var _assetList:Array = [];
		
		private var _swf:Object;
		
		private var _swfName:String;
		
        /**
         * Creates or reuses an instance of this class.
         *   
         * @return  An instance of this class. 
         */
        public static function make( alist:AnimList, swf:Object, swfName:String, context:SteamboatContext ):SwfProcessor 
        {
			// recycle or create an instance
			if (_pool.length > 0)
			{
				var anim:SwfProcessor = _pool.pop();
			}
			else
			{
				anim = new SwfProcessor();
			}
			// initialize the variables
			anim._context = context;
			anim._swf = swf;
			anim._swfName = swfName;
			anim.stime = 0;
			anim.block = true;
			
			// add it to the parent list
			alist.add(anim);
			return anim;
        }   
		
		public function addAsset( assetId:String ):void
		{
			_assetList.push( assetId );
		}
                						
		/**
		 * Updates the animation at a regular interval.
		 * 
		 * @return True if the animation has completed. 
		 */
		override public function animate():Boolean
		{
			var control:AnimControl = alist.control;
			if (stime == 0)
			{
                stime = control.time;
			}
			if (control.time >= stime+wait)
			{
				_putCount = 0;
				while ( _putCount < 30 && _assetList.length > 0 )
				{
					var key:String = _assetList.pop();
					if ( putBitmapData( key ) )
					{
						putBitmapDataPostfix( key, "img_ing_", "_icon" );
						putBitmapDataPostfix( key, "img_ing_", "_orderIcon" );
						putBitmapDataPostfix( key, "img_prod_", "_icon" );
						putBitmapDataPostfix( key, "img_app_", "_icon" );
						putBitmapDataPostfix( key, "img_prod_", "_orderIcon" );
					}
				}
				if (_assetList.length == 0 ) 
				{
					_context.readySwfList[ _swfName ] = true;
				}
				return _assetList.length == 0;
			}
			return false;
		}
		
		/**
		 * Frees all resources for garbage collection.
		 */
		override public function destroy():void 
		{
			_context = null;
			_swf = null;
			_assetList.length = 0;
			
			super.destroy();
			
			if (_pool.indexOf(this) == -1) 
			{
				_pool.push(this);
			}
		}	
		
		private var _putCount:int;
		
		private function putBitmapDataPostfix( key:String, prefix:String, postfix:String ):void
		{
			if ( key.indexOf( prefix ) == 0 )
			{
				putBitmapData( key + postfix );
			}
		}
		
		private function putBitmapData( key:String ):Boolean
		{
			var bmp:Bitmap = _swf.getBitmap( key );
			if ( bmp )
			{
				var bmd:BitmapData = bmp.bitmapData;
				if ( bmd )
				{
					_context.assetHash.putBitmapData( key, bmd );
					_putCount++;
					return true;
				}
			}
			else
			{
				_context.log.info( ".putBitmapData: could not create " + key, this );
			}
			return false;
		}

	}
}