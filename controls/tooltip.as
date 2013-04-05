/**
 * Creates a dynamic tooltip and attaches it to an object.
 *
 * Usage: {{{
 *    tooltip("This is a test tooltip!", object_mc, stage);
 * }}}
 */

package classes.controls {
	import classes.text.text;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import fl.transitions.easing.Regular;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	
	public class tooltip {
		// Global vars
		private var _bold:Boolean							= new Boolean(false);							// flag to indicate if the text is bold or not
		private var _bgColor:Number							= new Number(0xe6d06c);							// solid background color
		private var _bgGradient:Boolean						= new Boolean(true);							// flag to indicate if the background is a solid color or a gradient
		private var _borderColor:Number						= new Number(0xbcbcbc);							// border's color
		private var _borderRound:Number						= new Number(5);								// the roundess of the border's corners
		private var _borderWidth:Number						= new Number(1);								// border's width
		private var _color:Number							= new Number(0x000000);							// font color
		private var _gradientAlphas:Array					= new Array(1, 1);								// the gradient's color alphas
		private var _gradientAngle:Number					= new Number(90);								// the gradient's angle
		private var _gradientColors:Array					= new Array(0xEEEEEE, 0xBCBCBC);				// the gradient's colors
		private var _gradientFocalPointRatio:Number			= new Number(.80);								// the ratio of the gradient's focal point
		private var _gradientInterpolationMethod:String		= new String(InterpolationMethod.RGB);			// the gradient's interpolation method
		private var _gradientRatios:Array					= new Array(100, 255);							// the gradient's color ratios
		private var _gradientSpreadMethod:String			= new String(SpreadMethod.PAD);					// the gradient's spread method
		private var _gradientType:String					= new String(GradientType.LINEAR);				// the gradient type
		private var _hookOffset:Number						= new Number(10);								// offset of the hook
		private var _hookSize:Number						= new Number(15);								// size of the hook
		private var _maxWidth:Number						= new Number(300);								// the maximum width allowed
		private var _padding:Number							= new Number(5);								// inner padding of the tooltip
		private var _size:Number							= new Number(15);								// size of the font
		private var _speed:Number							= new Number(2000);								// speed that the tooltip displays
		private var _directionHorizontal:String				= new String("right");							// current horizontal direction
		private var _directionVertical:String				= new String("up");								// current vertical direction
		private var _obj:Object								= null;											// clip to "attach" to
		private static var _stage:Object					= null;											// stage object
		private var _text:text								= null;											// global text object
		private var _timer:Timer							= new Timer(2000, 1);							// global timer object
		private var _tooltip:MovieClip						= new MovieClip();								// movieclip to store the tooltip in
		private var _uniqueName:String						= new String();									// unique generated name based on the time the tooltip was created
				
		/**
		 * constructor: sets up the base tooltip
		 */
		public function tooltip(string:String, obj:Object, stage:Object):void {
			if ((obj == null) || (stage == null)) {
				trace("[tooltip] Cannot create tooltip. Required objects not specified.");
				return;
			}
			_uniqueName = "tooltip_"+getTimer();
			_obj = obj;
			if (_stage == null) _stage = stage;
			_createTooltip(string);
			_createListeners();
			_obj.addEventListener(Event.REMOVED_FROM_STAGE, _destroy, false);
		}
		
		/**
		 * gets/sets the standard (solid) background color of the tooltip
		 */
		public function get bgColor():Number {
			return _bgColor;
		}
		public function set bgColor(value:Number):void {
			_bgColor = value;
			_gradientChanged();
		}
		
		/**
		 * gets/sets the true/false value of the font-weight being bold
		 */
		public function get bold():Boolean {
			return _bold;
		}
		public function set bold(value:Boolean):void {
			_bold = value;
			if (_text != null) {
				_text.bold = value;
				_gradientChanged();
			}
		}
		
		/**
		 * gets/sets the border color of the tooltip
		 */
		public function get borderColor():Number {
			return _borderColor;
		}
		public function set borderColor(value:Number):void {
			_borderColor = value;
			_gradientChanged();
		}

		/**
		 * gets/sets the roundness of the tooltip's corners
		 */
		public function get borderRoundness():Number {
			return _borderRound;
		}
		public function set borderRoundness(value:Number) {
			_borderRound = value;
			_gradientChanged();
		}

		/**
		 * gets/sets the border thickness
		 */
		public function get borderWidth():Number {
			return _borderWidth;
		}
		public function set borderWidth(value:Number):void {
			_borderWidth = value;
			_gradientChanged();
		}
		
		/**
		 * gets/sets the font color
		 */
		public function get color():Number {
			return _color;
		}
		public function set color(value:Number):void {
			_color = value;
			if (_text != null) {
				_text.color = value;
				_gradientChanged();
			}
		}
		
		/**
		 * gets/sets whether or not we are using a gradient as a background color
		 */
		public function get gradient():Boolean {
			return _bgGradient;
		}
		public function set gradient(value:Boolean) {
			_bgGradient = value;
			_gradientChanged();
		}
		
		/**
		 * gets/sets the alpha settings for the current gradient
		 */
		public function get gradientAlphas():Array {
			return _gradientAlphas;
		}
		public function set gradientAlphas(value:Array):void {
			_gradientAlphas = value;
			_gradientChanged();
		}
		
		/**
		 * gets/sets the angle of the current gradient
		 */
		public function get gradientAngle():Number {
			return _gradientAngle;
		}
		public function set gradientAngle(value:Number):void {
			_gradientAngle = value;
			_gradientChanged();
		}
		
		/**
		 * gets/sets the current color settings of the gradient
		 */
		public function get gradientColors():Array {
			return _gradientColors;
		}
		public function set gradientColors(value:Array):void {
			_gradientColors = value;
			_gradientChanged();
		}
		
		/**
		 * gets/sets the current focal point of the gradient
		 */
		public function get gradientFocalPointRatio():Number {
			return _gradientFocalPointRatio;
		}
		public function set gradientFocalPointRatio(value:Number):void {
			_gradientFocalPointRatio = value;
			_gradientChanged();
		}
		
		/**
		 * gets/sets the current gradients interpolation method
		 */
		public function get gradientInterpolationMethod():String {
			return _gradientInterpolationMethod;
		}
		public function set gradientInterpolationMethod(value:String):void {
			_gradientInterpolationMethod = value;
			_gradientChanged();
		}
		
		/**
		 * gets/sets the current gradients ratio settings
		 */
		public function get gradientRatios():Array {
			return _gradientRatios;
		}
		public function set gradientRatios(value:Array):void {
			_gradientRatios = value;
			_gradientChanged();
		}
		
		/**
		 * gets/sets the current spread method of the gradient
		 */
		public function get gradientSpreadMethod():String {
			return _gradientSpreadMethod;
		}
		public function set gradientSpreadMethod(value:String):void {
			_gradientSpreadMethod = value;
			_gradientChanged();
		}
		
		/**
		 * gets/sets the type of the current gradient
		 */
		public function get gradientType():String {
			return _gradientType;
		}
		public function set gradientType(value:String):void {
			_gradientType = value;
			_gradientChanged();
		}
		
		/**
		 * gets/sets the size of the hook
		 */
		public function get hookSize():Number {
			return _hookSize;
		}
		public function set hookSize(value:Number):void {
			_hookSize = value;
		}
		
		/**
		 * gets/sets the offset of the hook
		 */
		public function get hookOffset():Number {
			return _hookOffset;
		}
		public function set hookOffset(value:Number):void {
			_hookOffset = value;
		}
		
		/**
		 * gets/sets the maximum width of the tooltip
		 */
		public function get maxWidth():Number {
			return _maxWidth;
		}
		public function set maxWidth(value:Number):void {
			_maxWidth = value;
			if ((_text != null) && (_text.width > _maxWidth)) _text.width = _maxWidth;
			_gradientChanged();
		}
		
		/**
		 * gets/sets the text-padding of the tooltip
		 */
		public function get padding():Number {
			return _padding;
		}
		public function set padding(value:Number):void {
			_padding = value;
			_gradientChanged();
		}

		/**
		 * gets/sets the font size
		 */
		public function get size():Number {
			return _size;
		}
		public function set size(value:Number):void {
			_size = value;
			if (_text != null) {
				_text.size = value;
				_gradientChanged();
			}
		}

		/**
		 * gets/sets the timer's speed
		 */
		public function get speed():Number {
			return (_speed / 1000);
		}
		public function set speed(value:Number):void {
			_removeListeners();
			_speed = (value * 1000);
			if (_timer.running) {
				_timer.stop();
				_timer.reset();
			}
			_timer = new Timer(_speed, 1);
			_createListeners();
		}
		
		/**
		 * sets up the listener for the mouse events to display the tooltip
		 */
		private function _createListeners():void {
			_obj.addEventListener(MouseEvent.MOUSE_OVER, _showTooltip, false);			
			_timer.addEventListener(TimerEvent.TIMER, _showTooltipVisible, false);
		}
		
		/**
		 * creates the elements that makeup the tooltip
		 */
		private function _createTooltip(string:String):void {
			_text					= new text(string, _tooltip);
			_text.x					= (_padding > 0) ? _padding : 0;
			_text.y					= (_padding > 0) ? _padding : 0;
			_text.bold				= _bold;
			_text.color				= _color;
			_text.size				= _size;
			_text.width				= (_text.width > _maxWidth) ? _maxWidth : (_text.width + _padding);
			_text.multiline			= true;
			_text.wordWrap			= true;
			_createTooltipBg();
		}
		
		/**
		 * creates the background element of the tooltip
		 */
		private function _createTooltipBg():void {
			var t_height:Number = _tooltip.getChildAt(0).height;
			var t_width:Number	= _tooltip.getChildAt(0).width;

			var bgRect:Shape	= new Shape();
			var bgSprite:Sprite	= new Sprite();

			var width:Number	= ((((_maxWidth > 0) && (t_width > _maxWidth)) ? _maxWidth : t_width) + ((_padding > 0) ? (_padding * 2) : 0));
			var height:Number	= (t_height + ((_padding > 0) ? (_padding * 2) : 0));

			if (_bgGradient) {
				// the background color is a gradient, begin fillin it in
				var gradient_matrix:Matrix = new Matrix();
				gradient_matrix.createGradientBox(width, height, (_gradientAngle * Math.PI / 180), 0, 0);
				bgRect.graphics.beginGradientFill(_gradientType, _gradientColors, _gradientAlphas, _gradientRatios, gradient_matrix, _gradientSpreadMethod, _gradientInterpolationMethod, _gradientFocalPointRatio);
			} else {
				// just a standard bg fill
				bgRect.graphics.beginFill(_bgColor);
			}

			if (_borderWidth > 0) bgRect.graphics.lineStyle(_borderWidth, _borderColor);

			var obj_loc:Point = _obj.localToGlobal(new Point(0, 0));
			// set the tooltips display orientation
			_directionHorizontal	= (((obj_loc.x + _obj.width) - (_obj.width / 4) + _tooltip.width) <= (_stage.stageWidth - 5)) ? "right" : "left";
			_directionVertical	= (((obj_loc.y - (_tooltip.height + _hookSize)) - 5) > 0) ? "up" : "down";
			var dir:String = (_directionVertical == "up") ? ((_directionHorizontal == "right") ? "bottom-left" : "bottom-right") : ((_directionHorizontal == "right") ? "top-left" : "top-right");
			
			if (dir == "top-left") {
				bgRect.graphics.moveTo((_hookOffset + _borderRound), 0);										// start the line at the end of the "top left" corner
				bgRect.graphics.lineTo((_hookOffset + _borderRound), -(_hookSize));							// draw the left-side of the hook
				bgRect.graphics.lineTo((_hookOffset + _hookSize + _borderRound), 0);							// draw the right-side of the hook
			} else {
				bgRect.graphics.moveTo(_borderRound, 0);														// start the line at the end of the "top left" corner {x: (0+corner_roundness), y: 0}
				// draw the line to the "top right" corner, leaving room for the round corner
				bgRect.graphics.lineTo(((dir == "top-center") ? ((width / 2) - (_hookSize / 2)) : ((dir == "top-right") ? (width - (_hookOffset + _hookSize + _borderRound)) : (width - _borderRound))), 0);
				if (dir == "top-center") {
					bgRect.graphics.lineTo((width / 2), -(_hookSize));											// draw the left-side of the hook
					bgRect.graphics.lineTo(((width / 2) + (_hookSize / 2)), 0);								// draw the right-side of the hook
				} else if (dir == "top-right") {
					bgRect.graphics.lineTo((width - (_hookOffset + _borderRound)), -(_hookSize));			// draw the left-side of the hook
					bgRect.graphics.lineTo((width - (_hookOffset + _borderRound)), 0);						// draw the right-side of the hook
				}
			}

			// draw the top-right corner
			bgRect.graphics.lineTo((width - _borderRound), 0);
			bgRect.graphics.curveTo(width, 0, width, _borderRound);

			if (dir == "right-top") {
				bgRect.graphics.lineTo(width, (_hookOffset + _borderRound));									// draw the right side down to the hook offset
				bgRect.graphics.lineTo((width + _hookSize), (_hookOffset + _borderRound));					// draw the top-side of the hook
				bgRect.graphics.lineTo(width, (_hookOffset + _hookSize + _borderRound));						// draw the bottom-side of the hook
			} else {
				// draw the line to the "bottom right" corner, leaving room for the round corner
				bgRect.graphics.lineTo(width, ((dir == "right-center") ? ((height / 2) - (_hookSize / 2)) : ((dir == "right-bottom") ? (height - (_hookOffset + _hookSize + _borderRound)) : (height - _borderRound))));
				if (dir == "right-center") {
					bgRect.graphics.lineTo((width + _hookSize), (height / 2));									// draw the top-side of the hook
					bgRect.graphics.lineTo(width, ((height / 2) + (_hookSize / 2)));							// draw the bottom-side of the hook
				} else if (dir == "right-bottom") {
					bgRect.graphics.lineTo((width + _hookSize), (height - (_hookOffset + _borderRound)));	// draw the top-side of the hook
					bgRect.graphics.lineTo(width, (height - (_hookOffset + _borderRound)));					// draw the bottom-side of the hook
				}
			}

			// draw the "bottom right" corner
			bgRect.graphics.lineTo(width, (height - _borderRound));
			bgRect.graphics.curveTo(width, height, (width - _borderRound), height);

			if (dir == "bottom-right") {
				bgRect.graphics.lineTo((width - (_hookOffset + _borderRound)), height);						// draw the line to the hook offset
				bgRect.graphics.lineTo((width - (_hookOffset + _borderRound)), (height + _hookSize));		// draw the right-side of the hook
				bgRect.graphics.lineTo((width - (_hookOffset + _hookSize + _borderRound)), height);			// draw the left-side of the hook
			} else {
				// draw the line to the "bottom left" corner, leaving room for the round corner
				bgRect.graphics.lineTo(((dir == "bottom-center") ? ((width / 2) + (_hookSize / 2)) : ((dir == "bottom-left") ? (_hookOffset + _hookSize + _borderRound) : _borderRound)), height);
				if (dir == "bottom-center") {
					bgRect.graphics.lineTo((width / 2), (height + _hookSize));									// draw the right-side of the hook
					bgRect.graphics.lineTo(((width / 2) - (_hookSize / 2)), height);							// draw the left-side of the hook
				} else if (dir == "bottom-left") {
					bgRect.graphics.lineTo((_hookOffset + _borderRound), (height + _hookSize));				// draw the right-side of the hook
					bgRect.graphics.lineTo((_hookOffset + _borderRound), height);								// draw the left-side of the hook
				}
			}

			// draw the "bottom left" corner
			bgRect.graphics.lineTo(_borderRound, height);
			bgRect.graphics.curveTo(0, height, 0, (height - _borderRound));

			if (dir == "left-bottom") {
				bgRect.graphics.lineTo(0, (height - (_hookOffset + _borderRound)));							// draw the left side up to the hook offset
				bgRect.graphics.lineTo(-(_hookSize), (height - (_hookOffset + _borderRound)));				// draw the bottom-side of the hook
				bgRect.graphics.lineTo(0, (height - (_hookOffset + _hookSize + _borderRound)));				// draw the top-side of the hook
			} else {
				// draw the line up to the "top left" corner, leaving room for the round corner
				bgRect.graphics.lineTo(0, ((dir == "left-center") ? ((height / 2) + (_hookSize / 2)) : ((dir == "left-top") ? (_hookOffset + _hookSize + _borderRound) : (_borderRound))));
				if (dir == "left-center") {
					bgRect.graphics.lineTo(-(_hookSize), (height / 2));										// draw the bottom-side of the hook
					bgRect.graphics.lineTo(0, ((height / 2) - (_hookSize / 2)));								// draw the top-side of the hook
				} else if (dir == "left-top") {
					bgRect.graphics.lineTo(-(_hookSize), (_hookOffset + _borderRound));						// draw the bottom-side of the hook
					bgRect.graphics.lineTo(0, (_hookOffset + _borderRound));									// draw the top-side of the hook
				}
			}

			// draw the line back up to the "top left" corner, leaving room for the round corner
			bgRect.graphics.lineTo(0, _borderRound);
			bgRect.graphics.curveTo(0, 0, _borderRound, 0);
			bgRect.graphics.endFill();

			// allow mouse clicks overtop of the rectangle
			bgSprite.mouseEnabled = false;
			bgSprite.mouseChildren = false;

			// add the new rectangle to the stage
			bgSprite.addChild(bgRect);  
			_tooltip.addChildAt(bgSprite, _tooltip.numChildren);
			
			// swap the bg with the text ('cause currently the bg is on top of the text)
			_tooltip.setChildIndex(_tooltip.getChildAt(_tooltip.numChildren - 1), 0);
		}
		
		/**
		 * creates the dropshadow based on the tooltips position
		 */
		private function _createShadow():void {
			// DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject)
			var drop_shadow:DropShadowFilter = new DropShadowFilter(5, 45, 0x000000, .6, 2.5, 2.5, 1, 3, false, false, false);
			_tooltip.filters = [ drop_shadow ];				
		}
				
		/**
		 * destroys the current tooltip
		 */
		public function _destroy(e:Event):void {
			_obj.removeEventListener(Event.REMOVED_FROM_STAGE, _destroy, false);
			_removeListeners();
			_text = null;
			_timer = null;
			_tooltip = null;
			_obj = null;
		}
		
		/**
		 * hides the tooltip from the stage
		 */
		private function _hideTooltip(e:MouseEvent):void {
			_obj.removeEventListener(MouseEvent.MOUSE_OUT, _hideTooltip, false);
			_obj.addEventListener(MouseEvent.MOUSE_OVER, _showTooltip, false);
			_timer.reset();
			var clip:DisplayObject = _stage.getChildByName(_uniqueName);
			_stage.removeChild(clip);
		}
		
		/**
		 * a gradient display value has changed, redraw the tooltip if the gradient settings are valid
		 */
		private function _gradientChanged():void {
			if (!_bgGradient || (_bgGradient && (_gradientAlphas.length == _gradientColors.length) && (_gradientAlphas.length == _gradientRatios.length))) {
				_tooltip.removeChildAt(0);
				_createTooltipBg();
			}
		}
		
		/**
		 * sets the tooltips position based on "stage" layout
		 */
		private function _position():void {
			var obj_loc:Point = _obj.localToGlobal(new Point(0, 0));
			_tooltip.x = (_directionHorizontal == "right") ? ((obj_loc.x + _obj.width) - (_obj.width / 4)) : ((obj_loc.x - _tooltip.width) + (_obj.width / 4) + _hookSize);
			_tooltip.y = (_directionVertical == "up") ? (obj_loc.y - _tooltip.height) : (obj_loc.y + _obj.height + _hookSize);
		}
		
		/**
		 * removes the listener for the mouse events to display the tooltip
		 */
		private function _removeListeners():void {
			_obj.removeEventListener(MouseEvent.MOUSE_OVER, _showTooltip, false);
			_timer.removeEventListener(TimerEvent.TIMER, _showTooltipVisible, false);
		}
		
		/**
		 * displays the tooltip on the stage
		 */
		private function _showTooltip(e:MouseEvent):void {
			_obj.removeEventListener(MouseEvent.MOUSE_OVER, _showTooltip, false);
			_obj.addEventListener(MouseEvent.MOUSE_OUT, _hideTooltip, false);
			// position the tooltip
			_position();
			// create the tooltips shadow
			_createShadow();
			// make it "invisible" before adding it to the stage
			_tooltip.alpha = 0;
			// add the tooltip
			_stage.addChild(_tooltip);
			_tooltip.name = _uniqueName;
			_timer.start();
		}
		
		/**
		 * makes the tooltip visible to the user
		 */
		private function _showTooltipVisible(e:TimerEvent):void {
			_timer.reset();
			var tooltip_tween_alpha:Tween = new Tween(_tooltip, "alpha", Regular.easeIn, 0, 1, .25, true);
		}
	}
}