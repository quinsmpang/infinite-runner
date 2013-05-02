/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.common.util {
	
	/**
	 * 	Numeric utility methods; this is a static class.
	 */
	public class NumberUtils{		
		/** Multiplier for degrees to radian calculation */
		public static const DEG_TO_RAD:Number = Math.PI/180;
		
		/** Multiplier for radian to degrees calculation */
		public static const RAD_TO_DEG:Number = 180/Math.PI;
		
			
		public static function getAngle(x1:Number, y1:Number, x2:Number, y2:Number):Number {
			var radians:Number = Math.atan2(y1-y2, x1-x2);
			return rad2deg(radians);
		}
	
		public static function deg2rad(deg:Number):Number{
			return deg*(Math.PI/180);
		}						

		public static function rad2deg(rad:Number):Number{
			return rad*(180/Math.PI);
		}

		public static function calcX(spd:Number,dir:Number):Number {
			return Math.cos(dir*DEG_TO_RAD)*spd;
		}
		
		public static function calcY(spd:Number,dir:Number):Number {
			return Math.sin(dir*DEG_TO_RAD)*spd;
		}

		public static function calcDist(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
			var dx:Number = x2-x1;
			var dy:Number = y2-y1;
			return Math.sqrt(dx*dx+dy*dy);
		}
		
		public static function parseInteger(str:String):int {
            var num:Number = parseInt(str);
            if(!isNaN(num) && num <= int.MAX_VALUE && num >= int.MIN_VALUE) {
                return int(num);
            }
//			Log.info(".parseInteger: Unable to parse integer: " + str, "NumberUtils"); 
            
            return -1;
        }		
        
		/**
		 * Converts 1000000 to 1,000,000
		 */ 
        public static function toCommaSeparatedString(n:int):String {
        	var s:String = n.toString();
        	var len:int = s.length;
        	var targetString:String = "";
        	
        	while (len > 0) {
        		len--;
				if ((len < s.length -1) && ((s.length - 1 - len)%3==0)) {
					targetString = "," + targetString;
				}
        		targetString = s.substr(len,1) + targetString; // add a digit
        	}
        	return targetString;
		}
		
		/**
		 * Randomly picks from a comma-separated set
		 *  
		 * @param val  The set string.
		 * 
		 * @return One item from the set.
		 */
		public static function randomSet(val:String):String 
		{
			var len:int = val.length;
			var arr:Array = val.substring(1, len-1).split(",");
			var rnd:int = Math.random()*arr.length;
			return arr[rnd];
		}
		
		/**
		 * Randomly picks from a range of numbers
		 *  
		 */
		public static function randomValue(min:Number, max:Number):Number 
		{
			return Math.random()*(max-min+1)+min;
		}
		
		/**
		 * Fetches an integer from an array.
		 *  
		 * @param arr  The array.
		 * @param idx  The index of the element to fetch.
		 * @param def  The default value to return if one cannot be found.
		 * 
		 * @return An integer value. 
		 */
		public static function fetchInt( arr:Array, idx:int, def:int=0 ):int
		{
			try
			{
				return parseInt( arr[ idx ] );
			}
			catch ( err:Error )
			{
			}
			return def;
		}
		
	}	
}