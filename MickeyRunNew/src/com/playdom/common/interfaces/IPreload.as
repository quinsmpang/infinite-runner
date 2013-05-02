/*
* Playdom, Inc. (c)2013 All Rights Reserved
*/
package com.playdom.common.interfaces 
{
	/**
	 * Contains a method used for preloading assets.
	 * 
	 * @author Rob Harris
	 */
	public interface IPreload
	{
		/**
		 * Increments or decrements the preload counter.
		 * 
		 * @param inc  The amount to add or subtract from the counter
		 */
		function incPreloadCount(inc:int):void; 
	}
}