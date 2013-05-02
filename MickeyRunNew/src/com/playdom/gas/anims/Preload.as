/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.anims
 {
    import com.playdom.cms.CMS;
    import com.playdom.game.brewhaha.BrewConst;
    import com.playdom.gas.AnimControl;
    import com.playdom.gas.AnimList;
    import com.playdom.simple.AssetLoader;
    import com.playdom.steamboat.data.metadata.MetaData;
    import com.playdom.steamboat.data.metadata.RowData;
    import com.playdom.steamboat.data.metadata.SheetData;

    /**
     * Loads assets.
     *
     * @author Rob Harris
     */
    public class Preload extends AnimBase
    {
        /** The recycling pool */
        private static var _pool:Array = [];
		
		private static var _idCounter:int = 0;
		
		private var _preloadId:String;

        /** True while loading the assets */
        private var _loading:Boolean;

        /** List of assets. */
        private var _list:String;

        /** URL prefix. */
        private var _base:String;

        /** Metadata sheet name. */
        private var _metadata:String;

        /** The number of assets remaining to load */
        private var _loadedAssetCount:int;

        /** System references */
		private var _context:Object;

		private static var firstTime:Boolean = true;
        /**
         * Creates or reuses an instance of this class.
         *
         * @return  An instance of this class.
         */
        public static function make(alist:AnimList, wait:int, list:String, base:String, metadata:String, context:Object):Preload
        {
            // recycle or create an instance
            if (_pool.length > 0)
            {
                var anim:Preload = _pool.pop();
            }
            else
            {
                anim = new Preload();
            }
            // initialize the variables
            anim.wait = wait;
            anim.stime = 0;
            anim._loading = false;
            anim._list = list;
            anim._base = base;
			anim._metadata = metadata;
            anim._context = context;
            anim._loadedAssetCount = 0;
			anim._preloadId = "preload" + _idCounter++;

            // add it to the parent list
            alist.add(anim);
            return anim;
        }

        /**
         * Frees all resources for garbage collection.
         */
        override public function destroy():void
        {
			if ( _context != null )
			{
				_context.dispatcher.removeKeyListener( "preload.inc", decrementCount );
				_context = null;
			}
			if ( listener != null )
			{
				listener(this);
				listener = null;
			}
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
            if ( !_loading )
            {
                var control:AnimControl = alist.control;
                if (stime == 0)
                {
                    stime = control.time;
                }
                if (control.time >= stime+wait)
                {
                    if ( MetaData.instance == null )
                    {
                        return true;
                    }
					if ( _metadata == "assets" && MetaData.getConstantsBoolean( BrewConst.ROW_ENABLE_BUNDLING ) )
					{
						return true;
					}
                    var assetDefs:SheetData = _metadata ? MetaData.getSheetData( _metadata ) : null;
                    if ( _list )
                    {
                        var assets:Array = _list.split(",");
                    }
                    else
                    {
                        assets = assetDefs.getItems();
                    }
					_context.loaderQueue.resetDelay();
					_context.dispatcher.addKeyListener( "preload.inc", decrementCount );
					var lang:String = _context.language.substring( 0, 2 );
                    for (var i:int = 0; i < assets.length; i++)
                    {
                        var asset:Object = assets[ i ];
                        if ( asset is RowData )
                        {
							if ( _context.restrictBundlesTest != null && _context.restrictBundlesTest.indexOf( asset.getString( "group" ) ) == -1 )
							{
								continue;
							}
							key = asset.uid;
                            url = asset.getString();
							if ( _context.language != "en_US" && url.indexOf( "en" ) == 0 )
							{
								url = lang + url.substr( 2 );
							}
                        }
                        else if ( asset.indexOf( ":" ) == -1 )
                        {
                            key = asset as String;
                            url = assetDefs.getString( key );
                            if ( url == null )
                            {
                                _context.log.warning( ".animate: could not find URL for " + key, this );
                                continue;
                            }
                        }
                        else
                        {
                            var keyVal:Array = asset.split(":");
                            var key:String = keyVal[ 0 ];
                            var url:String = keyVal[ 1 ];
                        }
						var item:Object;
                        if ( url )
                        {
                            if ( key == "gas" )
                            {
                                url = _base + url + ".xml";
                                _loadedAssetCount++;
                                var uriToLoad:String = ( _context.parameters && _context.parameters.cmsUseAPI && _context.parameters.cmsUseAPI == "true" ) ? CMS.getFileUri( url ) : _context.urlPrefix + url;
								item = _context.assetLoader.loadText( key, uriToLoad, _handleGasLoaded );
                            }
							else if ( url.indexOf( ".swf" ) != -1 )
							{
								_loadedAssetCount++;
								url = "swf/" + url;
								uriToLoad = ( _context.parameters && _context.parameters.cmsUseAPI && _context.parameters.cmsUseAPI == "true" ) ? CMS.getFileUri( url ) : _context.urlPrefix + url;
//								uriToLoad = "XXX" + uriToLoad;	// for testing only
								item = _context.loaderQueue.loadItem( key, uriToLoad, _preloadId, AssetLoader.TYPE_SWF );
							}
							else if ( url.indexOf( ".mp3" ) != -1 )
							{
								url = _base + url;
								if ( _context.assetHash.getSound( key ) == null && _context.assetHash.getSoundUrl( key ) == null )
								{
									uriToLoad = ( _context.parameters && _context.parameters.cmsUseAPI && _context.parameters.cmsUseAPI == "true" ) ? CMS.getFileUri( url ) : _context.urlPrefix + url;

									if ( asset.getBoolean( BrewConst.COL_STREAMABLE ) )
									{
										// save the sound url for streaming
										_context.assetHash.putSoundUrl( key, uriToLoad );
									}
									else
									{
										_loadedAssetCount++;
										item = _context.loaderQueue.loadItem( key, uriToLoad, _preloadId, AssetLoader.TYPE_SOUND );
									}
								}
							}
                            else
                            {
                                url = _base + url;
                                tryLoad( key, url );
								tryLoadPostfix( key, url, "img_ing_", "_icon" );
								tryLoadPostfix( key, url, "img_ing_", "_orderIcon" );
                                tryLoadPostfix( key, url, "img_prod_", "_icon" );
                                tryLoadPostfix( key, url, "img_app_", "_icon" );
                                tryLoadPostfix( key, url, "img_prod_", "_orderIcon" );
                            }
                        }
						if ( item != null )
						{
							item.progressListener = _context.progressListener;
						}
                    }
                    if ( _loadedAssetCount > 0 )
                    {
                        _loading = true;
                    }
                    else
                    {
                        return true;
                    }
                }
            }
            return false;
        }

        private function tryLoadPostfix( key:String, url:String, prefix:String, postfix:String ):void
        {
            if ( key.indexOf( prefix ) == 0 )
            {
                var idx:int = url.length - 4;
                tryLoad( key + postfix, url.substr( 0, idx ) + postfix + url.substr( idx ) );
            }
        }

        private function tryLoad( key:String, url:String ):void
        {
            if ( _context.assetHash.getBitmapData( key ) == null )
            {
                _loadedAssetCount++;
                var uriToLoad:String = ( _context.parameters && _context.parameters.cmsUseAPI && _context.parameters.cmsUseAPI == "true" ) ? CMS.getFileUri( url ) : _context.urlPrefix + url;
				_context.loaderQueue.loadItem( key, uriToLoad, _preloadId, AssetLoader.TYPE_IMAGE );
            }
        }

        private function decrementCount( key:String=null, value:String=null ):void
        {
			if ( value == null || value == _preloadId )
			{
	            _loadedAssetCount--;
	            if (_loadedAssetCount == 0)
	            {
					if ( _metadata )
					{
						_context.log.info( ".decrementCount: metadata " + _metadata + " loaded", this );
					}
	                destroy();
	            }
			}
        }

        private function _handleGasLoaded(item:Object):void
        {
            _context.animParser.processString( item.data );
            decrementCount();
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
                tokenizer.getString( "list", "" ),
                tokenizer.getString( "base", "" ),
				tokenizer.getString( "metadata", "" ),
                context
            );
            helper.parseAnimAttributes( anim, tokenizer );
            tokenizer.destroy();
        }

    }
}
