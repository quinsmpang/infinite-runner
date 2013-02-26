package games.tinywings {

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	
	import games.hungryhero.Assets;
	
	import nape.phys.Body;
	
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;

	/**
	 * @author Aymeric
	 */
	public class HillsTexture extends Sprite {
		
		private var _groundTexture:Texture;
		private var _sliceWidth:uint;
		private var _sliceHeight:uint;
		
		private var _images:Vector.<Image>;
		
		private var _flagAdded:Boolean = false;

		[Embed(source="/../embed/noise.png")]
		private static const Noise:Class;
		
		public function HillsTexture() {
		}
		
		public function init(sliceWidth:uint, sliceHeight:uint):void {
			
			_sliceWidth = sliceWidth;
			_sliceHeight = sliceHeight;
			
//			var myBitmapData:BitmapData = new BitmapData( 400, 300 );
//			myBitmapData.perlinNoise( 400, 300, 5, 67, true, true, 4, true);
			
//			
			var texture:Texture = Texture.fromBitmap( new Noise() );
			
//			var myBitmapData:BitmapData = new BitmapData( _sliceWidth, _sliceHeight );
//			myBitmapData.perlinNoise( _sliceWidth, _sliceHeight, 5, 67, true, true, 4, true);
			
//			_groundTexture = texture;
//			_groundTexture = Texture.fromBitmapData(myBitmapData);
			_groundTexture = Texture.fromBitmapData(new BitmapData(_sliceWidth, _sliceHeight, false, 0x2277ee));
			
			_images = new Vector.<Image>();
			
			addEventListener(Event.ADDED, _added);
		}

		private function _added(evt:Event):void {
			
			_flagAdded = true;
			
			removeEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		public function update():void {
			
			// we don't want to move the parent like StarlingArt does!
			if (_flagAdded)
				this.parent.x = this.parent.y = 0;
		}
		
		public function createSlice(rider:Body, nextYPoint:uint, currentYPoint:uint):void {
			
			var image:Image = new Image(_groundTexture);
			//image.blendMode = BlendMode.MULTIPLY;
			addChild(image);
			
			_images.push(image);
			
			var matrix:Matrix = image.transformationMatrix;
            matrix.translate(rider.position.x, rider.position.y);
            matrix.a = 1.04;
            matrix.b = (nextYPoint - currentYPoint) / _sliceWidth;
            image.transformationMatrix.copyFrom(matrix); 
		}
		
		public function deleteHill(index:uint):void {
			
			removeChild(_images[index], true);
			_images.splice(index, 1);
		}
	}
}
