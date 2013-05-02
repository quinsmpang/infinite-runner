// Copyright © 2009-2010 Playdom, Inc. All rights reserved.
package com.playdom.common.bitrack
{
	/**
	 * Handles performance tracking.
	 */
	import com.playdom.common.util.Clock;
	import com.playdom.common.util.Quiesce;
	import com.playdom.common.util.NameValuesContainer;
	
	import flash.system.System;
	import flash.utils.getTimer;
	
	public class PerformanceBITracking
	{
		 use namespace OnlyTracker;
		
		 /**
		  * Whether performance monitoring is running or not. 
		  */
		 OnlyTracker var running:Boolean = false;
		 
		 private static const MINUTES_TO_MILISECONDS_MULTIPLIER:uint = 60000;
		 
		 private var trackInterval:Array/* of uint */ = [];
		 
		 private var lastTime:Number;
		 
		 private var frameCount:uint = 0;
		 
		 private var repeatCount:uint = 0;
		 
		 private var totalRepeats:uint = 0;
		 
		 private var quiesce:Quiesce;
		 
		 /**
		  * Time Game started.
		  * */
		 private var _gameStartTime:Number;
	
		 /**
		  * Attributes 
		  */
		 private static const FPS_ATTRIBUTE:String = "fps";
		 
		 private static const MEMORY_ATTRIBUTE:String = "memory_used";
		 
		 private static const NETWORK_SPEED_ATTRIBUTE:String = "network_speed";
		 
		 private static const LOADED_BYTES_ATTRIBUTE:String = "loaded_bytes";
		 
		 private static const LOADING_TIME_ATTRIBUTE:String = "loading_time";
		 
		 private static const TIME_SINCE_START:String = "time_since_start";
		 
		/**
		 * Constructor 
		 * 
		 */
		public function PerformanceBITracking()
		{
			_gameStartTime = getTimer();
		}
		
		/**
		 * Starts Performance Monitoring.
		 * @param array This is the amount of minutes between each performance call. ie[1,2,4] means first after 1 
		 * minute, then after 2 minutes, then after 4 minutes.
		 * */
		public function start(trackInterval:Array /* of uint */ ): void
    	{
			if ((trackInterval) && (trackInterval.length > 0))
			{
				repeatCount = 0;
				running = true;
				frameCount = 0;
				lastTime = getTimer();
				this.trackInterval = trackInterval;	
				totalRepeats = trackInterval.length;
				startNewInterval();
				Clock.addEnterFrameCallBack(countFrame);	
			}
			else
			{
				BITrack.instance.log.warning("PerformanceBITracking attempted to start with null or empty array");
			}
    	}
    	
		/**
		 * Stops Performance Monitoring 
		 * 
		 */
    	public function stop(): void
    	{
    		running = false;
			quiesce.destroy();
			this.trackInterval= null;
    		Clock.removeEnterFrameCallBack(countFrame);
    	}
    	
    	private function countFrame():void
    	{
    		frameCount++;	
    	}
		
		private function startNewInterval():void
		{
			if (quiesce)
			{
				quiesce.destroy();
			}
			var nextInterval:Number = trackInterval[repeatCount++];
			if (nextInterval < 0)
			{
				BITrack.instance.log.warning("Invalid interval, must be above 0");				
			}
			else
			{
				var newInterval:int = nextInterval*MINUTES_TO_MILISECONDS_MULTIPLIER;
				quiesce = new Quiesce(calcAndTrack, newInterval, BITrack.instance.log);
				quiesce.reset();
			}
		}
		
    	private function calcAndTrack(): void
	    {
	    	var now_ms:int = getTimer();
	    	var secondsPast:Number = (now_ms - lastTime) / 1000;
	    	var fps:Number = frameCount / secondsPast;
	    	var mem:Number =  System.totalMemory / 1048576;
	    	trackPerformance(fps, mem);
	    	lastTime = now_ms;
	    	frameCount = 0;
			//clean up.
			if (repeatCount == totalRepeats)
			{
				stop();
			}
			else
			{
				startNewInterval();
			}
	    }
		
		/**
		 * Logs Performance
		 * 
		 * @param fps    Frames per second since last track (or since start).
		 * @param memoryUsed  how much memory used, in MegaBytes.
		 */ 
		private  function trackPerformance(fps:Number, memoryUsed:Number): void
		{
			var biTrack:BITrack = BITrack.instance;
			
			var nvc: NameValuesContainer = NameValuesContainer.getScratch(FPS_ATTRIBUTE,fps.toFixed(2), 
				MEMORY_ATTRIBUTE, memoryUsed.toFixed(3));
			if (biTrack.totalLoadedTime > 0)
			{
				nvc.addPair(NETWORK_SPEED_ATTRIBUTE,String(biTrack.calcNetworkSpeed().toFixed(2)));
			}
			var ms: int = getTimer();
			nvc.addPair(TIME_SINCE_START, String(ms- _gameStartTime));
			if (biTrack.totalLoadedBytes)
			{
				nvc.addPair(LOADED_BYTES_ATTRIBUTE, String(biTrack.totalLoadedBytes));
			}
			if (biTrack.totalLoadedTime)
			{
				nvc.addPair(LOADING_TIME_ATTRIBUTE, String(biTrack.totalLoadedTime));
			}
			biTrack.trackIt(BITrack.PERFORMANCE, nvc, true);
			nvc = null;
		} // end trackPerformance
	} // end PerformanceBITracking
} // end package