/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.parsing
 {
	import com.playdom.common.interfaces.IBitmaps;
	import com.playdom.common.interfaces.ILog;
	import com.playdom.common.interfaces.ISettings;
	import com.playdom.common.recycle.RecyclableBitmap;
	import com.playdom.common.recycle.RecyclableBlur;
	import com.playdom.common.recycle.RecyclableHSB;
	import com.playdom.common.recycle.RecyclableSprite;
	import com.playdom.common.util.FindChild;
	import com.playdom.common.util.Hashtable;
	import com.playdom.gas.AnimBackground;
	import com.playdom.gas.AnimControl;
	import com.playdom.gas.AnimList;
	import com.playdom.gas.anims.AnimBase;
	import com.playdom.gas.anims.Normalizer;
	import com.playdom.gas.interfaces.IAnimParser;
	import com.playdom.steamboat.data.resources.AssetManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	/**
	 * Helps perform script parsing.
	 * 
	 * @author Rob Harris
	 */
	public class ParserHelper
	{
		/** Temporary variables. */
		public var aVars:Hashtable;
		
		/** The image asset manager. */
		private var bitmapAssets:IBitmaps;
		
		/** The animation controller. */
		private var animControl:AnimControl;
		
		/** The insertion layer for display objects. */
		public var objLayer:DisplayObjectContainer;
		
		/** The insertion layer for background image. */
		private var bgLayer:Sprite;
		
		/** The current animation list being constructed. */
		private var _alist:AnimList;
		
		/** The current display object. */
		public var currDob:DisplayObject;
		
		public var lastAlist:AnimList;
		public var lastDob:DisplayObject;
		
		public var settings:ISettings;
		
		public var logger:ILog;
		
		/** A reusable rectangle. */
		private var tmpRect:Rectangle = new Rectangle();
		
		/** A reusable point. */
		private static var tempPoint:Point = new Point(0, 0);
		
		/** A reusable point set to 0,0. */
		private static const zeroPoint:Point = new Point(0, 0);
		
		/** The parent parser. */
		public var parser:IAnimParser;
		
		/** Used by AnimBackground to sense resize events */
		public var container:DisplayObjectContainer;
		
		private var listStack:Array = [];
		
		/**
		 * Creates an instance of this class.
		 * 
		 * @param parser The script parser.
		 */
		public function ParserHelper(parser:IAnimParser) 
		{
			this.parser = parser;
		}
		
		public function set alist( list:AnimList ):void
		{
			_alist = list;	
		}
		
		public function get alist():AnimList
		{
			return _alist;
		}
		
		public function pushList():AnimList
		{
			if ( _alist != null )
			{
				var newList:AnimList = animControl.animListFactory( currDob, animControl );
				_alist.add( newList );
			}
			else
			{
				newList = animControl.attachAnimList( currDob );
			}
			listStack.push( _alist );
			return _alist = lastAlist = newList;
		}
		
		public function popList():void
		{
			if ( listStack.length > 0 )
			{
				_alist = listStack.pop();
				if ( _alist )
				{
					lastAlist =  _alist;
				}
			}
			else
			{
				logger.error( ".popList: stack is empty", this );
			}
		}
		        
		/**
		 * Initializes this instance.
		 * 
		 * @param animControl  The animation controller.
		 * @param objLayer     The insertion layer for display objects.
		 * @param bgLayer      The background layer.
		 * @param settings     The configuration settings object.
		 * @param logger       The message logger.
		 * @param bitmapAssets The asset manager.
		 * @param vars         The animation system variable hashtable.
		 * @param container    Used to sense resize events.
		 */
		public function init(animControl:AnimControl, objLayer:DisplayObjectContainer, bgLayer:Sprite, settings:ISettings, logger:ILog, bitmapAssets:IBitmaps, vars:Hashtable, container:DisplayObjectContainer):void
		{
			this.animControl = animControl;
			this.objLayer = objLayer;
			this.bgLayer = bgLayer;
			this.settings = settings;
			this.logger = logger;
			this.bitmapAssets = bitmapAssets;
			this.aVars = vars;
			this.container = container;
		}
		
		public function parseBackgroundAttributes(w:int, h:int, tokenizer:ScriptTokenizer):void
		{
			if (bgLayer)
			{
				var bg:String = tokenizer.getString("bg", "");
				if (bg)
				{
					// add a bg image
					if (animControl.bg)
					{
						(animControl.bg as AnimBackground).reset(0, RecyclableBitmap.make(bg, null, bitmapAssets));
					}
					else
					{
						animControl.bg = new AnimBackground(w, h, 0, RecyclableBitmap.make(bg, null, bitmapAssets), container, logger);
						bgLayer.addChild(animControl.bg);
					}
				}
				else
				{
					var bgColor:String = tokenizer.getString("bgColor", "");
					if (bgColor)
					{
						if (animControl.bg)
						{
							(animControl.bg as AnimBackground).reset(parseInt(bgColor,16), null);
						}
						else
						{
							animControl.bg = new AnimBackground(w, h, parseInt(bgColor,16), null, container, logger);
							bgLayer.addChild(animControl.bg);
						}
					}
				}
			}
		}
		
		public function parseEasingAttribute(normalizer:Normalizer, tokenizer:ScriptTokenizer):void
		{
			var easing:String = tokenizer.getString("easing", "");
			if (easing)
			{
				switch (easing)
				{
					case "in":
					{
						normalizer.easing = Normalizer.EASE_IN;
						break;
					}
					case "out":
					{
						normalizer.easing = Normalizer.EASE_OUT;
						break;
					}
					case "both":
					{
						normalizer.easing = Normalizer.EASE_BOTH;
						break;
					}
				}
			}
		}
		
		/**
		 * Initializes an Anim object using tokenized data.
		 *  
		 * @param anim      The Anim object.
		 * @param tokenizer The script tokenizer.
		 */
		public function parseAnimAttributes( anim:AnimBase, tokenizer:ScriptTokenizer ):void
		{
			anim.name = tokenizer.getString( "name", null );
			anim.osc = tokenizer.getBoolean( "osc", false );
			anim.loop = anim.osc ? true : tokenizer.getBoolean( "loop", false );
			anim.block = tokenizer.getBoolean( "block", false );
			anim.killDob = tokenizer.getBoolean( "killDob", false );
			anim.repeat = tokenizer.getInt( "repeat", -1 );
		}
		
		/**
		 * Initializes a display object using tokenized data.
		 *  
		 * @param dob         The display object.
		 * @param tokenizer   The script tokenizer.
		 * @param defx        The default x location.
		 * @param defy        The default y location.
		 * @param attachAlist True if an empty AnimList should be attached.
		 * @param place       True if the display object should be placed in a location.
		 * 
		 * @return The anim list.
		 */
		public function parseDobAttributes( dob:DisplayObject, tokenizer:ScriptTokenizer, defx:int=0, defy:int=0, place:Boolean=true ):void
		{
			var saveDob:DisplayObject = currDob;
			currDob = dob;
			
			// parse the attributes
			
			if (dob is Bitmap)
			{
				(dob as Bitmap).smoothing = tokenizer.getBoolean("smoothing", false);
			}
			else if (dob is Sprite)
			{
				var cont:Sprite = dob as Sprite;
				if (cont.numChildren > 0)
				{
					var child:DisplayObject = cont.getChildAt(0);
					if (child is Bitmap)
					{
						(child as Bitmap).smoothing = tokenizer.getBoolean("smoothing", false);
					}
				}
				
				// mouse
				if ( !tokenizer.getBoolean( "mouse", true ) )
				{
					cont.mouseEnabled = false;
					cont.mouseChildren = false;
				}
			}
			else if (dob is TextField)
			{
				var tf:TextField = dob as TextField
				// mouse
				if ( !tokenizer.getBoolean( "mouse", true ) )
				{
					tf.mouseEnabled = false;
				}
			}
			
			var tint:String = tokenizer.getString("tint", null);
			if (tint != null)
			{
				var trans:ColorTransform =  new ColorTransform();
				trans.color = parseInt(tint, 16);
				dob.transform.colorTransform = trans;
			}
			
			// optional anchor point
			var anchor:String = tokenizer.getString("anchor", "");
			if (anchor)
			{
				var dx:int = -dob.width/2;
				var dy:int = -dob.height/2;
				if (anchor != "center")
				{
					var idx:int = anchor.indexOf(",");
					if (idx != -1)
					{
						dx = -parseInt(anchor.substring(0, idx));
						dy = -parseInt(anchor.substr(idx+1));
					}
				}
				//				var spr:RecyclableSprite = RecyclableSprite.make(objLayer);
//				spr = RecyclableSprite.make(dob.parent);
				var centerer:Sprite = RecyclableSprite.make(dob.parent);
//				spr.addChild(dob);
				centerer.addChild(dob);
				dob.x = dx;
				dob.y = dy;
//				dob = spr;
				dob = centerer;
				currDob = dob;
//				if ( _alist != null )
//				{
//					_alist.dob = dob;
//				}
				if ( !tokenizer.getBoolean( "mouse", true ) )
				{
					centerer.mouseEnabled = false;
					centerer.mouseChildren = false;
				}
			}
			
			var blur:Number = tokenizer.getNumber("blur", 0);
			if (blur > 0)
			{
				var bf:RecyclableBlur = RecyclableBlur.make();
				bf.setBlur(blur);
				dob.filters = bf.array;
				if (dob.hasOwnProperty("blur"))
				{
					dob["blur"] = bf;
				}
			}
			
			var blend:String = tokenizer.getString("blend", null);
			if (blend)
			{
				doBlend(blend, dob);
			}
			
			var mask:String = tokenizer.getString("mask", null);
			if (mask)
			{
//				var dob2:DisplayObject = FindChild.byName( mask, animControl.stage );
				var dob2:DisplayObject = FindChild.byName( mask, dob.stage );
				if (dob2 != null)
				{
					dob.mask = dob2;
				}
			}
			
			// process common settings
			if (place)
			{
				dob.x = tokenizer.getInt("x", defx);
				dob.y = tokenizer.getInt("y", defy);
			}
			
			// scale
			var sx:Number = tokenizer.getNumber("scalex", 0);
			var sy:Number = tokenizer.getNumber("scaley", 0);
			if (sx == 0 && sy == 0)
			{
				sy = sx = tokenizer.getNumber("scale", 1);
			}
			else
			{
				if (sx == 0)
				{
					sx = tokenizer.getNumber("scale", 1);
				}
				if (sy == 0)
				{
					sy = tokenizer.getNumber("scale", 1);
				}
			}
			dob.scaleX = sx;
			dob.scaleY = sy;
			dob.alpha = tokenizer.getNumber("alpha", 1);
			dob.visible = tokenizer.getBoolean("visible", true);
			dob.rotation = tokenizer.getNumber("rotation", dob.rotation);
			dob.name = tokenizer.getString("name", dob.name);
			
			// process the children
			var len:int = tokenizer.getNumChildren();
			if (len > 0)
			{
				pushList();
//				parser.parseScript(tokenizer, objLayer );
				parser.parseScript(tokenizer, cont ? cont : objLayer );
				popList();
			}
			lastDob = saveDob ? saveDob : currDob;
			currDob = saveDob;
		}
		
		public function doBlend(blend:String, dob:DisplayObject):void
		{
			var idx:int = BLEND_MODE_KEYS.indexOf(blend);
			if (idx != -1)
			{
				dob.blendMode = BLEND_MODE_CONSTS[idx];
			}
		}
		
		private static const BLEND_MODE_KEYS:Array = ["add", "darken", 
			"difference", "hardlight", "invert", "lighten", 
			"multiply", "normal", "overlay", "screen", "subtract"];
		
		private static const BLEND_MODE_CONSTS:Array = [BlendMode.ADD, BlendMode.DARKEN, 
			BlendMode.DIFFERENCE, BlendMode.HARDLIGHT, BlendMode.INVERT, BlendMode.LIGHTEN, 
			BlendMode.MULTIPLY, BlendMode.NORMAL, BlendMode.OVERLAY, BlendMode.SCREEN, BlendMode.SUBTRACT];
		
		/**
		 * Copies a portion of a bitmap image from a source area to a new BitmapData object.
		 *  
		 * @param sourceData  The source bitmap image.
		 * @param sourceRect  The source area.
		 * 
		 * @return  A new BitmapData object. 
		 */
		private static function copyBitmapData(sourceData:BitmapData, sourceRect:Rectangle):BitmapData 
		{
			var bmd:BitmapData = new BitmapData(sourceRect.width, sourceRect.height, true, 0x00000000);
			bmd.copyPixels(sourceData, sourceRect, zeroPoint);
			return bmd;
		}
		
		/**
		 * Slices an image into equal pieces and stores the parts under the parent
		 * name plus incrementing digits (heart -> heart1, heart2, heart3, ...).
		 * The parts are cut left to right top to bottom in a grid. 
		 * 
		 * @param key  The key of the source image.
		 * @param cols The number of rows.
		 * @param rows The number of columns.
		 */
		public function sliceImage(src:String, base:String, cols:int, rows:int):void
		{
			var image:BitmapData = bitmapAssets.getBitmapData(src);
			if (image)
			{
				tmpRect.width = Math.floor(image.width/cols);
				tmpRect.height = Math.floor(image.height/rows);
				tmpRect.x = tmpRect.y = 0;
				var idx:int = 0;
				for (var row:int = 0; row < rows; row++)
				{
					tmpRect.x = 0;
					for (var col:int = 0; col < cols; col++)
					{
						bitmapAssets.putBitmapData(base+(idx++).toString(), copyBitmapData(image, tmpRect));
						tmpRect.x += tmpRect.width;
					}
					tmpRect.y += tmpRect.height;
				}
			}
		}
		
		/**
		 * Slices an image into equal pieces and stores the parts under the parent
		 * name plus incrementing digits (heart -> heart1, heart2, heart3, ...).
		 * The parts are cut left to right top to bottom in a grid. 
		 * 
		 * @param key  The key of the source image.
		 * @param cols The number of rows.
		 * @param rows The number of columns.
		 */
		public static function sliceImage2(src:String, base:String, cols:int, rows:int, bitmaps:IBitmaps):void
		{
			var save:Boolean = AssetManager.ignoreMissing;
			AssetManager.ignoreMissing = true;
			if ( bitmaps.getBitmapData( base + "0" ) == null )	// check for existing slices
			{
				var image:BitmapData = bitmaps.getBitmapData(src);
				if (image)
				{
					tmpRect2.width = Math.floor(image.width/cols);
					tmpRect2.height = Math.floor(image.height/rows);
					tmpRect2.x = tmpRect2.y = 0;
					var idx:int = 0;
					for (var row:int = 0; row < rows; row++)
					{
						tmpRect2.x = 0;
						for (var col:int = 0; col < cols; col++)
						{
							bitmaps.putBitmapData(base+(idx++).toString(), copyBitmapData(image, tmpRect2));
							tmpRect2.x += tmpRect2.width;
						}
						tmpRect2.y += tmpRect2.height;
					}
				}
			}
			AssetManager.ignoreMissing = save;
		}
		private static var tmpRect2:Rectangle = new Rectangle();
		
		public function makeSeq(base:String, start:int, end:int, seq:String=null):Array
		{
			var arr:Array = [];
			if (seq)
			{
				var arr2:Array = seq.split(",");
				for (var i:int = 0; i < arr2.length; i++)
				{
					arr[i-start] = bitmapAssets.getBitmapData(base+arr2[i]);
				}
			}
			else
			{
				for (i = start; i <= end; i++)
				{
					arr[i-start] = bitmapAssets.getBitmapData(base+i.toString());
					
					if ( arr[i-start] == null )
					{
						trace( "no bitmap" );
					}
				}
			}
			return arr;
		}

		public function getSetting(key:String, def:String):String
		{
			var value:String = def;
			if (key)
			{
				value = aVars.getString(key, def);
				if (!value)
				{
					value = settings.getString(key, def);
				}
			}
			return value;
		}
		
		/**
		 * Randomly picks from a comma-separated set
		 *  
		 * @param val  The set string.
		 * 
		 * @return One item from the set.
		 */
		private function randomSet(val:String):String 
		{
			var len:int = val.length;
			var arr:Array = val.substring(1, len-1).split(",");
			var rnd:int = Math.random()*arr.length;
			return arr[rnd];
		}
		
		/**
		 * Randomly picks from a range of numbers
		 *  
		 * @param val  The set string.
		 * 
		 * @return One item from the set.
		 */
		private function randomValue(val:String):Number 
		{
			var idx:int = val.indexOf("_");
			var len:int = val.length;
			var min:Number = parseFloat(val.substring(1, idx));
			var max:Number = parseFloat(val.substring(idx+1, len));
			var rnd:Number = Math.random()*(max-min+1)+min;
			return rnd;
		}
		
		/**
		 * Applies a hue to an image and returns a new image.
		 *  
		 * @param image The source image.
		 * @param hue   The hue value (0 to 359)
		 * 
		 * @return A new image with the hue applied.
		 */
		public function applyHue(image:BitmapData, hue:int):BitmapData 
		{
			var result:BitmapData = new BitmapData(image.width, image.height, true, 0);
			var w:int = image.width;
			var h:int = image.height;
			for (var y:int = 0; y < h; y++)
			{
				for (var x:int = 0; x < w; x++)
				{
					var argb:uint = image.getPixel32(x, y);
					if (argb != 0)
					{
						var rgb:uint = argb & 0xffffff;
						argb = argb & 0xff000000;
						var hsb:RecyclableHSB = RecyclableHSB.convertRGBtoHSB(rgb);
						rgb = RecyclableHSB.convertHSBtoRGB(hue, hsb.saturation, hsb.brightness);
						argb = argb | rgb;
						result.setPixel32(x, y, argb);
						hsb.destroy();
					}
				}
				x = 0;
			}
			return result;
		}
		
		/**
		 * Slices an image into same-sized pieces.
		 *  
		 * @param src  The source image.
		 * @param base The base name of the new images.
		 * @param cols The number of columns in the grid.
		 * @param rows The number of rows in the grid.
		 * @param name (optional) The name of the sheet; if this is specified, it will ensure the sheet is only cut once. 
		 * 
		 */
		public function sliceSheet(src:String, base:String, cols:int, rows:int, name:String=null):void
		{
			if (name && animControl.sheetNames.indexOf(name) != -1)
			{	// sheet already cut - do not cut again
				return;
			}
			animControl.sheetNames.push(name);
			sliceImage(src, base, cols, rows);
		}
		
		public function makeSheet(tokenizer:ScriptTokenizer):void
		{
			var base:String = tokenizer.getString("base", "");
			if (base)
			{	// the presense of a base attribute indicates the images should be sliced
				sliceSheet(tokenizer.getString("src", base), 
					base, 
					tokenizer.getInt("cols", 1), 
					tokenizer.getInt("rows", 1), 
					tokenizer.getString("name", ""));
			}
			else
			{
				var dest:String = tokenizer.getString("dest", "");
				if (dest)
				{	// the presense of a dest attribute indicates images should be combined
					var bmd:BitmapData = combineImages(tokenizer.getString("list", ""), tokenizer.getBoolean("horiz", true));
					if (bmd)
					{
						bitmapAssets.putBitmapData(dest, bmd);
					}
				}
			}
		}
		
		public function combineImages(list:String, horiz:Boolean, base:String=""):BitmapData
		{
			var bmdOut:BitmapData;
			if (list)
			{
				// split the list
				var images:Array = list.split(",");
				
				// fetch the first image (used for image size)
				var bmdIn:BitmapData = bitmapAssets.getBitmapData(base+images[0]);
				if (bmdIn)
				{
					tmpRect.width = bmdIn.width;
					tmpRect.height = bmdIn.height;
					tmpRect.x = tmpRect.y = 0;
					
					// create the destination image
					if (horiz)
					{
						bmdOut = new BitmapData(images.length*tmpRect.width, tmpRect.height);
					}
					else
					{
						bmdOut = new BitmapData(tmpRect.width, images.length*tmpRect.height);
					}
					
					// init the destination pointer
					tempPoint.x = tempPoint.y = 0;
					
					// copy each image to the destination
					for (var i:int = 0; i < images.length; i++)
					{
						bmdIn = bitmapAssets.getBitmapData(base+images[i]);
						if (bmdIn)
						{
							bmdOut.copyPixels(bmdIn, tmpRect, tempPoint);
						}
						if (horiz)
						{
							tempPoint.x += tmpRect.width;
						}
						else
						{
							tempPoint.y += tmpRect.height;
						}
					}
				}
			}
			return bmdOut;
		}
		
		public function colorOverlay(src:String, dest:String, hue:int):BitmapData
		{
			var bmdOut:BitmapData = null;
			var bmdIn:BitmapData = bitmapAssets.getBitmapData(src);
			if (bmdIn)
			{
				if (dest)
				{
					bmdOut = applyHue(bmdIn, hue);
					bitmapAssets.putBitmapData(dest, bmdOut);
				}
			}
			return bmdOut;
		}
	}
}