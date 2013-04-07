/**
 *
 * Hungry Hero Game
 * http://www.hungryherogame.com
 * 
 * Copyright (c) 2012 Hemanth Sharma (www.hsharma.com). All rights reserved.
 * 
 * This ActionScript source code is free.
 * You can redistribute and/or modify it in accordance with the
 * terms of the accompanying Simplified BSD License Agreement.
 *  
 */

package  {

	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	
	/**
	 * This class holds all embedded textures, fonts and sounds and other embedded files.  
	 * By using static access methods, only one instance of the asset file is instantiated. This 
	 * means that all Image types that use the same bitmap will use the same Texture on the video card.
	 * 
	 * @author hsharma
	 * 
	 */
	public class Assets
	{
		/**
		 * Texture Atlas 
		 */
		[Embed(source="/../embed/mySpritesheet.png")]
		public static const AtlasTextureGame:Class;
		
		[Embed(source="/../embed/mySpritesheet.xml", mimeType="application/octet-stream")]
		public static const AtlasXmlGame:Class;
		
		/**
		 * Background Assets 
		 */
		[Embed(source="/../embed/bgLayer1.png")]
		public static const BgLayer1:Class;
		
		/**
		 * Mickey Assets
		 */
		[Embed(source="/../embed/mickey/mickeyall.xml", mimeType="application/octet-stream")]
		public static const MickeyConfig:Class;
		
		[Embed(source="/../embed/mickey/mickeyall.png")]
		public static const MickeyPng:Class;
		
		[Embed(source="/../embed/mickey/misc.xml", mimeType="application/octet-stream")]
		public static const MiscConfig:Class;
		
		[Embed(source="/../embed/mickey/misc.png")]
		public static const MiscPng:Class;
		
//		[Embed(source="/../embed/games/hungryhero//graphics/bgWelcome.jpg")]
//		public static const BgWelcome:Class;
		
		/**
		 * Texture Cache 
		 */
		private static var gameTextures:Dictionary = new Dictionary();
		private static var gameTextureAtlas:TextureAtlas;
		private static var mickeyTextureAtlas:TextureAtlas;
		private static var miscTextureAtlas:TextureAtlas;
		
		/**
		 * Returns the Texture atlas instance.
		 * @return the TextureAtlas instance (there is only oneinstance per app)
		 */
		public static function getAtlas():TextureAtlas
		{
			if (gameTextureAtlas == null)
			{
				var texture:Texture = getTexture("AtlasTextureGame");
				var xml:XML = XML(new AtlasXmlGame());
				gameTextureAtlas=new TextureAtlas(texture, xml);
			}
			
			return gameTextureAtlas;
		}
		
		public static function getMickeyAtlas():TextureAtlas
		{
			if (mickeyTextureAtlas == null)
			{
				var texture:Texture = getTexture("MickeyPng");
				var xml:XML = XML(new MickeyConfig());
				mickeyTextureAtlas=new TextureAtlas(texture, xml);
			}
			
			return mickeyTextureAtlas;
		}
		
		public static function getMiscAtlas():TextureAtlas
		{
			if (miscTextureAtlas == null)
			{
				var texture:Texture = getTexture("MiscPng");
				var xml:XML = XML(new MiscConfig());
				miscTextureAtlas=new TextureAtlas(texture, xml);
			}
			
			return miscTextureAtlas;
		}
		
		/**
		 * Returns a texture from this class based on a string key.
		 * 
		 * @param name A key that matches a static constant of Bitmap type.
		 * @return a starling texture.
		 */
		public static function getTexture(name:String):Texture
		{
			if (gameTextures[name] == undefined)
			{
				var bitmap:Bitmap = new Assets[name]();
				gameTextures[name]=Texture.fromBitmap(bitmap);
			}
			
			return gameTextures[name];
		}
	}
}
