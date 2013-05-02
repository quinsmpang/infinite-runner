/**
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
package com.playdom.common.interfaces 
{
	import flash.net.URLRequest;

	/**
	 * Loads a resource.
	 * 
	 * @author Rob Harris
	 */
	public interface ILoader
	{
		/**
		 * Loads a resource.
		 * 
		 * @param url     The resource url.
		 * @param timeout The timeout period.
		 */
		function loadResource( url:String, timeout:int ):void;
	}
}