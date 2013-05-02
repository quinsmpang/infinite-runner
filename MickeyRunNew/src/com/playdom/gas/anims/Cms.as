/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims
 {
    import com.playdom.cms.CMS;
    import com.playdom.cms.CmsOptions;
    import com.playdom.gas.AnimControl;
    import com.playdom.gas.AnimList;

    /**
     * Loads a SWF.
     *
     * @author Rob Harris
     */
    public class Cms extends AnimBase
    {
        /** The recycling pool */
        private static var _pool:Array = [];

        /** Initializing the CMS System */
        private var _initializing:Boolean;

        /** Distinguishes the project to the CMS. */
        private var _codeName:String;

        private var _environment:String;

        private var _context:Object;

        /**
         * Creates or reuses an instance of this class.
         *
         * @return  An instance of this class.
         */
        public static function make(alist:AnimList, wait:int, codeName:String, environment:String, context:Object):Cms
        {
            // recycle or create an instance
            if (_pool.length > 0)
            {
                var anim:Cms = _pool.pop();
            }
            else
            {
                anim = new Cms();
            }
            // initialize the variables
            anim.wait = wait;
            anim.stime = 0;
            anim._initializing = false;
            anim._codeName = codeName;
            anim._environment = environment;
            anim._context = context;

            // add it to the parent list
            alist.add(anim);
            return anim;
        }

        /**
         * Frees all resources for garbage collection.
         */
        override public function destroy():void
        {
            super.destroy();

            if (_pool.indexOf(this) == -1)
            {
                _pool.push(this);
            }
        }

        /**
         * Updates the animation at a regular interval.
         *
         * @return True if the animation has completed.
         */
        override public function animate():Boolean
        {
            if ( !_initializing )
            {
                var control:AnimControl = alist.control;
                if (stime == 0)
                {
                    stime = control.time;
                }
                if (control.time >= stime+wait)
                {
                    var options:CmsOptions;
                    if ( _context.parameters && _context.parameters.cmsCodeName ) {
                        _codeName = _context.parameters.cmsCodeName;
                        _context.log.info( ".animate: overriding codeName attribute with value from cmsCodeName flash_var.", this );
                    }

                    if ( _context.parameters && _context.parameters.cmsEnvironment ) {
                        _environment = _context.parameters.cmsEnvironment;
                        _context.log.info( ".animate: overriding environment attribute with value from cmsEnvironment flash_var.", this );
                    }

                    _context.log.info( ".animate: initializing CMS interface for codeName '" + _codeName + "' and environment '" + _environment + "'", this );
                    options = new CmsOptions(_codeName, _environment);

                    if ( _context.parameters && _context.parameters.cmsUseAPI && _context.parameters.cmsUseAPI == "true" ) {
                        _context.log.info( ".animate: initializing CMS interface to use the remote service api... that means we're fetching content from the net.", this );
                        options.mode = CmsOptions.MODE_USEAPI;
                    } else {
                        _context.log.info( ".animate: initializing CMS interface to use the local adapter api... that means we're fetching content from the filesystem.", this );
                    }

                    CMS.init( options, _context.log, _handleCmsReady );

                    _initializing = true;
                }
            }
            return false;
        }

        private function _handleCmsReady():void
        {
//            AssetWrapper.instance.loadAssets( _context.urlPrefix );
            destroy();
        }

        /**
         * Parses tokenized data to create an instance of this object.
         *
         * @param tokenizer The script tokenizer.
         * @param helper    The parser helper.
         * @param context   The system context.
         */
        public static function parse( tokenizer:Object, helper:Object, context:Object ):void
        {
            var anim:AnimBase = make( helper.alist,
                tokenizer.getInt( "wait", 0 ),
                tokenizer.getString( "codeName", "nocode" ),
                tokenizer.getString( "environment", "dev" ),
                context
            );
            helper.parseAnimAttributes( anim, tokenizer );
            tokenizer.destroy();
        }

    }
}
