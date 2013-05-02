/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.gas.AnimControl;
    import com.playdom.gas.AnimList;

	/**
	 * Loads a SWF.
	 * 
	 * @author Rob Harris
	 */
	public class Load extends AnimBase	
	{
		/** The recycling pool */
		private static var _pool:Array = [];
		
		/** The system context */
		private var _context:Object;
		
		/** True after login command sent */
		private var _loading:Boolean;
		
		/** SWF symbol */
		private var _key:String;
		
		/** URL */
		private var _src:String;
		
        /**
         * Creates or reuses an instance of this class.
         *   
         * @return  An instance of this class. 
         */
        public static function make(alist:AnimList, wait:int, src:String, key:String, context:Object):Load 
        {
			// recycle or create an instance
			if (_pool.length > 0)
			{
				var anim:Load = _pool.pop();
			}
			else
			{
				anim = new Load();
			}
			// initialize the variables
			anim.wait = wait;
			anim.stime = 0;
			anim._context = context;
			anim._loading = false;
			anim._key = key;
			anim._src = src;
			
			// add it to the parent list
			alist.add(anim);
			return anim;
        }   
		
		/**
		 * Frees all resources for garbage collection.
		 */
		override public function destroy():void 
		{
			super.destroy();
			
			if (_pool.indexOf(this) == -1) 
			{
				_pool.push(this);
			}
		}	
                						
		/**
		 * Updates the animation at a regular interval.
		 * 
		 * @return True if the animation has completed. 
		 */
		override public function animate():Boolean
		{
			if ( !_loading )
			{
				var control:AnimControl = alist.control;
				if (stime == 0)
				{
	                stime = control.time;
				}
				if (control.time >= stime+wait)
				{
					if ( _context.swfs[ _key ] != null )
					{	// already loaded
						return true;
					}
					
					// load the SWF
					_context.assetLoader.loadSWF( _key, _context.urlPrefix + _src, _handleSwfLoaded );
					
					_loading = true;
				}
			}
			return false;
		}
		
		/**
		 * Called when the SWF has loaded.
		 *  
		 * @param item   The data.
		 */
		private function _handleSwfLoaded( item:Object ):void
		{
			if ( item.error )
			{
				_context.log.info( "error loading SWF: " + item.url );
			}
			else
			{
				// store the SWF in a hash table
				_context.swfs[ _key ] = item.data;
				try
				{
					// signal that the context is already initialized
					_context.initialized = true;
					
					// share the context object
					if ( item.data.hasOwnProperty( "context" ) )
					{
						item.data.context = _context;
					}
					
					// trigger the initialization logic by adding it to the stage (then remove it to be tidy)
					alist.dob.stage.addChild( item.data );
					alist.dob.stage.removeChild( item.data );
				}
				catch ( err:Error )
				{
					_context.log.info( "error initializing SWF: " + item.url );
				}
			}
			destroy();
		}
		
		/**
		 * Parses tokenized data to create an instance of this object.
		 *  
		 * @param tokenizer The script tokenizer.
		 * @param helper    The parser helper.
		 * @param context   The system context.
		 */
		public static function parse( tokenizer:Object, helper:Object, context:Object ):void
		{
			var anim:AnimBase = make( helper.alist,
				tokenizer.getInt( "wait", 0 ),
				tokenizer.getString( "src", "" ),
				tokenizer.getString( "key", "" ),
				context
			);
			helper.parseAnimAttributes( anim, tokenizer );
			tokenizer.destroy();
		}

	}
}