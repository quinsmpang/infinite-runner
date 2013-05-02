/*
* Playdom, Inc. (c)2013 All Rights Reserved
*/
package com.playdom.common.interfaces 
{
	/**
	 * Contains a destroy method used for free resources for garbage collection.
	 * 
	 * @author Rob Harris
	 */
	public interface IDestroyable
	{
		/**
		 * Frees all resources for garbage collection.
		 */
		function destroy():void;
	}
}