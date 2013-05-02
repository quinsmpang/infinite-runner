/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims 
 {
	import com.playdom.common.interfaces.IDestroyable;
	import com.playdom.gas.AnimList;
	
	/**
	 * Superclass for all animators.
	 * 
	 * @author Rob Harris
	 */
	public class Anim implements IDestroyable
	{
   		/** The parent animation list */
		public var alist:AnimList;
		
		/** The anim's name. */
		public var name:String;
				
		/**
		 * Frees all resources for garbage collection.
		 */
		public function destroy():void 
		{
			if ( alist )
			{
				alist.remove( this );
				alist = null;
			}
		}	
							
		/**
		 * Updates the animation at a regular interval.
		 * 
		 * @return True if the anim is done. 
		 */
		public function animate():Boolean 
		{
			return false;
		}		
		
	}
}