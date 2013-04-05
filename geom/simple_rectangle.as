/**
 * Creates a simple rectanlge sprite that is quick and straight to the point!
 *
 * Usage {{{
 *    var rect:Sprite = new simple_rectangle(100, 100, 0x000000, 1, 0x006699);
 * }}}
 */

package classes.geom {
	import flash.display.Sprite;
	
	public class simple_rectangle extends Sprite {
		// Global vars
		private var _bgAlpha:Number					= 1.0;								// background alpha
		private var _bgColor:Number					= 0x000000;							// background color
		private var _borderColor:Number				= 0x000000;							// border color
		private var _borderRoundness:Number			= 0;								// border roundness
		private var _borderWidth:Number				= 1;								// border width
		private var _height:Number					= 0;								// height of the rectangle
		private var _rect:Sprite					= null;								// current rectangle sprite
		private var _width:Number					= 0;								// width of the rectangle
		
		/**
		 * constructor: draws the simple rectangle
		 */
		public function simple_rectangle(width:Number, height:Number, color:Number=0x000000, border_width:Number=1, border_color:Number=0x000000, roundness:Number=0):void {
			_width				= width;
			_height				= height;
			_bgColor			= color;
			_borderWidth		= border_width;
			_borderColor		= border_color;
			_borderRoundness	= roundness;
			_draw();
		}
		
		/**
		 * returns/sets the background alpha
		 */
		public function get bgAlpha():Number {
			return _bgAlpha;
		}
		public function set bgAlpha(value:Number):void {
			_bgAlpha = ((value >= 0) && (value <= 1)) ? value : _bgAlpha;
			_draw();
		}
		
		/**
		 * returns/sets the rectangle bgColor
		 */
		public function get bgColor():Number {
			return _bgColor;
		}
		public function set bgColor(value:Number):void {
			_bgColor = value;
			_draw();
		}
		
		/**
		 * returns/sets the rectangle borderColor
		 */
		public function get borderColor():Number {
			return _borderColor;
		}
		public function set borderColor(value:Number):void {
			_borderColor = value;
			_draw();
		}
		
		/**
		 * returns/sets the rectangle borderRoundness
		 */
		public function get borderRoundness():Number {
			return _borderRoundness;
		}
		public function set borderRoundness(value:Number):void {
			_borderRoundness = value;
			_draw();
		}
		
		/**
		 * returns/sets the rectangle borderWidth
		 */
		public function get borderWidth():Number {
			return _borderWidth;
		}
		public function set borderWidth(value:Number):void {
			_borderWidth = value;
			_draw();
		}
		
		/**
		 * returns/sets the rectangle height
		 */
		public override function get height():Number {
			return _height;
		}
		public override function set height(value:Number):void {
			_height = value;
			_draw();
		}
		
		/**
		 * returns/sets the rectangle width
		 */
		public override function get width():Number {
			return _width;
		}
		public override function set width(value:Number):void {
			_width = value;
			_draw();
		}
		
		/**
		 * using all configured settings, we draw the rectangle!
		 */
		private function _draw():void {
			var rect:Sprite = new Sprite();
			if (_borderWidth > 0) rect.graphics.lineStyle(_borderWidth, _borderColor);
			rect.graphics.beginFill(_bgColor, _bgAlpha);
			(_borderRoundness > 0) ? rect.graphics.drawRoundRect(0, 0, _width, _height, _borderRoundness) : rect.graphics.drawRect(0, 0, _width, _height);
			rect.graphics.endFill();
			
			// remove the current rectangle and add the new one
			if (_rect != null) removeChild(_rect);
			_rect = rect;
			addChild(_rect);
		}
	}
}