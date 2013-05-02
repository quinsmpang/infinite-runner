/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.common.util 
 {
    import flash.utils.Dictionary;

	/**
	 * Weighted table for weighted randomness.
	 * 
	 * @author Rob Harris
	 */
	public class WeightedTable extends Object	
	{
		/** the list of item IDs */
		public var idList:Array = new Array();
		
		/** item list */
		private var items:Dictionary = new Dictionary();
		
		/** the total number of items */
		private var total:Number = 0;
		
        /**
         * Creates or reuses an instance of this class.
         *   
         * @return  An instance of this class. 
         */
        public function WeightedTable() 
        {
        }   
		
		/**
		 * Adds an item to the weighted list.
		 *  
		 * @param itemId  The item ID.
		 * @param weight  The weight for the item.
		 */
		public function addItem( itemId:String, weight:Number ):void
		{
			items[ itemId ] = weight;
			total += weight;
			idList.push( itemId );
		}
		
		/**
		 * Fetched a random item from the weighted list.
		 *  
		 * @return  A weighted random item ID. 
		 */
		public function getRandomItem():String
		{
			var rnd:Number = Math.random()*total;
			var threshold:Number = 0;
			for (var id:String in items)
			{
				var weight:Number = items[ id ];
				threshold += weight;
				if (rnd < threshold )
				{
					return id;
				}
			}
			return id;
		}
		
	}
}