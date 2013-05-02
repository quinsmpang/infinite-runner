/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.common.util 
 {
	 /**
	  * Trims the white space from the start and end of the line.
	  *  
	  * @param txt The text to be trimmed.
	  * 
	  * @return  The trimmed text. 
	  */
	 public function trimString( txt:String ):String 
	 {
		 if (txt != null) 
		 {
			 return txt.replace(/^\s+|\s+$/g, '');
		 }
		 return ''; 
	 }
	
}