///////////////////////////////////////////////////////////
//  BITrack.as
//  Actionscript 3.0 of the Class BITrack
//  Property of Playdom
//  Created on:      9-Sept-2010 11:58:19 AM
//  Original author: Iman Khabazian
// Copyright © 2009-2010 Playdom, Inc. All rights reserved.
///////////////////////////////////////////////////////////

package com.playdom.common.bitrack
{
    import com.playdom.common.interfaces.ILoader;
    import com.playdom.common.interfaces.ILog;
    import com.playdom.common.util.NameValuesContainer;
    
    import flash.system.Capabilities;
    import flash.utils.Dictionary;

    /**
     * Singleton, Abstracts actual call to analytics by providing an interface that conforms with
     * Playdom analytics requirements.
     * Notes:  BiTrack uses a buffer that is flushed on an interval.  You should force a flush if
     * you detect the browser being closed.
     *
     * @author Iman Khabazian
     * @version 1.0
     * @created 25-Feb-2010 11:58:19 AM
     */
    public class BITrack
    {
        use namespace OnlyTracker;

        /**
         *Tag Enums
         */
        private static var tagEnumCnt:uint = 0;

        // add a function to be notified on send.
        public var sendCallback:Function;
        public static const BiTrack_VERSION:String = "0.3";

        OnlyTracker static const ERROR:uint = tagEnumCnt++;

        OnlyTracker static const GAME_ACTION:uint = tagEnumCnt++;

        OnlyTracker static const PAGEVIEW:uint = tagEnumCnt++;

        OnlyTracker static const POPUP:uint = tagEnumCnt++;

        OnlyTracker static const STEP_TIMING:uint = tagEnumCnt++;

        OnlyTracker static const USER_STAT_CHANGE:uint = tagEnumCnt++;

        OnlyTracker static const PERFORMANCE:uint = tagEnumCnt++;

        OnlyTracker static const SYSTEM:uint = tagEnumCnt++;

        OnlyTracker static const MONEY:uint = tagEnumCnt++;

        /**
         * Attribute Names Constants
         */
        OnlyTracker static const USER_ID_ATTRIBUTE:String = "user_id";

        OnlyTracker static const NETWORK_ATTRIBUTE:String = "network";

        OnlyTracker static const VIEW_NETWORK_ATTRIBUTE:String = "view_network";

        OnlyTracker static const CONTEXT_ATTRIBUTE:String = "context";

        OnlyTracker static const LOCATION_ATTRIBUTE:String = "location";

        /**
         * Dictionary of start times.
         */
        OnlyTracker var startTimes:Dictionary = new Dictionary();

        /**
         * Array of Tag strings simulating enum.
         */
        private static const tagStrings:Array  /* of String */ =
            [
                "error",
                "game_action",
                "pageview",
                "popup",
                "step_timing",
                "user_stat_change",
                "performance",
                "system",
                "money"
            ];

        private var _totalLoadedTime:Number = 0;

        private var _totalLoadedBytes:uint = 0;

        private static const TAG_ATTRIBUTE:String = "tag";

        private static const APP_ATTRIBUTE:String = "app";

        private static const LANG_ATTRIBUTE:String = "lang";

        /**
         *system
         */
        private static const SYSTEM_MANUFACTURER_ATTRIBUTE:String = "manufacturer"

        private static const SYSTEM_OS_ATTRIBUTE:String = "os"

        private static const SYSTEM_PLAYER_TYPE_ATTRIBUTE:String = "player_type"

        private static const SYSTEM_FP_VERSION_ATTRIBUTE:String = "fp_version"

        private static const SYSTEM_APP_VERSION_ATTRIBUTE:String = "app_version"

        /**
         *Errors Messages.
         */
        private static const MUST_INITIALIZE_ERROR:String =
            "You must initialize with the initialize function before using Tracker"

        private static const TRACKER_SINGELTON_ERROR:String = "Tracker is a singleton, use Tracker.getInstance"

        private static const ALREADY_RUNNING_ERROR:String =
            "Can not start performance monitor while it is already running.";

        /**
         * contains info that will be used with every call, ie userID, networkID, appID
         */
        private static const LANG_EN_US:String = "en_US";

        private var biBuffer:BIBuffer;

        private var appVersion:String = "";

		private var _initialized:Boolean = false;
		
		public var log:ILog;

        /**
         *  singelton pattern.
         */
		public static var instance:BITrack;

        /**
         *  Constructor.  Dont use this ,use getInstance per singelton.
         */
        public function BITrack( log:ILog, loader:ILoader ): void
        {
			this.log = log;
            if (instance)
            {
				if ( log )
				{
					log.error(TRACKER_SINGELTON_ERROR);
				}
				else
				{
					trace(TRACKER_SINGELTON_ERROR);
				}
            }
            else
            {
				instance = this;
                // start up buffer.
                biBuffer = new BIBuffer( true, loader );
                // startup performance
                trackSystem();
            }
        }

        public function get initialized():Boolean
        {
            return _initialized;
        }

        /**
         * Buffer is set to flush on an interval, this function will flush it instantly.  Good to use if you detect browser close.
         *
         */
        public function flush():void
        {
            biBuffer.flush();
        }

        public function get flushInterval():Number
        {
            return biBuffer.flushInterval;
        }



        static public function get biBaseURL():String
        {
            return BIBuffer.URL_STRING;
        }

        /**
         * Initializes tracker and sends intial loading step_timing message to server.
         *
         * @param userID    The unique ID of the user, ie 	1000049183098
         * @param appString    The Scribe tag of the app sending this event. see https:
         * //confluence.playdom.com/display/analysis/Scribe+tag
         * @param networkID:String = ""    optional, "m" for myspace, "f" for facebook.
         * @param appVersion:String The version of your app.
         * @param flushInterval:uint = Intreval for flush time.
         * @param viewNetworkID: A single-character identifier of the platform on which the user actually uses the app.
         * By default, set to the same value as networkID.
         * @param language: For localization, what language is the app running in.
         */
        public function initialize(userID:String, appString:String,networkID:String = "", appVersion:String = "",
                                   flushInterval:uint = 30000, viewNetworkID:String = "", language:String = LANG_EN_US): void
        {
            if (! _initialized)
            {

                if ((userID== null) || (userID == ""))
                {
                    log.error("invalidate userID");
                }
                if ((appString== null) || (appString==""))
                {
                    log.error("invalidate appString");
                }
                this.appVersion = appVersion;
                if (viewNetworkID == "")
                {
                    viewNetworkID = networkID;
                }
                var gameDataNVC:NameValuesContainer = new NameValuesContainer();
                gameDataNVC.addPair(APP_ATTRIBUTE,appString);
                gameDataNVC.addPair(USER_ID_ATTRIBUTE,userID);
                gameDataNVC.addPair(NETWORK_ATTRIBUTE,networkID);
                gameDataNVC.addPair(VIEW_NETWORK_ATTRIBUTE,viewNetworkID);
                gameDataNVC.addPair(LANG_ATTRIBUTE,language);
                biBuffer.headerNVC = gameDataNVC;
                biBuffer.start(flushInterval);
                _initialized = true;
                log.info("BiTrack.initialize: ver " + BiTrack_VERSION + " on App: " + appString + " ver: " + appVersion + " for user: " + userID + " flushInterval: " + flushInterval + " viewNetwork: " + viewNetworkID  + " lang:"  + language);
            }
            else
            {
                log.warning("BITrack already initialized, new parameters do not take effect");
            }

        }

        public function get headerNVC():String
        {
            if (biBuffer !== null)
            {
                if (biBuffer.headerNVC !== null)
                {
                    return biBuffer.headerNVC.toURL();
                }
            }
            return "no header";
        }

        OnlyTracker function get totalLoadedTime():Number
        {
            return Math.round(_totalLoadedTime * 100) / 100;
        }

        OnlyTracker function get totalLoadedBytes():Number
        {
            return Math.round(_totalLoadedBytes * 100) / 100;
        }

        /**
         * Kilobytes per second.
         * @return
         *
         */
        OnlyTracker function calcNetworkSpeed(): Number
        {
            // Calc is bytes per milisecond, which is equal to kilobytes per second.
            // actually I had to multiply by 1000/1024 since 1025 bytes in a kilobye, thus the .9765625.
            return ((_totalLoadedBytes/_totalLoadedTime )*0.9765625);
        }

        /**
         * helper function for trackLoadStop for maintaining the network speed.
         * @param bytes
         * @param ms
         *
         */
        OnlyTracker function updateNetworkSpeed(bytes:uint, ms:Number): void
        {
            if (bytes > 0)
            {
                _totalLoadedTime += ms;
                _totalLoadedBytes += bytes;
            }
        }

        /**
         *
         * @param tag    one of the predifed tags that Tracker supports.
         * @param data    generic data object of which all string attributes will be
         * logged.
         */
        OnlyTracker function trackIt(tag:uint, playloadNVC:NameValuesContainer= null, flush:Boolean=false): void
        {
            if (tag > tagEnumCnt)
            {
                log.error("BITrack.trackIt sent bad tag");
            }
            var myNVC: NameValuesContainer = new NameValuesContainer();
            myNVC.addPair(TAG_ATTRIBUTE, tagStrings[tag]);
            myNVC.addNVC(playloadNVC);
            biBuffer.pushNVC(myNVC, flush);
        }

        /**
         * Sends System Capabilities to Analytics.
         * */
        private function trackSystem(): void
        {
            var nvc: NameValuesContainer = new NameValuesContainer();
            nvc.addPair(SYSTEM_APP_VERSION_ATTRIBUTE, appVersion);
            nvc.addPair(SYSTEM_MANUFACTURER_ATTRIBUTE, Capabilities.manufacturer);
            nvc.addPair(SYSTEM_OS_ATTRIBUTE, Capabilities.os);
            nvc.addPair(SYSTEM_PLAYER_TYPE_ATTRIBUTE, Capabilities.playerType);
            nvc.addPair(SYSTEM_FP_VERSION_ATTRIBUTE, Capabilities.version);
            trackIt(SYSTEM, nvc);
        } // end trackSystem
    }//end BITrack
} // end package
