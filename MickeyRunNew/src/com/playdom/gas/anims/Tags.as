/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.gas.AnimControl;
    import com.playdom.gas.AnimList;
    
    import flash.display.MovieClip;
    import flash.utils.getDefinitionByName;

	/**
	 * Loads a SWF.
	 * 
	 * @author Rob Harris
	 */
	public class Tags extends AnimBase	
	{
		/** The recycling pool */
		private static var _pool:Array = [];
		
		/** The system context */
		private var _context:Object;
		
		/** True while waiting for the correct frame */
		private var _loading:Boolean;
		
		/** root frame containing class definition */
		private var _frame:String;
		
		/** name of the document class for that frame */
		private var _docClass:String;
		
		/** the root movie clip */
		private var _rootMc:MovieClip;
		
        /**
         * Creates or reuses an instance of this class.
         *   
         * @return  An instance of this class. 
         */
        public static function make(alist:AnimList, wait:int, docClass:String, frame:String, context:Object):Tags 
        {
			// recycle or create an instance
			if (_pool.length > 0)
			{
				var anim:Tags = _pool.pop();
			}
			else
			{
				anim = new Tags();
			}
			// initialize the variables
			anim.wait = wait;
			anim.stime = 0;
			anim._context = context;
			anim._loading = false;
			anim._frame = frame;
			anim._docClass = docClass;
			
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
			_context = null;
			_docClass = null;
			_frame = null;
			_rootMc = null;
			
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
			if ( _loading )
			{
				if ( gotoFrame() )
				{
					return checkFrame();
				}
				return true;
			}
			else
			{
				var control:AnimControl = alist.control;
				if (stime == 0)
				{
	                stime = control.time;
				}
				if (control.time >= stime+wait)
				{
					_loading = true;
					if ( gotoFrame() )
					{
						return checkFrame();
					}
					return true;
				}
			}
			return false;
		}
		
		private function gotoFrame():Boolean
		{
			try
			{
//				_rootMc = alist.dob.root as MovieClip;
				_rootMc = _context.topLayer.root as MovieClip;
				_rootMc.gotoAndStop( _frame );
				return true;
			}
			catch ( err:Error )
			{
				_context.dispatcher.dispatchKeyEvent( "tags.frame.missing", _frame );
					
//				_context.log.info( "gotoFrame: " + err.message );
			}
			return false;
		}
		
		private function checkFrame():Boolean
		{
			if ( _rootMc )
			{
				if ( _rootMc.currentFrameLabel == _frame )
				{
					initHandlers();
					return true;
				}
			}
			return false;
		}
		
		private function initHandlers():void
		{
			if ( _docClass )
			{
				try
				{
					var mainClass:Object = getDefinitionByName( _docClass );
					if ( mainClass != null )
					{
						var main:Object = new mainClass( _context );
						if ( main != null )
						{
							main.initHandlers();
							_context.log.info( ".initHandlers: " + _frame + " frame tags initialized", this );
						}
					}
				}
				catch ( err:Error )
				{
					_context.log.info( ".initHandlers: " + err.message, this );
				}
			}
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
				tokenizer.getString( "class", "" ),
				tokenizer.getString( "frame", "" ),
				context
			);
			helper.parseAnimAttributes( anim, tokenizer );
			tokenizer.destroy();
		}

	}
}