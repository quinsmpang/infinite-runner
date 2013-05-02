/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas
 {
	import com.playdom.common.interfaces.IDestroyable;
	import com.playdom.common.recycle.RecycleRef;
	import com.playdom.gas.anims.Anim;
	import com.playdom.gas.anims.AnimBase;
	import com.playdom.gas.interfaces.IHflip;
	
	import citrus.core.CitrusObject;
	
	import starling.display.DisplayObject;

	/**
	 * Holds a list of animators and links them to a display object.
	 *
	 * @author Rob Harris
	 */
	public class AnimList extends Anim implements IHflip
	{
		/** The recycling pool */
		private static var pool:Array = [];

		private static var popCounter:int = 0;
		private static var instanceCounter:int = 0;
		private static var makeCounter:int = 0;
		private static var destroyCounter:int = 0;

   		/** The animation controller object. */
		public var control:AnimControl;

   		/** The associated display object. */
		public var dob:Object;

		/** True if the list should be killed. */
		public var kill:Boolean;

		/** True if the list should be kept alive when empty. */
		public var keepAlive:Boolean;

		/** Floating point x location that can be shared by Anims in the same AnimList. */
		public var x_loc:Number = 0;

		/** Floating point y location that can be shared by Anims in the same AnimList. */
		public var y_loc:Number = 0;

		/** The current index into the animation list. */
		protected var animIdx:int;

		/** True while the list is paused. */
		protected var paused:Boolean;

		/** The list of anims. */
		protected var list:Array = new Array();

		/** The list of recycle references. */
		private var refs:Array = [];

//		public function get dob():DisplayObject
//		{
//			return _dob;
//		}
//
//		public function set dob( v:DisplayObject ):void
//		{
//			_dob = v;
//		}

		/**
		 * Creates or recycles an instance of this class.
		 *
		 * @param dob      The display object to attach to the list.
		 * @param control  The animation controller.
		 * @param recycler The recycling manager.
		 *
		 * @return An instance of this class.
		 */
		public static function make(dob:Object, control:AnimControl):AnimList
		{
			makeCounter++;
			// recycle or create an instance
			if (pool.length > 0)
			{
				var alist:AnimList = pool.pop();
				popCounter++;
			}
			else
			{
				instanceCounter++;
				alist = new AnimList();
			}

			// initialize the variables
			alist.dob = dob;
			alist.control = control;
			alist.kill = false;
			alist.keepAlive = false;
			alist.x_loc = 0;
			alist.y_loc = 0;
			alist.animIdx = 0;
			alist.list.length = 0;
			alist.paused = false;

			return alist;
		}

		public function returnToPool():void
		{
			if ( pool.indexOf( this ) == -1 )
			{
				pool.push( this );
			}
		}

		/**
		 * Frees all resources for garbage collection.
		 */
		override public function destroy():void
		{
			if (control)
			{
				var ctrl:AnimControl = control;
				control = null;

				while ( refs.length > 0 )
				{
					var ref:RecycleRef = refs.pop();
					ref.setAnimList( null );
				}

				if ( !alist )
				{
					ctrl.removeInFuture( this );
				}
				else if (pool.indexOf(this) == -1)
				{
					destroyCounter++;
					pool.push(this);
				}
//				else
//				{
//					trace( "AnimList.destroy: recycling error" );
//				}
				clearAnims( true );
				dob = null;
//				if ( !alist )
//				{
//					ctrl.removeInFuture( this );
//				}
//				control = null;
				while (list.length > 0)
				{
					list.pop();
				}
			}
			super.destroy();
		}

		/**
		 * Adds an anim to this list.
		 *
		 * @param anim  The anim object.
		 */
		public function add(anim:Anim):void
		{
			anim.alist = this;
			list.push(anim);
		}

		/**
		 * Removes an anim from this list.
		 *
		 * @param anim  The anim object.
		 */
		public function remove(anim:Anim):void
		{
			var idx:int = list.indexOf(anim);
			if (idx != -1)
			{
				list[idx] = null;
			}
			if ( !keepAlive && isEmpty() )
			{
				destroy();
			}
		}

		/**
		 * Determines if list is empty.
		 */
		public function isEmpty():Boolean
		{
			for (var i:int = 0; i < list.length; i++)
			{
				if ( list[ i ] != null )
				{
					return false;
				}
			}
			return true;
		}

		/**
		 * Counts all anims in the list.
		 */
		public function getAnimAt( idx:int ):Anim
		{
			var count:int = 0;
			for (var i:int = 0; i < list.length; i++)
			{
				if ( list[ i ] != null )
				{
					if ( count++ == idx )
					{
						return list[ i ]
					}
				}
			}
			return null;
		}

		/**
		 * Counts all anims in the list.
		 */
		public function countAnims():int
		{
			//			return list != null ? list.length : 0;
			var count:int = 0;
			for (var i:int = 0; i < list.length; i++)
			{
				if ( list[ i ] != null )
				{
					count++;
				}
			}
			return count;
		}

		/**
		 * Horizontally flips any animators in the list that implement IHflip.
		 */
		public function hflip():void
		{
			if (list != null)
			{
				var len:int = list.length
				for (var i:int = 0; i < len; i++)
				{
					var anim:Anim = list[i];
					if (anim is IHflip)
					{
						(anim as IHflip).hflip();
					}
				}
			}
		}

		/**
		 * Sets or releases the pause control.
		 *
		 * @param on  True to pause the animators in this list.
		 */
		public function pause(on:Boolean=true):void
		{
			paused = on;
		}

		/**
		 * Removes all anims from the list.
		 */
		public function clearAnims( clearLists:Boolean=false ):void
		{
			if (list != null)
			{
				var len:int = list.length
				for (var i:int = len-1; i >= 0; i--)
				{
					var anim:Anim = list[i];
					if ( anim )
					{
						if ( clearLists || !( anim is AnimList ) )
						{
							anim.destroy();
						}
						else
						{
							( anim as AnimList ).clearAnims();
						}
					}
				}
				list.length = 0;
			}
		}

		/**
		 * Updates the animation at a regular interval.
		 *
		 * @return True if the list should be destroyed.
		 */
//		public function animate():Boolean
		override public function animate():Boolean
		{
			if ( paused )
			{
				return false;
			}
			animIdx = 0;
			while ( animIdx < list.length )
			{
				var anim:Anim = list[ animIdx ];
				if ( anim )
				{
					if ( anim is AnimBase )
					{
						var base:AnimBase = list[ animIdx ];
						if ( base.animate() ) // returns true when anim is done
						{
							if ( base.repeat >= 0 )
							{
								base.loop = ( --base.repeat >= 0 );
							}
							if ( base.loop )
							{
								base.doLoop();
								if ( base.block )
								{
									break;
								}
							}
							else
							{
								if ( base.listener != null )
								{
									if ( base.listener(anim) )
									{
										return true;    // kill the alist
									}
								}
								var killDob:Boolean = base.killDob;
//								base.destroy();
								if ( killDob )
								{
									destroyDob();
									base.destroy();
									return true;
								}
								base.destroy();
							}
						}
						else
						{
							if ( base.block )
							{
								break;
							}
						}
					}
					else if ( anim.animate() ) // returns true when anim is done
					{	// not AnimBase
						anim.destroy();
//						destroyDob();
//						if (dob is IDestroyable)
//						{
//							IDestroyable(dob).destroy();
//						}
					}
				}
				animIdx++;
			}
			return kill;
		}

		public function destroyDob():void
		{
			if ( dob is CitrusObject ) {
				( dob as CitrusObject ).destroy();
			}
			else if (dob is IDestroyable)
			{
				IDestroyable(dob).destroy();
			}
			else if (dob && dob.parent)
			{
				dob.parent.removeChild(dob);
			}
			dob = null;
		}

		public static function report():String
		{
			return "AnimList: makes = " + makeCounter + ", instances = " + instanceCounter + ", pops = " + popCounter + ", destroys = " + destroyCounter ;
		}

		public function findAnimList(dob:DisplayObject):AnimList
		{
			for each (var anim:Object in list)
			{
				if ( anim is AnimList )
				{
					if ( anim.dob == dob )
					{
						return anim as AnimList;
					}
					var childList:AnimList = anim.findAnimList( dob );
					if ( childList != null )
					{
						return childList;
					}
				}
			}
			return null;
		}

		public function findAnimByType( animClass:Class ):Anim
		{
			for each ( var anim:Object in list )
			{
				if ( anim is animClass )
				{
					return anim as Anim;
				}
				if ( anim is AnimList )
				{
					var childAnim:Anim = anim.findAnimByType( animClass );
					if ( childAnim != null )
					{
						return childAnim;
					}
				}
			}
			return null;
		}

		public function findAnimByName( name:String ):Anim
		{
			for each ( var anim:Object in list )
			{
				if ( anim.name == name )
				{
					return anim as Anim;
				}
				if ( anim is AnimList )
				{
					var childAnim:Anim = anim.findAnimByName( name );
					if ( childAnim != null )
					{
						return childAnim;
					}
				}
			}
			return null;
		}

//		/**
//		 * Finds an anim of a certain class.
//		 */
//		public function findAnimType(animClass:Class):Anim
//		{
//			if (list != null)
//			{
//				var len:int = list.length
//				for (var i:int = 0; i < len; i++)
//				{
//					var anim:Anim = list[ i ];
//					if ( anim is animClass )
//					{
//						return anim;
//					}
//				}
//			}
//			return null;
//		}

		public function removeRef( ref:RecycleRef  ):void
		{
			var idx:int = refs.indexOf( ref );
			if ( idx != -1 )
			{
				refs.splice( idx, 1 );
			}
		}

		public function addRef( ref:RecycleRef  ):void
		{
			refs.push( ref );
		}

	}
}