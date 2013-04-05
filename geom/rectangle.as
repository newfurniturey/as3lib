/**
 * Handles the creation of dynamic rectangles, both as objects and drawn elements.
 *
 * @deprecated In favor of simple_rectangle.
 *
 * Usage {{{
 *    var rect:rectangle = new rectangle(myClip, 0, 0, 550, 450, 0x000000, false, 2, 0x990000, 15);
 *    rect.draw();
 * }}}
 */

package classes.geom {
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class rectangle extends Sprite {
		// Global vars
		private var _bg_color:Number						= new Number(0x000000);
		private var _bg_gradient:Boolean					= new Boolean(false);
		private var _bg_transparent:Boolean					= new Boolean(false);
		private var _border_color:Number					= new Number(0x000000);
		private var _border_width:Number					= new Number(0);
		private var _corner_roundness:Number				= new Number(0);
		private var _display_hook:Boolean					= new Boolean(false);
		private var _gradient_alphas:Array					= new Array(1, 1);
		private var _gradient_angle:Number					= new Number(90);
		private var _gradient_colors:Array					= new Array(0xEEEEEE, 0xBCBCBC);
		private var _gradient_focalPointRatio:Number		= new Number(.80);
		private var _gradient_interpolationMethod:String	= new String(InterpolationMethod.RGB);
		private var _gradient_ratios:Array					= new Array(100, 255);
		private var _gradient_spreadMethod:String			= new String(SpreadMethod.PAD);
		private var _gradient_type:String					= new String(GradientType.LINEAR);
		private var _hook_direction:String					= new String("bottom-left");
		private var _hook_offset:Number						= new Number(0);
		private var _hook_size:Number						= new Number(0);
		private var _rObj:Rectangle							= null;
		private var _sObj:Shape								= null;
		private var _stage:Object							= null;
		private var _stage_sprite:DisplayObject				= null;
		
		/**
		 * constructor: sets up the initial rectangle object and stores all of the default values/attributes
		 */
		public function rectangle(stage=null, sX:Number=0, sY:Number=0, sWidth:Number=0, sHeight:Number=0, color:Number=0, transparent:Boolean=false, border_width:Number=1, border_color:Number=0, roundness:Number=0):void {
			if ((stage == null)) {
				// normally used when converting a Sprite into a rectangle type
				return;
			}
		
			_stage					= stage;
			_rObj					= new Rectangle(sX, sY, sWidth, sHeight);
			_bg_color				= color;
			_bg_transparent			= transparent;
			_border_width			= border_width;
			_border_color			= border_color;
			_corner_roundness		= roundness;
		}
		
		/**
		 * returns the alpha of the current rectangle
		 */
		public override function get alpha():Number {
			return (_stage_sprite != null) ? _stage_sprite.alpha : 0;
		}
		
		/**
		 * sets the alpha of the current rectangle
		 */
		public override function set alpha(value:Number):void {
			if (_stage_sprite != null) {
				_stage_sprite.alpha = value;
			}
		}
		
		/**
		 * gets the color of the current rectangle
		 */
		public function get color():Number {
			return _bg_color;
		}
		
		/**
		 * sets the color of the current rectangle
		 */
		public function set color(value:Number):void {
			_bg_color = value;
			if (_stage_sprite != null) {
				_stage.removeChild(_stage_sprite);
				draw();
			}
		}
		
		/**
		 * get the color of the current rectangle's border
		 */
		public function get color_border():Number {
			return _border_color;
		}
		
		/**
		 * sets the color of the current rectangle
		 */
		public function set color_border(value:Number):void {
			_border_color = value;
			if (_stage_sprite != null) {
				_stage.removeChild(_stage_sprite);
				draw();
			}
		}
		
		public function convert(obj:Sprite):void {
			_stage_sprite = obj;
			_sObj = Object(_stage_sprite).getChildAt(0);
		}
		
		/**
		 * draws the current rectangle to the stage
		 */
		public function draw():void {
			var rectShape:Shape	= new Shape();
			var rectSprite:Sprite	= new Sprite();
			
			if (!_bg_transparent && _bg_gradient) {
				// the background color isn't transparent, and it's a gradient, begin fillin it in
				var gradient_matrix:Matrix = new Matrix();
				gradient_matrix.createGradientBox(((_rObj != null) ? _rObj.width : _sObj.width), ((_rObj != null) ? _rObj.height : _sObj.height), (_gradient_angle * Math.PI / 180), 0, 0);
				rectShape.graphics.beginGradientFill(_gradient_type, _gradient_colors, _gradient_alphas, _gradient_ratios, gradient_matrix, _gradient_spreadMethod, _gradient_interpolationMethod, _gradient_focalPointRatio);
			} else if (!_bg_transparent) {
				// the background color isn't transparent so begin filling it in
				rectShape.graphics.beginFill(_bg_color);
			}
			
			if (_border_width > 0) {
				// there is a border line, draws it
				rectShape.graphics.lineStyle(_border_width, _border_color);
			}
			
			// create the actual rectangle (with or without rounded corners)
			if (_display_hook) {
				_draw_hook(rectShape);
			} else {
				if (_corner_roundness > 0) {
					rectShape.graphics.drawRoundRect(((_rObj != null) ? _rObj.x : _sObj.x), ((_rObj != null) ? _rObj.y : _sObj.y), ((_rObj != null) ? _rObj.width : _sObj.width), ((_rObj != null) ? _rObj.height : _sObj.height), _corner_roundness);
				} else {
					rectShape.graphics.drawRect(((_rObj != null) ? _rObj.x : _sObj.x), ((_rObj != null) ? _rObj.y : _sObj.y), ((_rObj != null) ? _rObj.width : _sObj.width), ((_rObj != null) ? _rObj.height : _sObj.height));
				}
			}
			
			if (!_bg_transparent) {
				// end the background fill
				rectShape.graphics.endFill();
			}
			
			// allow mouse clicks overtop of the rectangle
			rectSprite.mouseEnabled = false;
			rectSprite.mouseChildren = false;
			
			// add the new rectangle to the stage
			rectSprite.addChild(rectShape);  
			_stage_sprite = _stage.addChildAt(rectSprite, _stage.numChildren);
		}
		
		/**
		 * returns whether or not we are using a gradient as a background color
		 */
		public function get gradient():Boolean {
			return _bg_gradient;
		}
		
		/**
		 * sets whether or not to use a gradient as a background color
		 */
		public function set gradient(value:Boolean) {
			_bg_gradient = value;
			
			_gradient_changed();
		}
		
		/**
		 * returns the alpha settings for the current gradient
		 */
		public function get gradient_alphas():Array {
			return _gradient_alphas;
		}
		
		/**
		 * sets the alpha settings for the current gradient
		 */
		public function set gradient_alphas(value:Array):void {
			_gradient_alphas = value;
			
			_gradient_changed();
		}
		
		/**
		 * returns the angle of the current gradient
		 */
		public function get gradient_angle():Number {
			return _gradient_angle;
		}
		
		/**
		 * sets the angle of the current gradient
		 */
		public function set gradient_angle(value:Number):void {
			_gradient_angle = value;
			
			_gradient_changed();
		}
		
		/**
		 * returns the current color settings of the gradient
		 */
		public function get gradient_colors():Array {
			return _gradient_colors;
		}
		
		/**
		 * sets the color settings of the current gradient
		 */
		public function set gradient_colors(value:Array):void {
			_gradient_colors = value;
			
			_gradient_changed();
		}
		
		/**
		 * returns the current focal point of the gradient
		 */
		public function get gradient_focalPointRatio():Number {
			return _gradient_focalPointRatio;
		}
		
		/**
		 * sets the current focal point of the gradient
		 */
		public function set gradient_focalPointRatio(value:Number):void {
			_gradient_focalPointRatio = value;
			
			_gradient_changed();
		}
		
		/**
		 * returns the current gradients interpolation method
		 */
		public function get gradient_interpolationMethod():String {
			return _gradient_interpolationMethod;
		}
		
		/**
		 * sets the current gradients interpolation method
		 */
		public function set gradient_interpolationMethod(value:String):void {
			_gradient_interpolationMethod = value;
			
			_gradient_changed();
		}
		
		/**
		 * returns the current gradients ratio settings
		 */
		public function get gradient_ratios():Array {
			return _gradient_ratios;
		}
		
		/**
		 * sets the current gradients ratio settings
		 */
		public function set gradient_ratios(value:Array):void {
			_gradient_ratios = value;
			
			_gradient_changed();
		}
		
		/**
		 * returns the current spread method of the gradient
		 */
		public function get gradient_spreadMethod():String {
			return _gradient_spreadMethod;
		}
		
		/**
		 * sets the current spread method of the gradient
		 */
		public function set gradient_spreadMethod(value:String):void {
			_gradient_spreadMethod = value;
			
			_gradient_changed();
		}
		
		/**
		 * returns the type of the current gradient
		 */
		public function get gradient_type():String {
			return _gradient_type;
		}
		
		/**
		 * sets the current gradient type
		 */
		public function set gradient_type(value:String):void {
			_gradient_type = value;
			
			_gradient_changed();
		}
		
		/**
		 * returns the height of the current rectangle
		 */
		public override function get height():Number {
			return (_rObj != null) ? _rObj.height : ((_sObj != null) ? _sObj.height : 0);
		}
		
		/**
		 * sets the y of the current rectangle
		 */
		public override function set height(value:Number):void {
			if (_rObj != null) {
				_rObj.height			= value;
			} else if (_sObj != null) {
				_sObj.height			= value;
			}
			if (_stage_sprite != null) {
				_stage_sprite.height	= value;
			}
		}
		
		/**
		 * returns the true/false value of whether or not the hook should display
		 */
		public function get hook():Boolean {
			return _display_hook;
		}
		
		/**
		 * sets the value of whether or not a hook should be displayed on the rectangle or not
		 */
		public function set hook(value:Boolean):void {
			_display_hook = value;
			
			_hook_changed();
		}
		
		public function get hook_direction():String {
			return _hook_direction;
		}
		
		public function set hook_direction(value:String):void {
			_hook_direction = value;
			
			_hook_changed();
		}
		
		/**
		 * returns the size of the hook
		 */
		public function get hook_size():Number {
			return _hook_size;
		}
		
		/**
		 * sets the size of the hook
		 */
		public function set hook_size(value:Number):void {
			_hook_size = value;
			
			_hook_changed();
		}
		
		/**
		 * returns the offset of the hook
		 */
		public function get hook_offset():Number {
			return _hook_offset;
		}
		
		/**
		 * sets the offset of the hook
		 */
		public function set hook_offset(value:Number):void {
			_hook_offset = value;
			
			_hook_changed();
		}
		
		/**
		 * moves the rectangle to the new location
		 */
		public function move(sX:Number, sY:Number):void {
			if (_rObj != null) {
				_rObj.x			= sX;
				_rObj.y			= sY;
			} else if (_sObj != null) {
				_sObj.x			= sX;
				_sObj.y			= sY;
			}
			if (_stage_sprite != null) {
				_stage_sprite.x	= sX;
				_stage_sprite.y	= sY;
			}
		}
		
		/**
		 * returns the current rectangle object
		 */
		public function get rect():Rectangle {
			return (_rObj != null) ? _rObj : null;
		}
		
		/**
		 * removes the rectangle from the stage
		 */
		public function remove():void {
			if (_stage_sprite != null) {
				_stage_sprite.alpha = 0;
				_stage.removeChild(_stage_sprite);
				_stage_sprite = null;
			}
			_rObj = null;
			_sObj = null;
		}
		
		/**
		 * resizes the rectangle to the new dimensions
		 */
		public function resize(sWidth:Number, sHeight:Number):void {
			if (_rObj != null) {
				_rObj.width			= sWidth;
				_rObj.height			= sHeight;
			} else if (_sObj != null) {
				_sObj.width			= sWidth;
				_sObj.height			= sHeight;
			}
			if (_stage_sprite != null) {
				_stage_sprite.width	= sWidth;
				_stage_sprite.height	= sHeight;
			}
		}
		
		/**
		 * returns the width of the current rectangle
		 */
		public override function get width():Number {
			return (_rObj != null) ? _rObj.width : ((_sObj != null) ? _sObj.width : 0);
		}
		
		/**
		 * sets the y of the current rectangle
		 */
		public override function set width(value:Number):void {
			if (_rObj != null) {
				_rObj.width			= value;
			} else if (_sObj != null) {
				_sObj.width			= value;
			}
			if (_stage_sprite != null) {
				_stage_sprite.width	= value;
			}
		}
		
		/**
		 * returns the x of the current rectangle
		 */
		public override function get x():Number {
			return (_rObj != null) ? _rObj.x : ((_sObj != null) ? _sObj.x : 0);
		}
		
		/**
		 * sets the y of the current rectangle
		 */
		public override function set x(value:Number):void {
			if (_rObj != null) {
				_rObj.x			= value;
			} else if (_sObj != null) {
				_sObj.x			= value;
			}
			if (_stage_sprite != null) {
				_stage_sprite.x	= value;
			}
		}
		
		/**
		 * returns the y of the current rectangle
		 */
		public override function get y():Number {
			return (_rObj != null) ? _rObj.y : ((_sObj != null) ? _sObj.y : 0);
		}
		
		/**
		 * sets the y of the current rectangle
		 */
		public override function set y(value:Number):void {
			if (_rObj != null) {
				_rObj.y			= value;
			} else if (_sObj != null) {
				_sObj.y			= value;
			}
			if (_stage_sprite != null) {
				_stage_sprite.y	= value;
			}
		}
		
		/**
		 * draws the current rectangle to the stage with a hook using sprites/lines instead of the drawRect method
		 */
		private function _draw_hook(rectShape:Shape):void {
			var width:Number	= ((_rObj != null) ? _rObj.width : _sObj.width);
			var height:Number	= ((_rObj != null) ? _rObj.height : _sObj.height);
			
			if (_hook_direction == "top-left") {
				// start the line at the end of the "top left" corner
				rectShape.graphics.moveTo((_hook_offset + _corner_roundness), 0);
				
				// draw the left-side of the hook
				rectShape.graphics.lineTo((_hook_offset + _corner_roundness), -(_hook_size));
				// draw the right-side of the hook
				rectShape.graphics.lineTo((_hook_offset + _hook_size + _corner_roundness), 0);
			} else {			
				// start the line at the end of the "top left" corner {x: (0+corner_roundness), y: 0}
				rectShape.graphics.moveTo(_corner_roundness, 0);
				
				// draw the line to the "top right" corner, leaving room for the round corner
				rectShape.graphics.lineTo(((_hook_direction == "top-center") ? ((width / 2) - (_hook_size / 2)) : ((_hook_direction == "top-right") ? (width - (_hook_offset + _hook_size + _corner_roundness)) : (width - _corner_roundness))), 0);
				
				if (_hook_direction == "top-center") {
					// draw the left-side of the hook
					rectShape.graphics.lineTo((width / 2), -(_hook_size));
					// draw the right-side of the hook
					rectShape.graphics.lineTo(((width / 2) + (_hook_size / 2)), 0);
				} else if (_hook_direction == "top-right") {
					// draw the left-side of the hook
					rectShape.graphics.lineTo((width - (_hook_offset + _corner_roundness)), -(_hook_size));
					// draw the right-side of the hook
					rectShape.graphics.lineTo((width - (_hook_offset + _corner_roundness)), 0);
				}
			}
			
			// draw the top-right corner
			rectShape.graphics.lineTo((width - _corner_roundness), 0);
			rectShape.graphics.curveTo(width, 0, width, _corner_roundness);
			
			if (_hook_direction == "right-top") {
				// draw the right side down to the hook offset
				rectShape.graphics.lineTo(width, (_hook_offset + _corner_roundness));
				
				// draw the top-side of the hook
				rectShape.graphics.lineTo((width + _hook_size), (_hook_offset + _corner_roundness));
				// draw the bottom-side of the hook
				rectShape.graphics.lineTo(width, (_hook_offset + _hook_size + _corner_roundness));
			} else {
				// draw the line to the "bottom right" corner, leaving room for the round corner
				rectShape.graphics.lineTo(width, ((_hook_direction == "right-center") ? ((height / 2) - (_hook_size / 2)) : ((_hook_direction == "right-bottom") ? (height - (_hook_offset + _hook_size + _corner_roundness)) : (height - _corner_roundness))));
				
				if (_hook_direction == "right-center") {
					// draw the top-side of the hook
					rectShape.graphics.lineTo((width + _hook_size), (height / 2));
					// draw the bottom-side of the hook
					rectShape.graphics.lineTo(width, ((height / 2) + (_hook_size / 2)));
				} else if (_hook_direction == "right-bottom") {
					// draw the top-side of the hook
					rectShape.graphics.lineTo((width + _hook_size), (height - (_hook_offset + _corner_roundness)));
					// draw the bottom-side of the hook
					rectShape.graphics.lineTo(width, (height - (_hook_offset + _corner_roundness)));
				}
			}
			
			// draw the "bottom right" corner
			rectShape.graphics.lineTo(width, (height - _corner_roundness));
			rectShape.graphics.curveTo(width, height, (width - _corner_roundness), height);
			
			if (_hook_direction == "bottom-right") {
				// draw the line to the hook offset
				rectShape.graphics.lineTo((width - (_hook_offset + _corner_roundness)), height);
				// draw the right-side of the hook
				rectShape.graphics.lineTo((width - (_hook_offset + _corner_roundness)), (height + _hook_size));
				// draw the left-side of the hook
				rectShape.graphics.lineTo((width - (_hook_offset + _hook_size + _corner_roundness)), height);
			} else {
				// draw the line to the "bottom left" corner, leaving room for the round corner
				rectShape.graphics.lineTo(((_hook_direction == "bottom-center") ? ((width / 2) + (_hook_size / 2)) : ((_hook_direction == "bottom-left") ? (_hook_offset + _hook_size + _corner_roundness) : _corner_roundness)), height);
				
				if (_hook_direction == "bottom-center") {
					// draw the right-side of the hook
					rectShape.graphics.lineTo((width / 2), (height + _hook_size));
					// drawt he left-side of the hook
					rectShape.graphics.lineTo(((width / 2) - (_hook_size / 2)), height);
				} else if (_hook_direction == "bottom-left") {
					// draw the right-side of the hook
					rectShape.graphics.lineTo((_hook_offset + _corner_roundness), (height + _hook_size));
					// draw the left-side of the hook
					rectShape.graphics.lineTo((_hook_offset + _corner_roundness), height);
				}
			}
			
			// draw the "bottom left" corner
			rectShape.graphics.lineTo(_corner_roundness, height);
			rectShape.graphics.curveTo(0, height, 0, (height - _corner_roundness));
			
			if (_hook_direction == "left-bottom") {
				// draw the left side up to the hook offset
				rectShape.graphics.lineTo(0, (height - (_hook_offset + _corner_roundness)));
				
				// draw the bottom-side of the hook
				rectShape.graphics.lineTo(-(_hook_size), (height - (_hook_offset + _corner_roundness)));
				// draw the top-side of the hook
				rectShape.graphics.lineTo(0, (height - (_hook_offset + _hook_size + _corner_roundness)));
			} else {
				// draw the line up to the "top left" corner, leaving room for the round corner
				rectShape.graphics.lineTo(0, ((_hook_direction == "left-center") ? ((height / 2) + (_hook_size / 2)) : ((_hook_direction == "left-top") ? (_hook_offset + _hook_size + _corner_roundness) : (_corner_roundness))));
				
				if (_hook_direction == "left-center") {
					// draw the bottom-side of the hook
					rectShape.graphics.lineTo(-(_hook_size), (height / 2));
					// draw the top-side of the hook
					rectShape.graphics.lineTo(0, ((height / 2) - (_hook_size / 2)));
				} else if (_hook_direction == "left-top") {
					// draw the bottom-side of the hook
					rectShape.graphics.lineTo(-(_hook_size), (_hook_offset + _corner_roundness));
					// draw the top-side of the hook
					rectShape.graphics.lineTo(0, (_hook_offset + _corner_roundness));
				}
			}
			
			
			// draw the line back up to the "top left" corner, leaving room for the round corner
			rectShape.graphics.lineTo(0, _corner_roundness);
			rectShape.graphics.curveTo(0, 0, _corner_roundness, 0);
			
			rectShape.graphics.endFill();
		}
		
		/**
		 * a gradient display value has changed, redraw the rectangle if it has already been drawn, and the gradient settings are valid
		 */
		private function _gradient_changed():void {
			if ((_stage_sprite != null) && (!_bg_gradient || (_bg_gradient && (_gradient_alphas.length == _gradient_colors.length) && (_gradient_alphas.length == _gradient_ratios.length)))) {
				_stage.removeChild(_stage_sprite);
				draw();
			}
		}
		
		/**
		 * a hook display value has changed, redraw the rectangle if it has already been drawn
		 */
		private function _hook_changed():void {
			if ((_stage_sprite != null) && (!_display_hook || (_hook_size > 0))) {
				_stage.removeChild(_stage_sprite);
				draw();
			}
		}
	}
}