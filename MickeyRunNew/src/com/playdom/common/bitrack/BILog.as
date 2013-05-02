/**
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
package com.playdom.common.bitrack
{
	import com.playdom.framework.util.Log;
	
	/**
	 * Outputs log messages to the Event Logging System.
	 *
	 * Assumes that the Event Logging System is available and initialized.
	 *
	 * @author Jeremy Kassis
	 */
	public class BILog extends Log
	{
		override public function warning( msg:String, caller:Object=null ):void 
		{
			super.warning( msg, caller );
			InGameBITracking.trackError( escape( msg ), caller ? caller.toString() : "", "warning" );
		}
		
		override public function error( msg:String, caller:Object=null ):void  
		{
			super.error( msg, caller );
			InGameBITracking.trackError( escape( msg ), caller ? caller.toString() : "", "error" );
		}
		
	}
}
