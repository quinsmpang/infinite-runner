/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.parsing
 {
	import com.playdom.common.interfaces.IBitmaps;
	import com.playdom.common.interfaces.ILog;
	import com.playdom.common.interfaces.ISWFObject;
	import com.playdom.common.interfaces.ISettings;
	import com.playdom.common.recycle.RecyclableBitmap;
	import com.playdom.common.recycle.RecyclableShape;
	import com.playdom.common.recycle.RecyclableSprite;
	import com.playdom.common.recycle.RecyclableTextField;
	import com.playdom.common.util.FindChild;
	import com.playdom.common.util.Hashtable;
	import com.playdom.common.util.trimString;
	import com.playdom.framework.SystemContext;
	import com.playdom.gas.AnimControl;
	import com.playdom.gas.AnimList;
	import com.playdom.gas.SpecialEffect;
	import com.playdom.gas.interfaces.IAnimParser;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	/**
	 * Parses tokenized data to create animated display objects.
	 * 
	 * @author Rob Harris
	 */
	public class AnimParser implements IAnimParser
	{
		/** Extends parser logic. */
		public var nextParser:IAnimParser;
		
		/** Helps with parser logic. */
		public var helper:ParserHelper;
		
		/** The insertion layer for display objects. */
		public var objLayer:DisplayObjectContainer;
		
		/** True if the parser is running in the GASkit. */
		public var isGasKit:Boolean = false;
		
		/** The script format tokenizer (XML, JSON). */
		private var tokenizer:ScriptTokenizer;
		
		/** The asset manager. */
		private var assets:ISWFObject;
		
		/** The image asset manager. */
		private var bitmapAssets:IBitmaps;
		
		/** The animation controller. */
		private var animControl:AnimControl;
		
		/** The current display object being constructed. */
		private var dob:DisplayObject;
		
		private var protos:Array = [];
		
		private var logger:ILog;
		
		private var context:SystemContext;
		
		private var tagHandlers:Dictionary = new Dictionary();
		
		private var currExtSwf:String;
		
		/**
		 * Creates an instance of this class.
		 */
		public function AnimParser() 
		{
			helper = new ParserHelper(this);
		}
		
		public function setTokenizer(tokenizer:ScriptTokenizer, animVars:Hashtable):void
		{
			this.tokenizer = tokenizer;
			tokenizer.init(animVars, logger);
		}
		
		public function setAssets( assets:ISWFObject, bitmapAssets:IBitmaps ):void
		{
			if ( assets )
			{
				this.assets = assets;
			}
			if ( bitmapAssets )
			{
				this.bitmapAssets = bitmapAssets;
			}
		}
		        
		/**
		 * Initializes this class.
		 * 
		 * @param assets       The asset manager
		 * @param animControl  The animation controller
		 * @param objLayer     The insertion layer for display objects
		 * @param bgLayer      The insertion layer for the background image
		 * @param settings     The configuration settings object.
		 * @param logger       The message logger.
		 * @param context      The context object with 5 required properties: viewW:int, viewH:int, playfieldLayer:Sprite, animVars:Hashtable, animControl:AnimControl
		 * @param bitmapAssets The bitmap asset manager.
		 * @param animVars     The animation system variable hashtable.
		 * @param container    The outer container for sensing resize events.
		 * @param tokenizer    The script tokenizer.
		 */
		public function init(assets:ISWFObject, animControl:AnimControl, objLayer:DisplayObjectContainer, bgLayer:Sprite, 
							 settings:ISettings, logger:ILog, context:SystemContext, bitmapAssets:IBitmaps, animVars:Hashtable, 
							 container:DisplayObjectContainer, tokenizer:ScriptTokenizer):void
		{
			setAssets( assets, bitmapAssets );
//			this.assets = assets;
			this.objLayer = objLayer;
			this.animControl = animControl;
			this.logger = logger;
			this.context = context;
//			this.bitmapAssets = bitmapAssets;
			setTokenizer(tokenizer, animVars);
			
			helper.init(animControl, objLayer, bgLayer, settings, logger, bitmapAssets, animVars, container);
			
			tagHandlers["config"] = handleScene;
			tagHandlers["data"] = handleScene;
			tagHandlers["scene"] = handleScene;
			
			tagHandlers["kitonly"] = handleKitOnly;
			tagHandlers["link"] = handleLink;
			tagHandlers["ignore"] = handleIgnore;
//			tagHandlers["tags"] = handleTags;
			
			tagHandlers["effect"] = handleEffect;
			
			tagHandlers["view"] = handleView;
			tagHandlers["define"] = handleDefine;
			tagHandlers["sheet"] = handleSheet;
			tagHandlers["overlay"] = handleOverlay;
			
			tagHandlers["proto"] = handleProto;
			tagHandlers["instance"] = handleInstance;
			
			// display objects
			tagHandlers["group"] = handleGroup;
			tagHandlers["image"] = handleImage;
			tagHandlers["text"] = handleText;
			tagHandlers["shape"] = handleShape;
			tagHandlers["SWFobject"] = handleSWFObject;
		}
		
		/**
		 * Recursively processes an XML string.
		 *
		 * @param xml The XML string.
		 */
		public function processString(script:String, layer:DisplayObjectContainer = null):void 
		{
			if (script)
			{
				try
				{
					tokenizer.source = script;
					parseScript(tokenizer, layer);
					helper.alist = null;
				}
				catch (err:Error)
				{
					logger.error(".processString: "+err.message + "  " + err.getStackTrace(), this)
				}
			}
		}
		
		/**
		 * Recursively processes XML data.  
		 *
		 * @param list  The XML data.
		 */
		public function parseScript(tokenizer:ScriptTokenizer, layer:DisplayObjectContainer = null):void 
		{
			try 
			{
				var saveLayer:DisplayObjectContainer = objLayer;
				if (layer)
				{
					objLayer = layer;
				}
				var children:Array = tokenizer.getChildren();
				for each (var child:ScriptTokenizer in children) 
				{ 
					processChild( child );
				}
				objLayer = saveLayer;
			}
			catch (err:Error) 
			{
				logger.error(".parseScript: "+err.message + "  " + err.getStackTrace(), this)
			}
		}
		
		/**
		 * Adds a custom tag handler.
		 *  
		 * @param tag     The associated tag.
		 * @param handler The handler function.
		 */
		public function addTagHandler( tag:String, handler:Function ):void 
		{
			tagHandlers[ tag ] = handler;
		}
		
		/**
		 * Processes data for a child.  
		 *
		 * @param list  The XML data.
		 */
		public function processChild( child:ScriptTokenizer ):void 
		{
			if ( child != null ) 
			{
				var tag:String = child.getTag();
				var handler:Function = tagHandlers[tag];
				if ( handler != null )
				{
					try
					{
						handler( child, helper, context );
					}
					catch ( err:Error )
					{
						helper.logger.warning( ".processChild: " + tag + "   " + err.message, this );
					}
				}
				else if ( nextParser )
				{
					nextParser.processChild( child );
				}
				else
				{
					helper.logger.warning( ".processChild: unhandled tag = "+tag, this );
				}
			}
		}
		
		private function handleSwfLoaded( item:Object ):void
		{
			context.gameState.setObject( item.key, item.data ); 
			context.stage.dispatchEvent( new Event( "refresh-xml" ) );
		}
		
		public function findTarget(target:String):AnimList
		{
			var dob:DisplayObject = FindChild.byName( target, context.playfieldLayer );
			if (dob)
			{	// target found
				var alist2:AnimList = animControl.findAnimList(dob);
				if (!alist2)
				{
					alist2 = animControl.attachAnimList(dob);
				}
				// add prototype to the specified target
				dob = alist2.dob;
			}
			return alist2;
		}
		
		private function makeInstance(tokenizer:ScriptTokenizer, loader:Object=null):void
		{
			var defs:String = tokenizer.getAttribute("defs");
			if (defs)
			{	// definitions
				var arr:Array = defs.split(",");
				for each(var def:String in arr)
				{
					tokenizer.processValue(def, null);
				}
			}
			var target:String = tokenizer.getString("target", "");
			if (target)
			{	// target specified
				//				var dob:DisplayObject = findTarget(target);
				var alist:AnimList = findTarget(target);
				animControl.makeProto( context, alist, tokenizer.getString( "proto", "" ) );
			}
			else
			{	// no target specified; create an independant prototype
				helper.alist = animListCreator(tokenizer.getString("proto", ""));
				dob = helper.alist.dob;
			}
			if (dob)
			{
				helper.parseDobAttributes( dob, tokenizer, dob.x, dob.y );
			}
			dob = null;
			tokenizer.destroy();
			if (loader)
			{
				loader.destroy();
			}
		}
		
		private function animListCreator( name:String ):AnimList
		{
			var proto:ScriptTokenizer = protos[ name ];
			if ( proto != null )
			{
				if ( context.tempAlist != null )
				{
					helper.alist = context.tempAlist;
//					parseScript( proto );
					parseScript( proto, context.tempLayer );
					helper.alist = null;
					return context.tempAlist;
				}
				else
				{
					helper.lastAlist = null;
					parseScript( proto, context.tempLayer );
					return helper.lastAlist;
				}
			}
			return null;
		}
		
		public static function makeEffect(name:String, x:int, y:int, w:int, h:int, buffer:int, context:SystemContext, def:ScriptTokenizer=null):SpecialEffect
		{
			var parser:AnimParser = new AnimParser();
			var animControl:AnimControl = new AnimControl(context.viewW, context.viewH);
			animControl.init(context.assetHash, context.assetHash, context.assetHash, context.log);
			animControl.start( context.enterFrameDispatcher );
			var effect:SpecialEffect = new SpecialEffect(w, h, buffer, def, animControl, parser, context);
			
			effect.x = x;
			effect.y = y;
			
			context.effects[name] = effect;
			return effect;
		}		
		
		// -------------------------------------- tag handlers --------------------------------------------------
		
		private function handleKitOnly( tokenizer:ScriptTokenizer, helper:ParserHelper, context:Object ):void
		{
			if ( isGasKit )
			{
				var swfName:String = tokenizer.getString( "swf", "" );
				if ( swfName && currExtSwf != swfName )
				{
					currExtSwf = swfName;
					context.assetLoader.loadSWF( "extAssets", "swf/" + swfName, handleSwfLoaded );
				}
				parseScript(tokenizer);
			}
			tokenizer.destroy();
		}
		
		private function handleLink( tokenizer:ScriptTokenizer, helper:ParserHelper, context:Object ):void
		{
			var key:String = tokenizer.getString( "key", "" );
			var file:String = tokenizer.getString( "file", "" );
			if ( key && file )
			{
				var bmd:BitmapData = bitmapAssets.getBitmapData( file );
				if ( bmd )
				{
					bitmapAssets.putBitmapData( key, bmd );
				}
			}
			tokenizer.destroy();
		}
		
		private function dummyHandler( tokenizer:ScriptTokenizer, helper:ParserHelper, context:Object ):void
		{
			// does nothing - used by ignore element
			
			tokenizer.destroy();
		}
		
		private function handleIgnore( tokenizer:ScriptTokenizer, helper:ParserHelper, context:Object ):void
		{
			var list:String = tokenizer.getString( "list", "" );
			if ( list )
			{
				var arr:Array = list.split( "," );
				for (var i:int = 0; i < arr.length; i++) 
				{
					var tag:String = trimString( arr[ i ] );
					addTagHandler( tag, dummyHandler );
				}
				
			}
			tokenizer.destroy();
		}
		
		private function handleScene( tokenizer:ScriptTokenizer, helper:ParserHelper, context:Object ):void
		{
			helper.parseBackgroundAttributes(animControl.viewWidth, animControl.viewHeight, tokenizer);
			helper.pushList();
			parseScript(tokenizer);
			helper.popList();
			tokenizer.destroy();
		}
		
		private function handleEffect( tokenizer:ScriptTokenizer, helper:ParserHelper, context: SystemContext ):void
		{
			try 
			{
				var name:String = tokenizer.getString("name", "");
				if (name)
				{
					var w:int = tokenizer.getInt("w", 10);
					var h:int = tokenizer.getInt("h", 10);
					var buffer:int = tokenizer.getInt("buffer", 1);
					
					var effect:SpecialEffect = makeEffect(name,  tokenizer.getInt("x", 0),  tokenizer.getInt("y", 0), w, h, buffer, context, tokenizer);
					effect.alpha = tokenizer.getNumber("alpha", 1);
					effect.visible = tokenizer.getBoolean("visible", true);
				}				
			}
			catch (err:Error) 
			{
				logger.info(".processXML: "+err, this)
			}
		}
		
		private function handleView( tokenizer:ScriptTokenizer, helper:ParserHelper, context:Object ):void
		{
			objLayer.scrollRect = new Rectangle(0, 0, tokenizer.getInt("w", animControl.viewWidth), tokenizer.getInt("h", animControl.viewHeight));
			tokenizer.destroy();
		}
		
		private function handleSheet( tokenizer:ScriptTokenizer, helper:ParserHelper, context:Object ):void
		{
			helper.makeSheet(tokenizer);
			tokenizer.destroy();
		}
		
		private function handleOverlay( tokenizer:ScriptTokenizer, helper:ParserHelper, context:Object ):void
		{
			helper.colorOverlay(tokenizer.getString("src", ""), tokenizer.getString("dest", ""), tokenizer.getInt("hue", 0));
			tokenizer.destroy();
		}
		
		private function handleDefine( tokenizer:ScriptTokenizer, helper:ParserHelper, context:Object ):void
		{
			var key:String = tokenizer.getString("key", "");
			if (key)
			{
				var type:String = tokenizer.getString("type", "string");
				switch (type)
				{
					case "int":
						var inc:String = tokenizer.getString("inc", "");
						if (inc)
						{
							context.animVars.setInt(key, context.animVars.getInt(key, 0)+parseInt(inc));
							//context.animVars.setString(key, helper.parseIntXML(child, "value", 0).toString());
						}
						else
						{
							context.animVars.setInt(key, tokenizer.getInt("value", 0));
						}
						break;
					case "float":
						context.animVars.setNumber(key, tokenizer.getNumber("value", 0));
						break;
					default:
						context.animVars.setString(key, tokenizer.getString("value", ""));
						break;
				}
			}
			tokenizer.destroy();
		}
		
		private function handleGroup( tokenizer:ScriptTokenizer, helper:ParserHelper, context:Object ):void
		{
			var spr:Sprite = RecyclableSprite.make(objLayer);
			var w:int = tokenizer.getInt("w", 0);
			var h:int = tokenizer.getInt("h", 0);
			if (w != 0 || h != 0)
			{
				var bg:String = tokenizer.getString("bg", "");
				var alpha:Number = bg ? 1 : 0;
				with (spr.graphics)
				{
					beginFill(parseInt(bg, 16), alpha);
					drawRect(0, 0, w, h);
					endFill();
				}
			}
			spr.mouseEnabled = false;
			var saveLyr:DisplayObjectContainer = objLayer;
			helper.objLayer = spr;
			
			helper.currDob = spr;
			helper.pushList();
			helper.parseDobAttributes( spr, tokenizer );
			helper.popList();
			
			var panRect:String = tokenizer.getString("panRect", null);
			var data:Array = panRect ? panRect.split( "," ) : null; 
			if ( data && data.length == 4 )
			{
				spr.scrollRect = new Rectangle( data[ 0 ], data[ 1 ], data[ 2 ], data[ 3 ] );
			}

			
			helper.objLayer = saveLyr;
			tokenizer.destroy();
		}
		
		private function handleProto( tokenizer:ScriptTokenizer, helper:ParserHelper, context:Object ):void
		{
			// associate the tokenizer with the prototype name 
			var name:String = tokenizer.getString("name", "");
			protos[name] = tokenizer;
			
			// associate the prototype name with the generic creator
			animControl.addAnimListCreator(name, animListCreator);
		}
		
		private function handleInstance( tokenizer:ScriptTokenizer, helper:ParserHelper, context:Object ):void
		{
//			var lazy:String = tokenizer.getString("lazy", "");
//			if (lazy)
//			{
//				new LazyProto(tokenizer, context, makeInstance);
//			}
//			else
//			{
				makeInstance(tokenizer);
//			}
		}
		
		private function handleImage( tokenizer:ScriptTokenizer, helper:ParserHelper, context:Object ):void
		{
			var bmp:Bitmap = RecyclableBitmap.make(tokenizer.getString("src", ""), objLayer, bitmapAssets);
			helper.parseDobAttributes( bmp, tokenizer );
			tokenizer.destroy();
		}
		
		private function handleText( tokenizer:ScriptTokenizer, helper:ParserHelper, context:Object ):void
		{
			var tf:TextField;
			dob = tf = RecyclableTextField.make(tokenizer.getString("text", ""), 
				tokenizer.getHex("color", 0), 
				tokenizer.getInt("size", 12), 
				objLayer, 
				tokenizer.getString("font", "Arial") );
			var bg:String = tokenizer.getString("bg", "");
			if (bg)
			{
				tf.background = true;
				tf.backgroundColor = tokenizer.getHex("bg", 0);
			}
			tf.embedFonts = tokenizer.getBoolean( "embed", false );
			helper.parseDobAttributes( dob, tokenizer );
			tokenizer.destroy();
		}
		
		private function handleShape( tokenizer:ScriptTokenizer, helper:ParserHelper, context:Object ):void
		{
			dob = RecyclableShape.make(objLayer,
				tokenizer.getString("type", "rect"), 
				tokenizer.getHex("color", 0xff0000), 
				tokenizer.getNumber("alpha", 1),  
				tokenizer.getInt("w", 10), 
				tokenizer.getInt("h", 10));
			helper.parseDobAttributes( dob, tokenizer );
			tokenizer.destroy();
		}
		
		private function handleSWFObject( tokenizer:ScriptTokenizer, helper:ParserHelper, context:Object ):void
		{
			var dob:DisplayObject =  assets.getDisplayObject( tokenizer.getString("src", ""), tokenizer.getString("swf", "swf.assets") );
			if (dob)
			{
				var frame:String = tokenizer.getString( "frame", null );
				if ( frame && dob is MovieClip )
				{
					try
					{
						( dob as MovieClip ).gotoAndStop( frame );
					}
					catch( err:Error )
					{
						( dob as MovieClip ).gotoAndStop( 1 );
					}
				}
				objLayer.addChild(dob);
				helper.parseDobAttributes( dob, tokenizer );
			}
			tokenizer.destroy();
		}
		
		// -----------------------------------------------------------------------------------------------------------------------

	}
}