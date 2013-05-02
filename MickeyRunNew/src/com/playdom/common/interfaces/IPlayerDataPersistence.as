/*
* Playdom, Inc. (c)2013 All Rights Reserved
*/
package com.playdom.common.interfaces
{
    public interface IPlayerDataPersistence
    {
        /**
         * Clears all objects in persistant storage.
         */
        function clearAll():void;

        /**
         * Returns all player data.
         *
         * @return An associative array of values based on keys.
         */
        function getAllPlayerData():Array;

        /**
         * Sets a player string key-value pair.
         *
         * @param key   The key.
         * @param value The associated value.
         */
        function setPlayerString( key:String, value:String ):void;

        /**
         * Fetches a player string value based on a key.
         *
         * @param key   The key.
         *
         * @return      The associated value.
         */
        function getPlayerString( key:String ):String;

        /**
         * Sets a player scalar key-value pair.
         *
         * @param key   The key.
         * @param value The associated value.
         */
        function setPlayerScalar( key:String, value:Number ):void;

        /**
         * Fetches a player scalar value based on a key.
         *
         * @param key   The key.
         *
         * @return      The associated value.
         */
        function getPlayerScalar( key:String ):Number;


        /**
         * Forces implementations that queue commands to run them now.
         *
         * @param key   The key.
         *
         * @return      void
         */
        function executeQueuedCommandsNow():void;
    }
}
