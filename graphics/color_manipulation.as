/**
 * Allows for the manipulation of colors.
 *
 * Usage {{{
 *    var color:color_manipulation = new color_manipulation();
 * }}}
 */
 
package classes.graphics {
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class color_manipulation {
		// Global vars
		private var _edge_flood_modified:Boolean = new Boolean(false); // flag for the edge-color removal to tell if any changes were made on the current flood
		
		/**
		 * constructor: empty constructor for the color manipulation object
		 */
		public function color_manipulation() { }
		
		/**
		 * calculates the average color in a BitmapData Object
		 */
		public function averageColor(source:BitmapData):Number {
			var R:Number = 0;
			var G:Number = 0;
			var B:Number = 0;
			var n:Number = 0;
			var p:Number;
			
			for (var x:int=0; x<source.width; x++) {
				for (var y:int=0; y<source.height; y++) {
					p = source.getPixel(x, y);
					
					R += p >> 16 & 0xFF;
					G += p >> 8  & 0xFF;
					B += p       & 0xFF;
					
					n++
				}
			}
			
			R /= n;
			G /= n;
			B /= n;
			
			return R << 16 | G << 8 | B;
		}
		
		/**
		 * extracts the average colors from an image by dividing the source into segments and then finding the average color in each segment
		 */	
		public function averageColors(source:BitmapData, colors:Number):Array {
			var averages:Array = new Array();
			var columns:int = int(Math.sqrt(colors) + .5);
			
			var row:int = 0;
			var col:int = 0;
			
			var x:int = 0;
			var y:int = 0;
			
			var w:int = int((source.width / columns) + .5);
			var h:int = int((source.height / columns) + .5);
			
			for (var i:int=0; i<colors; i++) {
				var rect:Rectangle = new Rectangle(x, y, w, h);
				
				var box:BitmapData = new BitmapData(w, h, false);
				box.copyPixels(source, rect, new Point());
				
				averages.push(averageColor(box));
				box.dispose();
				
				col = i % columns;
				
				x = w * col;
				y = h * row;
				
				if (col == (columns - 1)) {
					row++;
				}
			}
			
			return averages;
		}
		
		/**
		 * checks the specified bitmap to see if the background is valid to remove or not
		 */
		public function backgroundRemoveable(image:BitmapData):Boolean {
			return (!hasTransparency(image, 0xAA000000) && (determineBackgroundColor(image) != -1));
		}
		
		/**
		 * converts the given BitmapData image into a pure black and white image, no gradients
		 */
		public function blackAndWhite(image:BitmapData, lightest_color:Number=250):void {
			for (var y:int=0; y<image.height; y++) {
				for (var x:int=0; x<image.width; x++) {
					image.setPixel(x, y, (((((image.getPixel(x, y) & 0xFF0000) >> 16) < lightest_color) || (((image.getPixel(x, y) & 0x00FF00) >> 8) < lightest_color) || ((image.getPixel(x, y) & 0x0000FF) < lightest_color)) ? 0x000000 : 0xFFFFFF));
				}
			}
		}
		
		/**
		 * compares a given color to a set of colors and evaluates whether or not the color is sufficiently unique
		 */		
		public function colorsDifferent(color:Number, colors:Array, tolerance:Number=0.05):Boolean {
			for (var i:int=0; i<colors.length; i++) {
				if (colorsSimilar(color, colors[i], tolerance)) {
					return false;
				}
			}
			return true;
		}
		
		/**
		 * returns an array of the most common unique colors
		 */	
		public function colorPalette(source:BitmapData, maximum:int=16, tolerance:Number=0.05):Array {
			var copy:BitmapData	= source.clone();
			var palette:Array	= uniqueColors(orderColors(copy, maximum), maximum, tolerance);
			copy.dispose();
			
			return palette.sort();
		}
		
		/**
		 * calculates whether colorA and colorB are similar within a given tolerence
		 */	
		public function colorsSimilar(color1:Number, color2:Number, tolerance:Number=0.05):Boolean {
			var RGB1:Object = hex2rgb(color1);
			var RGB2:Object = hex2rgb(color2);
			
			tolerance = tolerance * (255 * 255 * 3) << 0;
			
			var distance:Number = 0;
			
			distance += ((RGB1.red - RGB2.red) * (RGB1.red - RGB2.red));
			distance += ((RGB1.green - RGB2.green) * (RGB1.green - RGB2.green));
			distance += ((RGB1.blue - RGB2.blue) * (RGB1.blue - RGB2.blue));
			
			return (distance <= tolerance);
		}
		
		/**
		 * using the 4 corners of the image, it attempts to "guess" the background color of the current bitmapData
		 * by checking for similarities between the 4 (needs 3 to be similar to "find" the background)
		 *
		 * note: this method works well with light gradients too (they can't be too dramatic, yet)
		 */
		public function determineBackgroundColor(source:BitmapData):Number {
			var corners:Object = {top_left: 0, top_right: 0, bottom_right: 0, bottom_left: 0};
			// get the "corner" colors, but not the exact corner just incase there is some unseen border issue
			corners.top_left		= source.getPixel(5, 5);
			corners.top_right		= source.getPixel((source.width - 6), 5);
			corners.bottom_right	= source.getPixel((source.width - 6), (source.height - 6));
			corners.bottom_left		= source.getPixel(5, (source.height - 6));
			
			var bg_color:Number;
			
			var count:Number = new Number(0);
			count += colorsSimilar(corners.top_left, corners.top_right, .005)				? 1 : 0;
			count += colorsSimilar(corners.top_left, corners.bottom_right, .005)			? 1 : 0;
			count += colorsSimilar(corners.top_left, corners.bottom_left, .005)			? 1 : 0;
			if (count >= 2) {
				bg_color = corners.top_left;
			} else {
				count += colorsSimilar(corners.top_right, corners.bottom_right, .005)		? 1 : 0;
				count += colorsSimilar(corners.top_right, corners.bottom_left, .005)		? 1 : 0;
				if (count == 2) {
					bg_color = corners.top_right;
				}
			}
			
			return (!isNaN(bg_color)) ? bg_color : -1;
		}
		
		/**
		 * checks the specified image to see if any of it is transparent
		 */		
		public function hasTransparency(image:BitmapData, threshold:Number=0xFF000000):Boolean {
			for (var y:int=0; y<image.height; y++) {
				for (var x:int=0; x<image.width; x++) {
					// check the current pixel (32 bit w/ alpha) against the lowest "non-alpha" color
					if (image.getPixel32(x, y) <= threshold) {
						return true;
					}
				}
			}
			return false;
		}
		
		/**
		 * convert from HEX to RGB and return the 3 values as an object
		 */
		public function hex2rgb(hex:Number):Object {
			return {alpha: (hex >> 24 & 0xFF), red: (hex >> 16 & 0xFF), green: (hex >> 8 & 0xFF), blue: (hex & 0xFF)};
		}
		
		/**
		 * generates an array of objects representing each color present in an image;
		 * each object has a "color" and a "count" property
		 */
		public function indexColors(source:BitmapData, maximum:int=16, sort:Boolean=true, order:Number=Array.DESCENDING):Array {
			reduceColors(source, maximum);
			
			var n:Object = {};
			var a:Array = [];
			var p:int;
			
			for (var x:int=0; x<source.width; x++) {
				for (var y:int=0; y<source.height; y++) {
					p = source.getPixel(x, y);
					n[p] ? n[p]++ : n[p] = 1;
				}
			}
			
			for (var c:String in n) {
				a.push({color:c, count:n[c]});
			}
			
			if (!sort) {
				return a;
			}
			
			// sorting comparison function
			function byCount(a:Object, b:Object):int {
				if (a.count > b.count) return 1;
				if (a.count < b.count) return -1;
				return 0;
			}
			
			return a.sort(byCount, order);
		}

		/**
		 * get the opposite HEX value of the specified color
		 */
		public function opposite(hex:Number, offset:Number=0):int {
			var rgb:Object = hex2rgb(hex);
			
			rgb.red		= 255 - rgb.red;
			rgb.green	= 255 - rgb.green;
			rgb.blue	= 255 - rgb.blue;
			
			if (offset > 0) {
				while (offset > 1) {
					offset /= 10;
				}
				
				rgb.red		= ((rgb.red > 130)	? (rgb.red - (rgb.red * offset))		: (rgb.red + (rgb.red * offset)));
				rgb.green	= (rgb.green > 130)	? (rgb.green - (rgb.green * offset))	: (rgb.green + (rgb.green * offset));
				rgb.blue	= (rgb.blue > 130)	? (rgb.blue - (rgb.blue * offset))		: (rgb.blue + (rgb.blue * offset));
			}
			
			return rgb2dec(rgb.red, rgb.green, rgb.blue);
		}
		
		/**
		 * returns an array of colors ordered by how often they occur in the source image
		 */
		public function orderColors(source:BitmapData, maximum:int=16, order:Number=Array.DESCENDING):Array {
			var colors:Array = new Array();
			var index:Array = indexColors(source, maximum, true, order);
			
			for (var i:int=0; i<index.length; i++) {
				colors.push(index[i].color);
			}
			
			return colors;
		}

		/**
		 * reduces the input BitmapData's color palette
		 */
		public function reduceColors(source:BitmapData, colors:int=16):void {
			var Ra:Array = new Array(256);
			var Ga:Array = new Array(256);
			var Ba:Array = new Array(256);

			var n:Number = 256 / (colors / 3);
			
			for (var i:int=0; i<256; i++) {
				Ba[i] = int(i / n) * n;
				Ga[i] = Ba[i] << 8;
				Ra[i] = Ga[i] << 8;
			}
			
			source.paletteMap(source, source.rect, new Point(), Ra, Ga, Ba);
		}
		
		/**
		 * dynamically remove the "background" color from the specified image
		 */
		public function removeBackgroundColor(source:BitmapData):BitmapData {
			var bg_color:Number = determineBackgroundColor(source);
			
			if (bg_color > -1) {
				var cleaned_source:BitmapData = new BitmapData(source.width, source.height, true);
				var color_array:Array = new Array();
				color_array[0] = bg_color;
				for (var x:int=0; x<source.width; x++) {
					for (var y:int=0; y<source.height; y++) {
						cleaned_source.setPixel32(x, y, ((colorsSimilar(bg_color, source.getPixel(x, y), .005)) ? 0 : source.getPixel32(x, y)));
					}
				}
				return cleaned_source;
			} else {
				return source;
			}
		}
		
		/**
		 * dynamically removes the "background" color on the edges only from the specified image
		 */	
		public function removeEdgeColor(source:BitmapData):BitmapData {
			var bg_color:Number = determineBackgroundColor(source);
			
			if (bg_color > -1) {
				var cleaned_source:BitmapData = new BitmapData(source.width, source.height, true);
				// to allow for transparency, we cannot simply clone(), we need to manually copy each individual pixel =[
				for (var x:int=0; x<source.width; x++) {
					for (var y:int=0; y<source.height; y++) {
						cleaned_source.setPixel32(x, y, source.getPixel32(x, y));
					}
				}
				
				cleaned_source = _edgeFloodBorder(cleaned_source, bg_color);
				_edge_flood_modified = true;
				while (_edge_flood_modified) {
					_edge_flood_modified = false;
					cleaned_source = _edgeFloodStartTopLeft(cleaned_source, bg_color);
					cleaned_source = _edgeFloodStartBottomRight(cleaned_source, bg_color);
				}
				cleaned_source = _edgeFloodCleanEdges(cleaned_source);
				
				return cleaned_source;
			} else {
				return source;
			}
		}
		
		/**
		 * remove the white color from images (technically its "really light" grey to white; to remove pure white, use remove_color)
		 */
		public function removeWhite(source:BitmapData):BitmapData {
			var cleaned_source:BitmapData = new BitmapData(source.width, source.height, true);
			cleaned_source.threshold(source, source.rect, new Point(0,0), ">", 0xFFc0c0c0, 0x00FFFFFF, 0xFFFFFFFF, true);
			return cleaned_source;
		}

		/**
		 * convert from RGB to DECIMAL
		 */
		public function rgb2dec(red:int, green:int, blue:int):int {
			return (red << 16 | green << 8 | blue);
		}

		/**
		 * convert from RGB to HEX and return the actual HEX string, not the standard decimal format
		 *
		 * note: ONLY use this for display purposes...it's much slower than rgb2dec and doesn't provide
		 * any additional benefits
		 */
		public function rgb2hex(red:int, green:int, blue:int):String {
			var _r:String = new String(((red << 16).toString(16)).substring(0, 2));
			var _g:String = new String(((green << 8).toString(16)).substring(0, 2));
			var _b:String = new String((blue.toString(16)).substring(0, 2));
			
			if (_r == '0') _r = '00';
			if (_g == '0') _g = '00';
			if (_b == '0') _b = '00';
			return ('0x'+_r+_g+_b);
		}
		
		/**
		 * returns an array of unique colors up to a given maximum
		 */	
		public function uniqueColors(colors:Array, maximum:int, tolerance:Number=0.05):Array {
			var unique:Array = new Array();;
			
			for (var i:int=0; ((i < colors.length) && (unique.length < maximum)); i++) {
				if (colorsDifferent(colors[i], unique, tolerance)) {
					unique.push(colors[i]);
				}
			}
			
			return unique;
		}
		
		/**
		 * sets up the frame / basis of the edge-flood by removing the specified color in a 1-pixel border around the image
		 */	
		private function _edgeFloodBorder(source:BitmapData, bg_color:Number):BitmapData {
			// process the top and bottom borders
			for (var x:int=0; x<source.width; x++) {
				// top border
				if (colorsSimilar(bg_color, source.getPixel(x, 0), .005)) {
					source.setPixel32(x, 0, 0);
				}
				// bottom border
				if (colorsSimilar(bg_color, source.getPixel(x, (source.height - 1)), .005)) {
					source.setPixel32(x, (source.height - 1), 0);
				}
			}
			
			// process the left and right borders
			for (var y:int=1; y<(source.height - 1); y++) {
				// left
				if (colorsSimilar(bg_color, source.getPixel(0, y), .005)) {
					source.setPixel32(0, y, 0);
				}
				// right
				if (colorsSimilar(bg_color, source.getPixel((source.width - 1), y), .005)) {
					source.setPixel32((source.width - 1), y, 0);
				}
			}
			
			return source;
		}
		
		/**
		 * attempts to reduce jagged-ness caused by the edge-flood by blurring a 1-pixel border around the outside
		 * of the current image by fading the outside pixels by about half
		 */	
		private function _edgeFloodCleanEdges(source:BitmapData):BitmapData {
			for (var x:int=0; x<source.width; x++) {
				for (var y:int=0; y<source.height; y++) {
					if (!_edgeFloodMarked(source, x, y, 0x44000000) && (_edgeFloodMarked(source, x, (y - 1), 0x44000000) || _edgeFloodMarked(source, (x - 1), y, 0x44000000) || _edgeFloodMarked(source, x, (y + 1), 0x44000000) || _edgeFloodMarked(source, (x + 1), y, 0x44000000))) {
						source.setPixel32(x, y, (source.getPixel32(x, y) - 0x88000000));
					}
				}
			}
			
			return source;
		}
		
		/**
		 * gets the next x-coordinate to begin flooding from left -> right
		 */	
		private function _edgeFloodGetNextX(source:BitmapData, bg_color:Number, x:int, y:int):int {
			for (x; x<source.width; x++) {
				if (colorsSimilar(bg_color, source.getPixel32(x, y), .005) && (_edgeFloodMarked(source, x, (y - 1)) || _edgeFloodMarked(source, (x - 1), y) || _edgeFloodMarked(source, x, (y + 1)) || _edgeFloodMarked(source, (x + 1), y))) {
					// the current pixel is touching a marked pixel, it is touching an edge!
					break;
				}
			}
			
			return x;
		}
		
		/**
		 * gets the next x-coordinate to begin flooding from right -> left
		 */	
		private function _edgeFloodGetNextXReverse(source:BitmapData, bg_color:Number, x:int, y:int):int {
			for (x; x>0; x--) {
				if (!_edgeFloodMarked(source, x, y) && colorsSimilar(bg_color, source.getPixel32(x, y), .005) && (_edgeFloodMarked(source, x, (y - 1)) || _edgeFloodMarked(source, (x - 1), y) || _edgeFloodMarked(source, x, (y + 1)) || _edgeFloodMarked(source, (x + 1), y))) {
					// the current pixel is touching a marked pixel, it is touching an edge!
					break;
				}
			}
			
			return x;
		}
		
		/**
		 * floods the specified line from left -> right by removing any pixel that matches the specified color
		 */	
		private function _edgeFloodLinear(source:BitmapData, bg_color:Number, x:int, y:int):BitmapData {
			while ((x < source.width) && colorsSimilar(bg_color, source.getPixel(x, y), .005)) {
				source.setPixel32(x, y, 0);
				x++;
				_edge_flood_modified = true;
			}
			
			return source;
		}
		
		/**
		 * floods the specified line from right -> left by removing any pixel that matches the specified color
		 */	
		private function _edgeFloodLinearReverse(source:BitmapData, bg_color:Number, x:int, y:int):BitmapData {
			while ((x > 0) && colorsSimilar(bg_color, source.getPixel(x, y), .005)) {
				source.setPixel32(x, y, 0);
				x--;
				_edge_flood_modified = true;
			}
			
			return source;
		}
		
		/**
		 * checks if the specified pixel has been removed/marked based on the specified alpha threshold
		 */	
		private function _edgeFloodMarked(source:BitmapData, x:int, y:int, threshold:Number=0xAA000000):Boolean {
			return (source.getPixel32(x, y) <= threshold);
		}
		
		/**
		 * begins the flood scan from the bottom right -> top left
		 */	
		private function _edgeFloodStartBottomRight(source:BitmapData, bg_color:Number):BitmapData {
			var x:int		= new int(source.width - 2);
			var y:int		= new int(source.height - 2);
			
			while (y >= 0) {
				x = _edgeFloodGetNextXReverse(source, bg_color, x, y);
				// check if the coordinate is within the bounds or not
				if (x <= 0) {
					x = (source.width - 2);
					y--;
					if (y <= 0) break;
					continue;
				}
				// flood the current line
				source = _edgeFloodLinearReverse(source, bg_color, x, y);
			}
			
			return source;
		}
		
		/**
		 * begins the flood scan from the top left -> bottom right
		 */	
		private function _edgeFloodStartTopLeft(source:BitmapData, bg_color:Number):BitmapData {
			var x:int		= new int(0);
			var y:int		= new int(1);
			
			while (y < source.height) {
				x = _edgeFloodGetNextX(source, bg_color, x, y);
				// check if the coordinate is within the bounds or not
				if (x >= source.width) {
					x = 0;
					y++;
					if (y >= source.height) break;
					continue;
				}
				// flood the current line
				source = _edgeFloodLinear(source, bg_color, x, y);
			}
			
			return source;
		}
	}
}