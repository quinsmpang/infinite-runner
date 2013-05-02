package com.playdom.common.bitrack
{
	/**
	 * Enumaration for 3 popup step types (show, continue, cancel). 
	 * @author Ikhabazian
	 * 
	 */
	public class PopupStepEnum
	{
		private var _name:String;
		/**
		 * show: Log step = show if the popup pops up. 
		 */
		public static const POPUP_STEP_SHOW:PopupStepEnum = new PopupStepEnum("show");
		
		/**
		 * continue : Log step=continue if the user presses a button that continues
		 * on to a subsequent pop-up or screen (for example, a Facebook wall post pop-up)
		 */
		public static const POPUP_STEP_CONTINUE:PopupStepEnum = new PopupStepEnum("continue");
		
		/**
		 * cancel: Log this if the user presses a button that cancels the action that
		 * the pop-up prompts the user to take..
		 */
		public static const POPUP_STEP_CANCEL:PopupStepEnum = new PopupStepEnum("cancel");
			
		/**
		 * Constructor 
		 * @param enum
		 * 
		 */
		public function PopupStepEnum(name:String)
		{
			_name = name
		}
		
		/**
		 * Converts type to string 
		 * @return 
		 * 
		 */
		public function toString():String
		{
			return _name;
		} // end toString
	} // end PopupStepEnum
}//end package