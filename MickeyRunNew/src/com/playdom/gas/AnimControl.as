/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas 
 {
    import com.playdom.common.interfaces.IBitmaps;
    import com.playdom.common.interfaces.ILog;
    import com.playdom.common.interfaces.ISWFObject;
    import com.playdom.common.interfaces.ISounds;
    import com.playdom.common.util.EnterFrameDispatcher;
    import com.playdom.gas.anims.Anim;
    
    import starling.display.DisplayObject;
    import starling.display.Sprite;
    import flash.utils.getTimer;
	
	/**
	 * Controls the animation system.  
	 * 
	 * @author Rob Harris
	 */
	public class AnimControl 
	{
		/** The asset hash object. */
        public var assets:ISWFObject;
		
		/** The image asset manager. */
		public var bitmapAssets:IBitmaps;
		
		/** The sound asset manager. */
		public var soundAssets:ISounds;
		
		/** Frames per second text field. */
		private var fpsText:Object;
		
		/** The current system time. */
		public var time:uint;
		
//		private var animDelay:uint;
		
		/** Frames per second time threshold. */
		private var fpsTime:uint;
		
		/** Frames per second counter. */
		private var fpsCount:int = 1;

		/** An array of Display Object groups (used for disassemble/assemble). */
		private var dob_groups:Array = [];
		
		/** An array of AnimList creator functions. */
		private var alist_creators:Array = [];
		
		/** The list of anim lists. */
		private var alists:Array = [];
				
		/** The list of animlists to be removed in the future. */
		private var remove_list:Array = new Array();
						
		/** The time adjustment value to keep time motion anims from jumping forward after a pause. */
		private var time_adj:int = 0;

		/** The last time when pause was started. */
		private var pause_time:uint = 0;
				
		/** The message logger. */
		public var log:ILog;
		
		/** True while in the animation loop. */
		private var animating:Boolean = false;
		
		/** The current index into the animation list. */
		private var animIdx:int; 
		
		public var viewWidth:int;
		
		public var viewHeight:int;
		
		public var bg:Sprite;
		
		public var sheetNames:Array = [];
		
		public var isoSpace:Object;
		
		private var _enterFrameDispatcher:EnterFrameDispatcher;
		
		/**
		 * Creates an instance of this class.
		 */
		public function AnimControl(viewWidth:int, viewHeight:int) 
		{
			this.viewWidth = viewWidth;
			this.viewHeight = viewHeight;
		}
				
		/**
		 * Starts the animation system.
		 */
		public function init(assets:ISWFObject, bitmapAssets:IBitmaps, soundAssets:ISounds, log:ILog):void
		{
			this.assets = assets;
			this.bitmapAssets = bitmapAssets;
			this.soundAssets = soundAssets;
			this.log = log;
		}		
		        
		/**
		 * Starts the animation system.
		 * 
		 * @param stage Optional stage object that will tie the system to the ENTER_FRAME event.
		 */
//		public function start( fps:int=30 ):void 
		public function start( enterFrameDispatcher:EnterFrameDispatcher ):void 
		{
			_enterFrameDispatcher = enterFrameDispatcher;
			_enterFrameDispatcher.regist(animate);
			
//			animDelay = 1000 / fps;
//			animDelay = 20;
//			timer = new Timer( animDelay );
//			timer.addEventListener( TimerEvent.TIMER, animate );
//			timer.start();
			
			time = getTimer() + time_adj;
			fpsTime = time + 1000;
		}		
		
		public function resetFPS():void
		{
			fpsTime = getTimer()+1000;
			fpsCount = 0;
		}
		
		/**
		 * Determines if the system is paused.
		 *
		 * @return True if animation system is paused..
		 */
		public function isPaused():Boolean
		{
			return pause_time != 0;
		}	
			
		/**
		 * Sets the pause state for all anim lists.
		 *
		 * @param paused True to pause; false to resume.
		 */
		public function setPause(paused:Boolean):void  
		{
			if (paused) 
			{
				if (pause_time == 0)
				{
					pause_time = getTimer();
					_enterFrameDispatcher.unregist(animate);
//					timer.reset();
				}			
			}
			else if (pause_time != 0) 
			{
				time_adj += pause_time-getTimer();
				_enterFrameDispatcher.regist(animate);
//				timer.start();
				pause_time = 0;			
			}
		}
			
		/**
		 * Adds an animated list.
		 * 
		 * @param list  The list to be added.
		 */
		public function addAnimList(alist:AnimList):void 
		{
			alists.push(alist);
		}
                
		/**
		 * Removes an animated list.
		 * 
		 * @param list  The list to be removed.
		 */
		public function removeAnimList(alist:AnimList):void 
		{
			var idx:int = alists.indexOf(alist);
			if (idx == -1)
			{
				alist.destroy();
				return;
			}
			alists.splice(idx, 1);
			if (idx <= animIdx)
			{
				animIdx--;
			}
			alist.destroy();
		}
		
        /**
         * Finds an animated list.
         * 
         * @param dob The list's display object.
         * @return The list.
         */
        public function findAnimList( dob:DisplayObject ):AnimList 
        {
            for each ( var alist:AnimList in alists )
            {
            	if ( alist.dob == dob )
            	{
            		return alist;
            	}
				var childList:AnimList = alist.findAnimList( dob );
				if ( childList != null )
				{
					return childList;
				}
            }
            return null;
        }
		
		public function findAnimByName( name:String ):Anim
		{
			for each ( var alist:AnimList in alists )
			{
				var childAnim:Anim = alist.findAnimByName( name );
				if ( childAnim != null )
				{
					return childAnim;
				}
			}
			return null;
		}
		
		public function findAnimByType( animClass:Class ):Anim 
		{
			for each ( var alist:AnimList in alists )
			{
				var childAnim:Anim = alist.findAnimByType( animClass );
				if ( childAnim != null )
				{
					return childAnim;
				}
			}
			return null;
		}
		
		private function handleEnterFrame():void
		{
			// optional frames-per-second display
			if (fpsText)
			{
				if (time > fpsTime)
				{
					fpsText.text = String(fpsCount);
					fpsCount = 0;
					fpsTime += 1000;
				}
				fpsCount++;
			}
		}
		
		/**
		 * Called approximately 30 times per second to provide an animation tick. The tick 
		 * call is passed to all active anim lists.
		 * 
		 * @param evt  The "enter frame" event.
		 */
		public function animate():void 
		{
			try
			{
//				var minDiff:int = 20;
//				var timeDiff:int = 0;
//				while ( timeDiff < minDiff )
//				{
					// update the global time value
//					time += animDelay;
					time = getTimer();
					
					// animate all animated lists
					animating = true;
					animIdx = 0;
					while (animIdx < alists.length) 
					{
						var alist:AnimList = alists[animIdx];
						if (alist.animate()) 
						{
							removeAnimList(alist);
						} 
						animIdx++;
					}
					animating = false;
		
					while ( remove_list.length > 0 )
					{
						alist = remove_list.pop();
						removeAnimList( alist );
						alist.returnToPool();
					}
					if ( needsRender )	// is this used?
					{
						needsRender = false;
						renderer();
					}
//					var realTime:uint = getTimer() + time_adj;
//					timeDiff = time - realTime;
//					if ( timeDiff >= minDiff )
//					{
//						timer.delay = timeDiff;
//					}
//				}
			}
			catch ( err:Error )
			{
				var st:String = err.getStackTrace();
				if ( log )
				{
					if ( st )
					{
						log.error( ".animate: " +st, this );
					}
					else
					{
						log.error( ".animate: " + err.message, this );
					}
				}
				else
				{
					if ( st )
					{
						trace( ".animate: " +st, this );
					}
					else
					{
						trace( ".animate: " + err.message, this );
					}
				}
				setPause( true );
			}
		}
        
        //------------------------ AnimList Creation -------------------------------           
 
		public var animListFactory:Function = AnimList.make;
		public var renderer:Function;
		public var needsRender:Boolean = false;
		public var currentObject:Object;
		
		public function removeInFuture( alist:AnimList ):void
		{
			remove_list.push( alist );
		}
		
		/**
		 * Creates an AnimList object with the DisplayObject attached to it, then attaches the AnimList to the animation system.
		 *   
		 * @param dob  The display object.
		 * 
		 * @return  The AnimList. 
		 */
		public function attachAnimList( dob:Object=null, keepAlive:Boolean=false ):AnimList 
		{
			var alist:AnimList = animListFactory( dob, this );
			alist.keepAlive = keepAlive;
			addAnimList(alist)
			return alist;
		}
		
        /**
         * Adds an AnimList creator to the pool.
         *
         * @param name     The creator name.
         * @param creator  The creator function.
         */
        public function addAnimListCreator(name:String, creator:Function):void
        {
            alist_creators[name] = creator;
        }
                
        /**
         * Creates one or more custom AnimList objects from a named creator.
         *
         * @param name  The creator's name.
         * @param amt   The amount of objects to create.
         * 
         * @return The AnimList object (the last one created if more than one). 
         */
        public function createAnimList(name:String, amt:int=1):AnimList
        {
            var alist:AnimList;
            var creator:Function = alist_creators[name];
            if (creator != null) 
            {
            	for (var i:int=0; i < amt; i++)
                {	
                    alist = creator(name);
                }
            }
            return alist;
        }
		
		public function clearAll( destroyDobs:Boolean=false ):void
		{
			while (alists.length > 0)
			{
				var alist:AnimList = alists.pop();
				if ( destroyDobs )
				{
					alist.destroyDob();
				}
				alist.destroy();
			}
			sheetNames.length = 0;
		}
		
		private var placers:Array = [];
		
		public function getPlacer(name:String):Function
		{
			return placers[name];
		}
		
		public function addPlacer(name:String, placer:Function):void
		{
			placers[name] = placer;
		}
		
		public function getDobGroup(name:String):Array
		{
			return dob_groups[name];
		}
		
		public function setDobGroup(name:String, group:Array):void
		{
			dob_groups[name] = group;
		}
		
		public function makeProto(context:Object, alist:AnimList, proto:String):AnimList
		{
			context.tempAlist = alist;
			alist = createAnimList(proto);
			context.tempAlist = null;
			return alist;
		}
		
		public function initFpsText( textField:Object ):void
		{
			fpsText = textField;
			_enterFrameDispatcher.regist(handleEnterFrame);
		}

	}
}