/** * Playdom, Inc. (c)2013 All Rights Reserved */package common.util {	import flash.utils.Dictionary;		/**	 * Dispatches key/value messages to subscribed listeners.  Further messages can  	 * be dispatched during a dispatch.  Listeners can be removed during a dispatch.	 * 	 * @author Rob Harris	 */	public class KeyDispatcher extends Object	{		/** Instance name; very helpful when debugging multiple dispatchers. */		public var name:String;				/** List of listeners for each key. */		private var _listeners:Dictionary = new Dictionary();				/** Current call depth of the dispatch. */		private var _callDepth:int = 0;				/** Listener keys to be removed after a dispatch. */		private var _keysToRemove:Array = [];				/** Listeners to be removed after a dispatch. */		private var _listenersToRemove:Array = [];				/**		 * Creates an instance of this class 		 * 		 * @param name An optional name to be used for debugging multiple displatchers.		 */		public function KeyDispatcher( name:String = "noname" )		{			this.name = name;		}				/**		 * Adds a listener to be notified of events associated with a specified key.		 *		 * @param key       The key.		 * @param listener  The listener - will be passed the key and value.		 */		public function addKeyListener( key:String, listener:Function ):void 		{			if ( listener != null )			{				var arr:Array = _listeners[ key ];				if ( arr == null )				{	// create a new array for the first listener					_listeners[ key ] = [ listener ];				}				else				{	// add the listener to the array					var idx:int = arr.indexOf( listener );					if ( idx == -1 )					{						arr.push( listener );					}				}			}		}				/**		 * Removes a key listener.		 *		 * @param key       The key.		 * @param listener  The listener.		 */		public function removeKeyListener( key:String, listener:Function ):void 		{			var arr:Array = _listeners[ key ];			if ( arr != null )			{				// call depth will be non-zero during a dispatch				if ( _callDepth == 0 )				{	// remove the listener now					var idx:int = arr.indexOf( listener );					if ( idx != -1 )					{						arr.splice( idx, 1 );					}					if ( arr.length == 0 )					{						delete _listeners[ key ];					}				}				else				{	// save key and listener for future removal					_keysToRemove.push( key );					_listenersToRemove.push( listener );				}			}		}				/**		 * Dispatches a key event with an optional associated object.		 *		 * @param key  The key.		 * @param obj  The object.		 */		public function dispatchKeyEvent( key:String, data:Object=null ):void 		{			if ( key ) 			{				var arr:Array = _listeners[ key ];				if ( arr != null )				{					// call depth allows for dispatches within dispatches					_callDepth++;										// call each listener					for (var i:int = 0; i < arr.length; i++) 
					{
						var listener:Function = arr[ i ];						var index:int = _listenersToRemove.indexOf( listener ); 						if ( index == -1 || _keysToRemove[ index ] != key )						{	// the listener is not marked for future removal so it is OK to call							listener( key, data );						}					}
										// call depth will be zero when done dispatching; then remove all marked listeners					if ( --_callDepth == 0 )					{						while ( _keysToRemove.length > 0 )						{							removeKeyListener( _keysToRemove.shift(), _listenersToRemove.shift() )						}					}				}			}		}				/**		 * Returns a string representation of the instance.		 *  		 * @return A string. 		 */		public function toString():String		{			return "Dispatcher ( "+name+" )"		}			}}