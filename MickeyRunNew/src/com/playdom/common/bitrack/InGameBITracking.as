package com.playdom.common.bitrack
{
    import com.playdom.common.util.NameValuesContainer;

    /**
     * Exposes Ingame tracking api.
     * @author Ikhabazian
     *
     */
    public class InGameBITracking
    {
        use namespace OnlyTracker;

        private static const ENGAGED:String = "engaged";

        private static const ACTION_ATTRIBUTE:String = "action";

        private static const AMOUNT_ATTRIBUTE:String = "amount";

        private static const ITEM_NAME_ATTRIBUTE:String = "item_name";

        private static const MESSAGE_ATTRIBUTE:String = "message";

        private static const EXPERIENCE_ATTRIBUTE:String = "exp";

        private static const LEVEL_ATTRIBUTE:String = "level";

        private static const REASON_ATTRIBUTE:String = "reason";

        private static const TRACKING_CODE_ATTRIBUTE:String = "tracking_code";

        private static const STEP_ATTRIBUTE:String = "step";

        private static const STAT_NAME_ATTRIBUTE:String = "stat_name";

        // local reference to singelton.
//        private static var biTrack:BITrack = BITrack.instance;

        public static function trackPayment(subtype:String, currency:String, amount:int, newBalance:int=int.MIN_VALUE): void
        {
            trackMoney("payment", subtype, currency, amount, newBalance);
        }

        public static function trackPurchase(subtype:String, currency:String, amount:int, newBalance:int=int.MIN_VALUE): void
        {
            trackMoney("purchase", subtype, currency, -amount, newBalance);
        }

        public static function trackUpgrade(subtype:String, currency:String, amount:int, newBalance:int=int.MIN_VALUE): void
        {
            trackMoney("upgrade", subtype, currency, -amount, newBalance);
        }

        public static function trackReward(subtype:String, currency:String, amount:int, newBalance:int=int.MIN_VALUE): void
        {
            trackMoney("reward", subtype, currency, amount, newBalance);
        }

        private static function trackMoney(type:String, subtype:String, currency:String, amount:int, newBalance:int=int.MIN_VALUE): void
        {
            var nvc:NameValuesContainer = new NameValuesContainer(
                "type", type,
                "subtype", subtype,
                "currency", currency,
                "amount", amount.toString());

            if (newBalance > int.MIN_VALUE)
            {
                nvc.addByPairs("new_balance", newBalance);
            }

			BITrack.instance.trackIt(BITrack.MONEY, nvc, true);
        }

        /**
         * Logs error strings.
         * @param reason A description of the error that occurred. This is a low-cardinality parameter. It should not
         * contain more than ten to twenty distinct values
         * @param context    In what context is the error being logged, ie location
         * @param reason    The actual error string.
         * @param message: String="" 	 A lengthier explanation, or more information about the error, possibly a
         * response from the program.  This is a high-cardinality parameter. It can contain many distinct values.
         */
        public static function trackError(reason:String, context:String, message:String =""): void
        {
            var nvc: NameValuesContainer = new NameValuesContainer(REASON_ATTRIBUTE, reason, BITrack.CONTEXT_ATTRIBUTE,
                context, MESSAGE_ATTRIBUTE, message);
			BITrack.instance.trackIt(BITrack.ERROR,nvc);
        }

        /**
         * track any events that are specific to one game.
         * @param context   In what context is this action being made (ie location)
         * @param action    The name of the action that is being logged.
         * @param playerObj Object stats in it.
         * @param itemName    The name of the item that the action is being done on.
         */
        public static function trackGameAction(context:String, action:String, statsObj:*, engaged:Boolean = false): void
        {
            var nvc: NameValuesContainer = new NameValuesContainer(BITrack.CONTEXT_ATTRIBUTE, context,ACTION_ATTRIBUTE,
                action);
            nvc.addObject(statsObj,BITrack.instance.log);
            nvc.addPair(ENGAGED,engaged ? "1" : "0");
			BITrack.instance.trackIt(BITrack.GAME_ACTION, nvc);
        }

        /**
         * Track front-end UI events whenever  you might want the information in an access-
         * log without loading a new page.
         *
         * @param context  A path separated by the / character. We recommend two levels in the path, of the form
         * /NAME_OF_SCREEN/NAME_OF_ACTION
         */
        public static function trackPageview(context:String, engaged:Boolean = false): void
        {
            var nvc: NameValuesContainer = new NameValuesContainer(BITrack.LOCATION_ATTRIBUTE, context);
            nvc.addPair(ENGAGED, engaged ? "1" : "0");
			BITrack.instance.trackIt(BITrack.PAGEVIEW, nvc);
        }

        /**
         * Track information about a pop-up that an application displays to users.  Log
         * two popup events for each pop-up message: one with app set to the Scribe tag of
         * the application displaying the pop-up (without setting log_app) and another
         * with app=click_track and log_app set to the application's Scribe tag.
         * @param stepEnum    The action associated with this pop-up. Use Either BITrack.POPUP_STEP_SHOW,
         * BITrack.POPUP_STEP_CONTINUE, or BITrack.POPUP_STEP_CANCEL
         * values for step are appropriate, feel free to use other values and document
         * them here. Possible values include: POPUP_STEP_SHOW ("show"), POPUP_STEP_CONTINUE("continue"),
         * POPUP_STEP_CANCEL("cancel")
         * @param tracking_code    A tracking code to let us determine the purpose of the
         * pop-up, identify the specific pop-up being shown (for A/B testing), and
         * correlate this with subsequent actions like send_message  and clicked_link.
         * (ie invite-Invite-fancyPicture)
         */
        public static function trackPopup(stepEnum:PopupStepEnum, tracking_code:String, engaged:Boolean = false): void
        {
            var stepString:String= stepEnum.toString();
            var nvc: NameValuesContainer = new NameValuesContainer(TRACKING_CODE_ATTRIBUTE, tracking_code,
                STEP_ATTRIBUTE, stepString);
            nvc.addPair(ENGAGED,engaged ? "1" : "0");
			BITrack.instance.trackIt(BITrack.POPUP, nvc);
        }

        /**
         * Track a change to any user statistic, like exp or balance. If the change
         * results from a game_action, list it in the action  parameter.  Results of
         * actions that should be already tracked.
         * @param statName    The name of the stat that changed.
         * @param amount    The amount of change (+ for increase, - for decrease).
         * @param context:String = "" Match the context on the corresponding game_action
         * @param action:String = ""    If linked to a game action, the name of the action that
         * changed this stat.
         */
        public static function trackStatChange(statName:String, amount:Number, context:String="", action:String="",
                                               engaged:Boolean = false): void
        {
            var nvc: NameValuesContainer = new NameValuesContainer(STAT_NAME_ATTRIBUTE, statName, AMOUNT_ATTRIBUTE,
                amount, ACTION_ATTRIBUTE, action, BITrack.CONTEXT_ATTRIBUTE, context);
            nvc.addPair(ENGAGED,engaged ? "1" : "0");
			BITrack.instance.trackIt(BITrack.USER_STAT_CHANGE,nvc);
        }
    }//InGameBITracking
}//Packaging
