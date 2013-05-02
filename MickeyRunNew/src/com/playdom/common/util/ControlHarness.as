/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
package com.playdom.common.util
{
	import com.playdom.common.interfaces.IDestroyable;
	import com.playdom.gas.AnimList;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;

	/**
	 * A harness for event listeners.
	 */
	public class ControlHarness extends Object implements IDestroyable
	{
		/** The recycling pool */
		private static var pool:Array = [];

		protected var context:Object;

		public var topLayer:Sprite;

		private var bindings:Array = [];

//		public var defaultContainer:DisplayObjectContainer;

		/**
		 * Creates an instance of this class.
		 */
        public function ControlHarness()
		{
		}

		public static function make( context:Object ):ControlHarness
		{
			// recycle or create an instance
			if (pool.length > 0)
			{
				var instance:ControlHarness = pool.pop();
			}
			else
			{
				instance = new ControlHarness();
			}
			instance.context = context;

			return instance;
		}

		/**
		 * Adds a listener to be notified of events associated with a specified key.
		 *
		 * @param key       The key.
		 * @param listener  The listener - will be passed the key and value.
		 */
		public function addEventListener( type:String, listener:Function, dispatcher:EventDispatcher ):void
		{
			if ( type && dispatcher && listener != null )
			{
				dispatcher.addEventListener( type, listener );
				bindings.push( { type:"event.listener", key:type, listener:listener, dispatcher:dispatcher } );

//				context.log.info( ".addEventListener: type = " + type + " in " + dispatcher, this );
			}
			else
			{
				context.log.error( ".addEventListener: could not add listener for type ( " + type + " )", this );
			}
		}

		private function removeBinding( type:String, listener:Function, dispatcher:Object ):Boolean
		{
			for (var i:int = 0; i < bindings.length; i++)
			{
				var binding:Object = bindings[ i ];
				if ( binding.key == type && binding.listener == listener && binding.dispatcher == dispatcher )
				{
					bindings.splice(i, 1);
					return true;
				}
			}
			return false;
		}

		/**
		 * Remove a listener to be notified of events associated with a specified key.
		 *
		 * @param key       The key.
		 * @param listener  The listener - will be passed the key and value.
		 */
		public function removeEventListener( type:String, listener:Function, dispatcher:EventDispatcher ):void
		{
			if ( type && dispatcher && listener != null )
			{
				dispatcher.removeEventListener( type, listener );
				removeBinding( type, listener, dispatcher );

//				context.log.info( ".removeEventListener: type = " + type + " in " + dispatcher, this );
			}
			else
			{
				context.log.error( ".removeEventListener: could not remove listener for type ( " + type + " )", this );
			}
		}

		/**
		 * Remove a listener to be notified of events associated with a specified key.
		 *
		 * @param key       The key.
		 * @param listener  The listener - will be passed the key and value.
		 */
		public function removeKeyListener( type:String, listener:Function, dispatcher:KeyDispatcher ):void
		{
			if ( type && dispatcher && listener != null )
			{
				dispatcher.removeKeyListener( type, listener );
				removeBinding( type, listener, dispatcher );
			}
			else
			{
				context.log.error( ".removeKeyListener: could not remove listener for type ( " + type + " )", this );
			}
		}

		/**
		 * Adds a listener to be notified of events associated with a specified key.
		 *
		 * @param key       The key.
		 * @param listener  The listener - will be passed the key and value.
		 */
		public function addKeyListener( key:String, listener:Function, dispatcher:KeyDispatcher ):void
		{
			if ( key && dispatcher && listener != null )
			{
				dispatcher.addKeyListener( key, listener );
				bindings.push( { type:"key.listener", key:key, listener:listener, dispatcher:dispatcher } );

//				context.log.info( ".addKeyListener: key = " + key + " in " + dispatcher, this );
			}
			else
			{
				context.log.error( ".addKeyListener: could not add listener for key ( " + key + " )", this );
			}
		}

		/**
		 * Frees all resources for garbage collection.
		 */
		public function destroy():void
		{
			releaseBindings();
			context = null;
			if ( topLayer )
			{
				if ( topLayer is IDestroyable )
				{
					IDestroyable( topLayer ).destroy();
				}
				else if ( topLayer.parent )
				{
					topLayer.parent.removeChild( topLayer );
				}
				topLayer = null;
			}

			if (pool.indexOf(this) == -1)
			{
				pool.push(this);
			}
		}

		/**
		 * Frees all resources for garbage collection.
		 */
		public function releaseBindings():void
		{
			while ( bindings.length > 0 )
			{
				var binding:Object = bindings.pop();
				if ( binding.type == "key.listener" )
				{
					binding.dispatcher.removeKeyListener( binding.key, binding.listener );
//					context.log.info( ".destroy: removed binding for key = " + binding.key + " in " + binding.dispatcher, this );
				}
				else if ( binding.type == "event.listener" )
				{
					binding.dispatcher.removeEventListener( binding.key, binding.listener );
//					context.log.info( ".destroy: removed binding for type = " + binding.key + " in " + binding.dispatcher, this );
				}
				else if ( binding.type == "display.object" )
				{
					removeBoundChild( binding );
//					context.log.info( ".destroy: removed binding for type = " + binding.type + " in " + binding.parent.name, this );
				}
				else if ( binding.type == "animlist" )
				{
					if ( binding.alist.dob == binding.dob )
					{
//						context.log.info( ".destroy: removed binding for alist = " + binding.dob.name, this );
						binding.alist.destroy();
					}
				}
			}
		}

		private function removeBoundChild( binding:Object ):void
		{
			if ( binding.parent && binding.dob.parent == binding.parent )
			{
				if ( binding.dob is IDestroyable )
				{
					( binding.dob as IDestroyable ).destroy();
				}
				else
				{
					binding.parent.removeChild( binding.dob );
				}
			}
		}

		public function removeChild( dob:DisplayObject ):void
		{
			for (var i:int = 0; i < bindings.length; i++)
			{
				var binding:Object = bindings[ i ];
				if ( binding.dob == dob )
				{
					removeBoundChild( binding );
					bindings.splice( i, 1 );
					return;
				}
			}
		}

		/**
		 * Adds a child to a container.
		 *
		 * @param child  The display object.
		 * @param cont  The container.
		 */
		public function addChild( child:DisplayObject, cont:DisplayObjectContainer=null ):DisplayObject
		{
//			if ( !cont )
//			{
//				cont = defaultContainer;
//			}
			if ( cont )
			{
				cont.addChild( child );
			}
			if ( child && child.parent )
			{
				bindings.push( { type:"display.object", dob:child, parent:child.parent } );

//				context.log.info( ".addChild: " + child.name + " to " + child.parent, this );
			}
			else
			{
				context.log.error( ".addChild: child and child.parent must be non-null", this );
			}
			return child;
		}

		/**
		 * Creates an AnimList object with the DisplayObject attached to it, then attaches the AnimList to the animation system.
		 *
		 * @param dob  The display object.
		 *
		 * @return  The AnimList.
		 */
		public function attachAnimList( dob:DisplayObject, alist:AnimList=null, keepAlive:Boolean=true ):AnimList
		{
			if ( dob )
			{
				if ( !alist )
				{
					alist = context.animControl.attachAnimList( dob, keepAlive );
				}
				bindings.push( { type:"animlist", dob:dob, alist:alist } );

//				context.log.info( ".attachAnimList: dob = " + dob.name, this );
			}
			else
			{
				context.log.error( ".attachAnimList: could not attach animlist to null", this );
			}
			return alist;
		}

		/**
		 * Registers an AnimList object attached to a display object.
		 *
		 * @param alist  The AnimList.
		 */
		public function registerAnimList( alist:AnimList ):AnimList
		{
			if ( alist && alist.dob )
			{
//				context.log.info( ".registerAnimList: dob = " + alist.dob.name, this );
				bindings.push( { type:"animlist", dob:alist.dob, alist:alist } );
			}
			else
			{
				context.log.error( ".registerAnimList: alist.dob is null", this );
			}
			return alist;
		}

	}
}