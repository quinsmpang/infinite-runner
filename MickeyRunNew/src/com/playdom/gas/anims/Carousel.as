/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
    import com.playdom.common.util.FindChild;
    import com.playdom.common.util.Hashtable;
    import com.playdom.gas.AnimControl;
    import com.playdom.gas.AnimList;
    import com.playdom.gas.parsing.ParserHelper;
    import com.playdom.gas.parsing.ScriptTokenizer;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;

	/**
	 * Carousel controller; works with a group and item prototypes.
	 * 
	 * @author Rob Harris
	 */
	public class Carousel extends AnimBase
	{
		/** The recycling pool */
		private static var pool:Array = [];
		
		private var _context:Object;
		private var _prefix:String;
		private var _prevButton:DisplayObject;
		private var _nextButton:DisplayObject;
		private var _exitButton:DisplayObject;
		private var _panDur:int;
		private var _scrollX:int;
		private var _scrollXMax:int;
		private var _scrollY:int;
		private var _pageW:int;
		private var _itemGap:int;

		/**
         * Creates or reuses an instance of this class.
         *   
         * @return  An instance of this class. 
         */
        public static function make( alist:AnimList, prefix:String, spacing:int, context:Object ):Carousel 
        {
			// recycle or create an instance
			if (pool.length > 0)
			{
				var anim:Carousel = pool.pop();
			}
			else
			{
				anim = new Carousel();
			}
			// initialize the variables
			anim._prefix = prefix;
			anim._context = context;
			anim.stime = 0;
			anim._panDur = 250;
			anim._scrollX = 0;
			anim._scrollY = 0;
			anim._itemGap = spacing;
			
			// add it to the parent list
			alist.add( anim );
			return anim;
        }   
		
		/**
		 * Frees all resources for garbage collection.
		 */
		override public function destroy():void 
		{
			_context.dispatcher.removeKeyListener( "close.carousel", handleExitClick );
			_prefix = null;
			super.destroy();
			if (pool.indexOf(this) == -1) 
			{
				pool.push(this);
			}
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
				
				var rect:Rectangle = alist.dob.scrollRect;
				if ( rect == null )
				{
					_context.log.warning( "Carousel.animate: no scroll rect found" );
					return true;
				}
				_context.dispatcher.addKeyListener( "close.carousel", handleExitClick );
				
				_prevButton = FindChild.byName( _prefix + "Prev", alist.dob.parent );
				makeClickable( _prevButton as Sprite, handlePrevClick );
				
				_nextButton = FindChild.byName( _prefix + "Next", alist.dob.parent );
				makeClickable( _nextButton as Sprite, handleNextClick );
				
				_exitButton = FindChild.byName( _prefix + "Exit", alist.dob.parent );
				makeClickable( _exitButton as Sprite, handleExitClick );
				
				_scrollX = rect.x;
				_scrollY = rect.y;
				_pageW = rect.width;
//				_scrollXMax = alist.dob.width - _pageW;
				
				var vars:Hashtable = _context.animVars;
				var items:Array = vars.getString( _prefix + "Items", "" ).split( " " );
				var x:int = 10;
				_context.tempLayer = alist.dob;
				for (var i:int = 0; i < items.length; i++) 
				{
					var item:String = items[ i ];
					if ( item )
					{
						vars.setString( "rackItemType", item );
						
//						var data:Array = item.split( "." );
						vars.setInt( "rackItemX", x );
//						
//						vars.setString( "rackItemDescr", vars.getString( data[ 0 ], "(descr)" ) );
//						vars.setString( "rackItemType", data[ 1 ] );
//						vars.setString( "rackItemImage", data[ 1 ] );
//						vars.setString( "rackItemCost", vars.getString( data[ 2 ], "(cost)" ) );
						_context.animParser.helper.alist = alist;
						var proto:AnimList = _context.animControl.createAnimList( _prefix + "Item" );
						_context.animParser.helper.alist = null;
						
						x += _itemGap;
					}
				}
				_scrollXMax = x - _pageW;
				_context.tempLayer = null;
				
			}
			return false;
		}
		
		private function makeClickable( spr:Sprite, handler:Function ):void
		{
			spr.addEventListener( MouseEvent.CLICK, handler );
			spr.mouseChildren = false;
			spr.buttonMode = true;
			spr.useHandCursor = true;
		}
		
		private function pan( x:int ):void
		{
			x = Math.min( _scrollXMax, Math.max( 0, x ) );
			if ( x != _scrollX)
			{
				_scrollX = x;
				Path.make( alist, _scrollX, _scrollY, 0, _panDur, true );
			}
		}
		
		private function handleExitClick( arg1:Object=null, arg2:Object=null ):void
		{
			var proto:String = arg2 is String ? arg2 as String : _prefix + "Done";
			_context.animControl.createAnimList( proto );
			
			var popup:DisplayObject = FindChild.byName( _prefix, _context.playfieldLayer );
			var alist:AnimList = _context.animControl.findAnimList( popup );
			if ( alist == null )
			{
				alist = _context.animControl.attachAnimList( popup );
			}
			Set.make( alist, 0, null, null ).killDob = true;
			destroy();
		}
		
		private function handleNextClick( evt:Event ):void
		{
			pan( _scrollX + _pageW );
		}
		
		private function handlePrevClick( evt:Event ):void
		{
			pan( _scrollX - _pageW );
		}
		
		/**
		 * Parses tokenized data to create an instance of this object.
		 *  
		 * @param tokenizer The script tokenizer.
		 * @param helper    The parser helper.
		 * @param context   The system context.
		 */
		public static function parse( tokenizer:ScriptTokenizer, helper:ParserHelper, context:Object ):void
		{
			var anim:AnimBase = make(helper.alist,
				tokenizer.getString( "prefix", "rack" ), 
				tokenizer.getInt( "spacing", 200 ), 
				context
			);
			helper.parseAnimAttributes(anim, tokenizer);
			tokenizer.destroy();
		}
		
	}
}