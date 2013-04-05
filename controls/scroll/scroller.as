/**
 * Attaches to a MovieClip that only wants a set size to be displayed at a time and
 * the rest to be "scrolled", either horizontally or vertically.
 *
 * Usage: {{{
 *    var scroll:scroller = new scroller({object: my_scrolling_clip, width: 600, height: 200, direction: horizontal, left_arrow: "left.png", right_arrow: "right.png"});
 *    stage.addChild(scroll);
 * }}}
 */

package classes.controls.scroll {
	import classes.file.image_loader;
	import classes.geom.simple_rectangle;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class scroller extends MovieClip {
		// Global vars
		private			var _arrows:Array			= new Array();
		private			var	_enabled:Boolean		= new Boolean(true);
		private			var _force_stop:Boolean		= new Boolean(false);
		private static	var _loader:image_loader	= new image_loader();
		private			var _scrolling:Boolean		= new Boolean(false);
		private			var _settings:Object		= null;
		private			var _sprite:Sprite			= new Sprite();
		
		/**
		 * Constructor: sets up the scroller object.
		 *
		 * @param Object settings
		 */
		public function scroller(settings:Object):void {
			_settings						= settings;
			_settings.auto_hide				= ((_settings.auto_hide != null) && (_settings.auto_hide == "true"))				? true							: false;
			_settings.bgColor				= ((_settings.bgColor != null) && (_settings.bgColor >= 0))							? _settings.bgColor				: 0xFFFFFF;
			_settings.bgTrans				= (_settings.bgTrans != null)														? _settings.bgTrans				: .4;
			_settings.border				= ((_settings.border != null) && (_settings.border > 0))							? _settings.border				: 0;
			_settings.borderColor			= ((_settings.borderColor != null) && (_settings.borderColor > 0))					? _settings.borderColor 		: 0xFFFFFF;
			_settings.direction				= (_settings.direction != null)														? _settings.direction			: "auto";
			_settings.scrollMode			= ((_settings.scrollMode != null) && (_settings.scrollMode == "followMouse"))		? "followMouse"					: "fullPage";
			_settings.height				= ((_settings.height != null) && (_settings.height > 0))							? _settings.height				: 450;
			_settings.object				= (_settings.object != null)														? _settings.object				: null;
			_settings.scrollSpeed			= ((_settings.scrollSpeed != null) && (_settings.scrollSpeed > 0))					? _settings.scrollSpeed			: 24;
			_settings.width					= ((_settings.width != null) && (_settings.width > 0))								? _settings.width				: 550;
			_settings.horizontal_padding	= ((_settings.horizontal_padding != null) && (_settings.horizontal_padding > 0))	? _settings.horizontal_padding	: 5;
			_settings.vertical_padding		= ((_settings.vertical_padding != null) && (_settings.vertical_padding > 0))		? _settings.vertical_padding	: 5;
			
			// setup/load any of the arrow images
			_loader.addEventListener(Event.COMPLETE, _setup_arrows, false);
			if (_settings.left_arrow != null) {
				_arrows["left"]				= new Array();
				_arrows["left"]["image"]	= new MovieClip();
				_loader.load(_settings.left_arrow, _arrows["left"]["image"]);
			}
			if (_settings.right_arrow != null) {
				_arrows["right"]			= new Array();
				_arrows["right"]["image"]	= new MovieClip();
				_loader.load(_settings.right_arrow, _arrows["right"]["image"]);
			}
			if (_settings.up_arrow != null) {
				_arrows["up"]			= new Array();
				_arrows["up"]["image"]	= new MovieClip();
				_loader.load(_settings.up_arrow, _arrows["up"]["image"]);
			}
			if (_settings.down_arrow != null) {
				_arrows["down"]				= new Array();
				_arrows["down"]["image"]	= new MovieClip();
				_loader.load(_settings.down_arrow, _arrows["down"]["image"]);
			}
			// if the object was specified (which is required), begin setting up the scroller
			if (_settings.object != null) _setup_scroller();
		}
		
		/**
		 * Disables the arrow button/bar for the specified direction.
		 *
		 * @param String direction
		 */
		public function disable(direction:String):void {
			if ((_arrows[direction] != null) && (_arrows[direction]["container"] != null) && (_arrows[direction]["image"] != null)) {
				_arrows[direction]["container"].mouseChildren	= true;
				_arrows[direction]["container"].useHandCursor	= false;
				_arrows[direction]["container"].buttonMode		= false;
				_arrows[direction]["container"].alpha			= 0;
				_arrows[direction]["container"].visible			= false;
				_arrows[direction]["container"].enabled			= false;
				_arrows[direction]["disabled"]					= true;
			} else if (_arrows[direction] != null) {
				_arrows[direction]["disabled"]					= true;
			}
			trace("[scroller] Disabled "+direction+" arrow.");
		}
		
		/**
		 * Enables the arrow button/bar for the specified direction.
		 *
		 * @param String direction
		 */
		public function enable(direction:String):void {
			if ((_arrows[direction] != null) && (_arrows[direction]["container"] != null) &&  (_arrows[direction]["image"] != null)) {
				_arrows[direction]["container"].mouseChildren	= false;
				_arrows[direction]["container"].useHandCursor	= true;
				_arrows[direction]["container"].buttonMode		= true;
				_arrows[direction]["container"].alpha			= 1;
				_arrows[direction]["container"].visible			= true;
				_arrows[direction]["container"].enabled			= true;
				_arrows[direction]["disabled"]					= false;
			} else if (_arrows[direction] != null) {
				_arrows[direction]["disabled"]					= false;
			}
			trace("[scroller] Enabled "+direction+" arrow.");
		}
		
		/**
		 * Gets the the 'enabled' flag.
		 *
		 * @return Boolean The current 'enabled' value.
		 */
		public override function get enabled():Boolean {
			return _enabled;
		}
		
		/**
		 * Sets the the 'enabled' flag.
		 *
		 * @param Boolean value The current 'enabled' value.
		 */
		public override function set enabled(value:Boolean):void {
			_enabled = value;
		}
		
		/**
		 * Gets a pointer reference to the current object we are scrolling
		 *
		 * @return Object The object we're scrolling.
		 */
		public function get object():Object {
			return _settings.object;
		}
		
		/**
		 * Returns the maximum width of the current scroller.
		 *
		 * @param Object value A pointer-reference to the current object that's scrolling.
		 */
		public function set object(value:Object):void {
			if (value == _settings.object) return;
			
			// remove all of the current settings that are created during "setup"
			_settings.object.removeEventListener(Event.RESIZE, _obj_resize, false);
			this.removeChild(DisplayObject(_settings.object));
			if (_settings.scrollMode == "followMouse") this.removeEventListener(Event.ENTER_FRAME, _followMouse, false);
			
			// replace the scrolling object and re-setup the scroller
			_settings.object = value;
			_setup_scroller();
		}
		
		/**
		 * Sets the "force stop" flag so that any current scrolling stops!
		 */
		public override function stop():void {
			if (!_scrolling) return;
			_force_stop = true;
		}
		
		/**
		 * Returns the maximum width of the current scroller.
		 *
		 * @return Number The width of the scroller.
		 */
		public override function get width():Number {
			return _settings.width;
		}
		
		/**
		 * Sets the maximum width of the current scroller.
		 *
		 * @param Number value The width of the scroller.
		 */	
		public override function set width(value:Number):void {
			// placeholder
		}
		
		/**
		 * Creates the arrow button/bar based on the direction specified.
		 *
		 * @param String direction
		 * @param Boolean enabled
		 */
		private function _create_arrow(direction:String, enabled:Boolean):void {
			if ((_arrows[direction] != null) && (_arrows[direction]["image"] != null)) {
				// create an emtpy MovieClip to be the "container" for this arrow
				_arrows[direction]["container"] = new MovieClip();
				_arrows[direction]["container"].name = direction;
				// draw a background "rectangle"
				var arrow:Sprite = new simple_rectangle((((direction == "left") || (direction == "right")) ? _arrows[direction]["image"].width : _settings.width), (((direction == "up") || (direction == "down")) ? _arrows[direction]["image"].height : _settings.height), _settings.bgColor, _settings.border, _settings.borderColor);
				arrow.alpha = _settings.bgTrans;
				arrow.x = arrow.y = 0;
				_arrows[direction]["container"].addChild(arrow);
				// add the loaded arrow-image
				_arrows[direction]["container"].addChild(_arrows[direction]["image"]);
				// set the direction of the "arrow" image
				((direction == "left") || (direction == "right")) ? (_arrows[direction]["image"].y = (_settings.height - _arrows[direction]["image"].height) / 2) : (_arrows[direction]["image"].x = (_settings.width - _arrows[direction]["image"].width) / 2);
				// for right/down, we need to set the x/y, respectively
				if (direction == "right") {
					_arrows[direction]["container"].x = (_settings.width - _arrows[direction]["image"].width);
				} else if (direction == "down") {
					_arrows[direction]["container"].y = (_settings.height - _arrows[direction]["image"].height);
				}
				// if we are supposed to "auto-hide" the scrollbars, well, make it hidden!
				if (_settings.auto_hide == true) {
					arrow.alpha = .001;
					_arrows[direction]["image"].alpha = 0;
					_arrows[direction]["container"].addEventListener(MouseEvent.MOUSE_OVER, _hilight_arrow, false);
					_arrows[direction]["container"].addEventListener(MouseEvent.MOUSE_OUT, _unhilight_arrow, false);
				}
				if (_settings.scrollMode != "followMouse") {
					// add the scroll-listener
					_arrows[direction]["container"].addEventListener(MouseEvent.CLICK, _scroll, false);
				}
				this.addChild(_arrows[direction]["container"]);
				// enable/disable the button pending the passed flag
				(enabled == true) ? enable(direction) : disable(direction);
			}
		}
		
		/**
		 * Changes the objects position based on the current mouse position.
		 *
		 * @param Event e Event arguments.
		 */
		private function _followMouse(e:Event):void {
			if (!_enabled) return;
			if ((_settings.object.width > _settings.width) && ((_settings.direction == "auto") || (_settings.direction == "horizontal")) && this.hitTestPoint(this.mouseX, this.mouseY, false)) {
				// scroll horizontally following the mouse
				var endX:Number = ((((_settings.width / 2) - this.mouseX) / (_settings.width / 2))) * _settings.scrollSpeed;
				_settings.object.x = ((_settings.object.x + endX) > _settings.horizontal_padding) ? _settings.horizontal_padding : (((_settings.object.x + _settings.object.width + endX) < (this.width - _settings.horizontal_padding)) ? -(_settings.object.width - this.width + _settings.horizontal_padding) : (_settings.object.x + endX));
			}
			if ((_settings.object.height > _settings.height) && ((_settings.direction == "auto") || (_settings.direction == "vertical")) && this.hitTestPoint(this.mouseX, this.mouseY, false)) {
				// scroll vertically following the mouse
				var endY:Number = ((((_settings.height / 2) - this.mouseY) / (_settings.height / 2))) * _settings.scrollSpeed;
				_settings.object.y = ((_settings.object.y + endY) > _settings.vertical_padding) ? _settings.vertical_padding : (((_settings.object.y + _settings.object.height + endY) < (this.height - _settings.vertical_padding)) ? -(_settings.object.height - this.height + _settings.vertical_padding) : (_settings.object.y + endY));
			}

			// throw a resize listener to enable/disable the arrows
			_obj_resize(new Event(Event.RESIZE));
		}
		
		/**
		 * Displays the targeted arrow by increasing the alpha.
		 *
		 * @param MouseEvent e Event arguments.
		 */
		private function _hilight_arrow(e:MouseEvent):void {
			e.currentTarget.getChildAt(0).alpha = .4;
			e.currentTarget.getChildAt(1).alpha = 1;
		}
		
		/**
		 * Monitors the object for size modifications and/or position changes to enable/disable respective arrows.
		 *
		 * @param Event e Event arguments.
		 */
		private function _obj_resize(e:Event):void {
			if (!_enabled) return;
			// right arrow
			if (_arrows["right"] && (_arrows["right"]["disabled"] == true) && ((_settings.object.x + _settings.object.width) > _settings.width)) {
				enable("right");
			} else if (_arrows["right"] && (_arrows["right"]["disabled"] == false) && ((_settings.object.x + _settings.object.width) <= _settings.width)) {
				disable("right");
			}
			// left arrow
			if (_arrows["left"] && (_arrows["left"]["disabled"] == true) && (_settings.object.x < 0)) {
				enable("left");
			} else if (_arrows["left"] && (_arrows["left"]["disabled"] == false) && (_settings.object.x >= 0)) {
				disable("left");
			}
			// up arrow
			if (_arrows["up"] && (_arrows["up"]["disabled"] == true) && (_settings.object.y < 0)) {
				enable("up");
			} else if (_arrows["up"] && (_arrows["up"]["disabled"] == false) && (_settings.object.y >= 0)) {
				disable("up");
			}
			// down arrow
			if (_arrows["down"] && (_arrows["down"]["disabled"] == true) && ((_settings.object.y + _settings.object.height) > _settings.height)) {
				enable("down");
			} else if (_arrows["down"] && (_arrows["down"]["disabled"] == false) && ((_settings.object.y + _settings.object.height) <= _settings.height)) {
				disable("down");
			}
		}
		
		/**
		 * Calculates the amount to scroll each frame for a smooth page-scroll animation.
		 *
		 * @param MouseEvent e Event arguments.
		 */
		private function _scroll(e:MouseEvent):void {
			if (!_enabled) return;
			var dir:String				= e.currentTarget.name;
			var scroll_amount:Number	= new Number(0);
			var tmp_end:Number			= new Number(0);
			
			// find the amount to scroll the object based on the current direction
			switch (dir) {
				case "left":
					tmp_end = (-_settings.object.x < (_settings.width - (_settings.width * .2))) ? -_settings.object.x : (_settings.width - (_settings.width * .2));
					scroll_amount = (tmp_end / _settings.scrollSpeed);
					break;
				case "right":
					tmp_end = (((_settings.object.x + _settings.object.width) - _settings.width) < (_settings.width - (_settings.width * .2))) ? ((_settings.object.x + _settings.object.width) - _settings.width) : (_settings.width - (_settings.width * .2));
					scroll_amount = -(tmp_end / _settings.scrollSpeed);
					break;
				case "up":
					tmp_end = (-_settings.object.y < (_settings.height - (_settings.height * .2))) ? -_settings.object.y : (_settings.height - (_settings.height * .2));
					scroll_amount = (tmp_end / _settings.scrollSpeed);
					break;
				case "down":
					tmp_end = (((_settings.object.y + _settings.object.height) - _settings.height) < (_settings.height - (_settings.height * .2))) ? ((_settings.object.y + _settings.object.height) - _settings.height) : (_settings.height - (_settings.height * .2));
					scroll_amount = -(tmp_end / _settings.scrollSpeed);
					break;
			}
			
			// add a listener for the next frame-enterance to allow for smooth animation
			_scrolling = true;
			_settings.object.addEventListener(Event.ENTER_FRAME,
				function (e:Event):void {
					_settings.object.removeEventListener(Event.ENTER_FRAME, arguments.callee, false);
					_scroll_animate(dir, scroll_amount, 0);
				},
				false
			);
		}
		
		/**
		 * Performs the scrolling animation with the given settings.
		 *
		 * @param String dir
		 * @param Number scroll_amount
		 * @param int count
		 */
		private function _scroll_animate(dir:String, scroll_amount:Number, count:int):void {
			if (!_enabled) return;
			switch (dir) {
				case "left":	// scroll horizontally
				case "right":	_settings.object.x += scroll_amount;
					break;
				case "up":		// scroll vertically
				case "down":	_settings.object.y += scroll_amount
					break;
			}
			
			if (count < _settings.scrollSpeed) {
				// we still have more scrolling to do, so add a new listener to animate on the next frame enterance
				_settings.object.addEventListener(Event.ENTER_FRAME,
					function (e:Event):void {
						_settings.object.removeEventListener(Event.ENTER_FRAME, arguments.callee, false);
						if (!_force_stop) {
							_scroll_animate(dir, scroll_amount, ++count);
						} else {
							_scrolling = false;
							_force_stop = false;
						}
					},
					false
				);
			} else {
				_scrolling = false;
				_force_stop = false;
			}
			
			// throw a resize listener to enable/disable the arrows
			_obj_resize(new Event(Event.RESIZE));
		}
		
		/**
		 * Sets up the current "allowed" arrows one-by-one.
		 *
		 * @param Event e Event arguments.
		 */
		private function _setup_arrows(e:Event):void {
			_loader.removeEventListener(Event.COMPLETE, _setup_arrows, false);
			if ((_settings.direction == "auto") || (_settings.direction == "horizontal")) {
				_create_arrow("left", (_settings.object.x < 0));
				_create_arrow("right", (_settings.object.width > _settings.width));
			}
			if ((_settings.direction == "auto") || (_settings.direction == "vertical")) {
				_create_arrow("up", (_settings.object.y < 0));
				_create_arrow("down", (_settings.object.height > _settings.height));
			}
		}
		
		/**
		 * Sets up the scroller object.
		 */
		private function _setup_scroller():void {
			// create a mask to...mask...the object so that we only see the "width"/"height" that the scroller provides
			var obj_mask:Sprite = new simple_rectangle(_settings.width, _settings.height, 0x000000, 0, 0x000000);
			obj_mask.cacheAsBitmap = true;
			this.addChild(obj_mask);
		
			// set up the object
			_settings.object.addEventListener(Event.RESIZE, _obj_resize, false);
			this.addChildAt(DisplayObject(_settings.object), 0);
			_settings.object.cacheAsBitmap = true;
			_settings.object.mask = obj_mask;
			
			// check if we are to "follow the mouse" to scroll instead of using the arrows
			if (_settings.scrollMode == "followMouse") this.addEventListener(Event.ENTER_FRAME, _followMouse, false);
			_obj_resize(new Event(Event.RESIZE));
		}
		
		/**
		 * Hides the targeted arrow from view by fading it out.
		 *
		 * @param MouseEvent e Event arguments.
		 */
		private function _unhilight_arrow(e:MouseEvent):void {
			e.currentTarget.getChildAt(0).alpha = .001;
			e.currentTarget.getChildAt(1).alpha = 0;
		}
	}
}