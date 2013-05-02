package com.playdom.common.bitrack
{
	import com.playdom.common.util.NameValuesContainer;
	
	import flash.utils.getTimer;

	/**
	 * exposes load tracking api. 
	 * @author Ikhabazian
	 * 
	 */
	public class LoadBITracking
	{
		use namespace OnlyTracker;
		
		/**
		 * Errors 
		 */
		private static const KEY_DOESNT_EXIST_ERROR:String = "Key does not exists";
		
		private static const ALREADY_TIMING_ERROR:String = "Timing as already started for "
		
		/**
		 * Attributes 
		 */
		private static const ELAPSED_TIME_ATTRIBUTE:String = "elapsed_time";
		
		private static const PATH_NAME_ATTRIBUTE:String = "path_name";
		
		private static const RESULT_ATTRIBUTE:String = "result";
		
		/**
		 *Timing Block Names
		 */
		private static const PRELOADING_BLOCK:String = "page_load";
		
		private static const DATA_LOADING_BLOCK:String = "dataLoading";
		
		private static const ASSET_LOADING_BLOCK:String = "assetLoading";
		
		/**
		 * All sequences should start with the "start" step and end with the "end" step.
		 * */
		private static const START_STEP:String = "start";
		
		private static const END_STEP:String = "end";
		
		/**
		 *  Use this on any data load initiation during preloading.
		 * @param stepLabel: String = ""  If you only have 1 data loading step, dont worry about this, if you have 
		 * multiple, use this as a unique ID.
		 **/
		public static function trackDataLoadingStart(stepLabel:String = ""): void
		{
			var context: String = DATA_LOADING_BLOCK;
			startTiming(context + stepLabel);
			trackStepTiming(PRELOADING_BLOCK,context +"_" + stepLabel + "_" + START_STEP);
		}
		
		/**
		 *  Use this on any data load complete during preloading.
		 * @param bytesLoaded: uint =0  if you know how many bytes where loaded in the step that has just completed, 
		 * send it up to help track network speed.
		 * @param stepLabel: String = ""  If you only have 1 data loading step, dont worry about this, if you have 
		 * multiple, use this as a unique ID.
		 **/
		public static function trackDataLoadingEnd(bytesLoaded:uint = 0, stepLabel:String = ""): void
		{
			var context: String =DATA_LOADING_BLOCK;
			var elapsedTime: Number  = getElapsedTime(context + stepLabel);
			BITrack.instance.updateNetworkSpeed(bytesLoaded,elapsedTime);
			trackStepTiming(PRELOADING_BLOCK, context + "_" + stepLabel + "_" + END_STEP,elapsedTime);
		}
		
		/**
		 *  Use this for any asset load intiation during preloading.
		 * @param stepLabel: String = ""  If you only have 1 asset loading step, dont worry about this, if you have
		 *  multiple, use this as a unique ID.
		 **/
		public static function trackAssetLoadingStart(stepLabel:String = ""): void
		{
			var context: String = ASSET_LOADING_BLOCK;
			startTiming(context + stepLabel);
			trackStepTiming(PRELOADING_BLOCK,context + "_" + stepLabel + "_" + START_STEP);
		}
		
		/**
		 *  Use this for any asset load complete during preloading.
		 * @param bytesLoaded: uint =0  if you know how many bytes where loaded in the step that has just completed, 
		 * send it up to help track network speed.
		 * @param stepLabel: String = ""  If you only have 1 asset loading step, dont worry about this, if you have
		 *  multiple, use this as a unique ID.
		 **/
		public static function trackAssetLoadingEnd(bytesLoaded:uint = 0, stepLabel:String = ""): void
		{
			var context: String = ASSET_LOADING_BLOCK;
			var elapsedTime: Number = getElapsedTime(context + stepLabel);
			BITrack.instance.updateNetworkSpeed(bytesLoaded,elapsedTime);
			trackStepTiming(PRELOADING_BLOCK, context +"_" + stepLabel + "_" + END_STEP, elapsedTime);
		}
		
		/**
		 * Fires a step timing event for a given location.
		 * @location:String
		 */
		public static function trackPageLoadStep(location:String, elapsed:Number = 0):void
		{
			trackStepTiming(PRELOADING_BLOCK, location, elapsed);
		}
		
		/**
		 * starts timing for a key.
		 * @param key:String, something unique to indentify the block, will be logged.
		 */
		public static function startTiming(key:String): void
		{
			var ms: Number = getTimer();
			if (BITrack.instance.startTimes[key])
			{
				BITrack.instance.log.error(ALREADY_TIMING_ERROR + key);
			}
			BITrack.instance.startTimes[key] = ms;
		}
		
		/**
		 * returns elapsed time since start timing
		 * @param key
		 * @return 
		 * 
		 */
		public static function getElapsedTime(key:String): Number
		{
			var now_ms: Number = getTimer();
			var elapsedTime: Number 
			if (BITrack.instance.startTimes[key])
			{
				elapsedTime = (now_ms - BITrack.instance.startTimes[key]) / 1000;
				delete BITrack.instance.startTimes[key];	
			}
			else 
			{
				BITrack.instance.log.error(KEY_DOESNT_EXIST_ERROR);
			}
			return (elapsedTime);
		}
		
		/**
		 * When an event is sent, the server clock will be used, but this call is not hooked into the tickers.
		 * Analysis generates reports to show how many users reach each
		 * step in the sequence, and how much time has elapsed between the first event
		 * with location=start and the step being logged.
		 * 
		 * @param context Identifies the sequence of events in which this timestamp is included.
		 * @param location The name of the step in the sequence of events.	Always log one step_timing event with 
		 * location=start to indicate the beginning of the sequence (and "end" for the end)!
		 * @param pathName:String="" An additional description for a sequence that you can attach to the location=start 
		 * event.  You may also set the path_name parameter at the location=start  event. This attaches that path_name 
		 * to the rest of the steps in a sequence, until the next location=start event.
		 * For example, you can have a context=page_load, and then have several different page load flows that share
		 * code (e.g. FQL calls). The gift accept page would have a start event with path_name=accept_gift and the default
		 * page flow would start with path_name=default.
		 * @param result:String="" Logs the result of the step (ie "pass" or "uber_fail");
		 */
		private static function trackStepTiming(context:String, location:String, elapsed:Number = 0, pathName:String = "",result:String = ""): void
		{
			var nvc:NameValuesContainer = new NameValuesContainer(BITrack.CONTEXT_ATTRIBUTE, context, BITrack.LOCATION_ATTRIBUTE, location);
			nvc.addPair(PATH_NAME_ATTRIBUTE, pathName);
			nvc.addPair(RESULT_ATTRIBUTE, result);
			if (elapsed > 0)
			{
				nvc.addPair(ELAPSED_TIME_ATTRIBUTE , String(elapsed));
			}
			BITrack.instance.trackIt(BITrack.STEP_TIMING, nvc, true);
		}//trackStepTiming
	}//LoadBITracking
}//package