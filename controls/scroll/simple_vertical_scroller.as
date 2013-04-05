/**
 * Creates a plain, base configuration vertical scroller.
 *
 * @deprecated Replaced by `scroller`.
 */

package classes.controls.scroll {
	import classes.file.image_loader;
	import classes.geom.simple_rectangle;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class simple_vertical_scroller extends MovieClip {
		// Global vars
		private			var _arrows:Array			= new Array();						// holds all of the current arrows
		private			var	_enabled:Boolean		= new Boolean(true);				// flag to indicate if the scroller is enabled
		private			var _forceStop:Boolean		= new Boolean(false);				// flag to force any current slides to stop
		private static	var _loader:image_loader	= new image_loader();				// global image_loader object
		private			var _scrolling:Boolean		= new Boolean(false);				// flag to indicate if we are currently scrolling
		private			var _settings:Object		= null;								// holds all of the current settings
		
		/**
		 * constructor: sets up the simple_vertical_scroller object
		 *
		 * @param Object settings
		 */
		public function simple_vertical_scroller(settings:Object):void {
			_settings				= settings;
			_settings.height		= ((_settings.height != null) && (_settings.height > 0))			? _settings.height			: 450;
			_settings.width			= ((_settings.width != null) && (_settings.width > 0))				? _settings.width			: 550;
			_settings.object		= (_settings.object != null)										? _settings.object			: null;
			_settings.scrollSpeed	= ((_settings.scrollSpeed != null) && (_settings.scrollSpeed > 0))	? _settings.scrollSpeed		: 24;
			_settings.padding		= ((_settings.padding != null) && (_settings.padding > 0))			? _settings.padding			: 5;
			_settings.up_arrow		= (_settings.up_arrow != null)										? _settings.up_arrow		: null;
			_settings.down_arrow	= (_settings.down_arrow != null)									? _settings.down_arrow		: null;
			
			_setupScroller();
		}
		
		/**
		 * Disables the arrow button/bar for the specified direction.
		 *
		 * @param String direction
		 */
		public function disable(direction:String):void {
			var dir:MovieClip = MovieClip((direction == "up") ? _settings.up_arrow : _settings.down_arrow);
			
			dir.mouseChildren	= true;
			dir.useHandCursor	= false;
			dir.buttonMode		= false;
			dir.alpha			= .5;
			dir.enabled			= false;
			trace("[scroller] Disabled "+direction+" arrow.");
		}
		
		/**
		 * Enables the arrow button/bar for the specified direction.
		 *
		 * @param String direction
		 */
		public function enable(direction:String):void {
			var dir:MovieClip = MovieClip((direction == "up") ? _settings.up_arrow : _settings.down_arrow);
			
			dir.mouseChildren	= false;
			dir.useHandCursor	= true;
			dir.buttonMode		= true;
			dir.alpha			= 1;
			dir.enabled			= true;
			trace("[scroller] Enabled "+direction+" arrow.");
		}
		
		/**
		 * Sets the "force stop" flag so that any current scrolling stops!
		 */
		public override function stop():void {
			if (!_scrolling) return;
			_forceStop = true;
		}
		
		/**
		 * Returns the maximum height of the current scroller.
		 *
		 * @return Number The height of the scroller.
		 */
		public override function get height():Number {
			return (_settings.height + (_settings.padding * 2) + (_settings.up_arrow.height + _settings.down_arrow.height));
		}
		
		/**
		 * Sets the height.
		 *
		 * @param Number value The height to set the scroller to.
		 */	
		public override function set height(value:Number):void {
			// placeholder
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
		 * Sets the width.
		 *
		 * @param Number value The width to set the scroller to.
		 */
		public override function set width(value:Number):void {
			// placeholder
		}
		
		/**
		 * Monitors the object for size modifications and/or position changes to enable/disable respective arrows.
		 *
		 * @param Event e Event arguments.
		 */
		private function _objResize(e:Event):void {
			if (!_enabled) return;
			
			// up arrow
			if (_settings.object.y < 0) {
				enable("up");
			} else if (_settings.object.y >= 0) {
				disable("up");
			}
			
			// down arrow
			if (((_settings.object.y + _settings.object.height) > _settings.height)) {
				enable("down");
			} else if (((_settings.object.y + _settings.object.height) <= _settings.height)) {
				disable("down");
			}
		}
		
		/**
		 * Calculates the amount to scroll each frame for a smooth page-scroll animation.
		 *
		 * @param MouseEvent e Event arguments.
		 */
		private function _scroll(e:MouseEvent):void {
			if (!_enabled || _scrolling || !e.currentTarget.enabled) return;
			
			var dir:String				= (e.currentTarget == _settings.up_arrow) ? "up" : "down";
			var scrollAmount:Number		= new Number(0);
			var tmpEnd:Number			= new Number(0);
			
			// find the amount to scroll the object based on the current direction
			switch (dir) {
				case "up":
					tmpEnd = (-_settings.object.y < (_settings.height - (_settings.height * .2))) ? -_settings.object.y : (_settings.height - (_settings.height * .2));
					scrollAmount = (tmpEnd / _settings.scrollSpeed);
					break;
				case "down":
					tmpEnd = (((_settings.object.y + _settings.object.height) - _settings.height) < (_settings.height - (_settings.height * .2))) ? ((_settings.object.y + _settings.object.height) - _settings.height) : (_settings.height - (_settings.height * .2));
					scrollAmount = -(tmpEnd / _settings.scrollSpeed);
					break;
			}
			
			// add a listener for the next frame-enterance to allow for smooth animation
			_scrolling = true;
			_settings.object.addEventListener(Event.ENTER_FRAME,
				function (e:Event):void {
					_settings.object.removeEventListener(Event.ENTER_FRAME, arguments.callee, false);
					_scrollAnimate(scrollAmount, 0);
				},
				false
			);
		}
		
		/**
		 * Performs the scrolling animation with the given settings.
		 *
		 * @param Number scrollAmount
		 * @param int count
		 */
		private function _scrollAnimate(scrollAmount:Number, count:int):void {
			if (!_enabled) return;
			_settings.object.y += scrollAmount;
			
			if (count < _settings.scrollSpeed) {
				// we still have more scrolling to do, so add a new listener to animate on the next frame enterance
				_settings.object.addEventListener(Event.ENTER_FRAME,
					function (e:Event):void {
						_settings.object.removeEventListener(Event.ENTER_FRAME, arguments.callee, false);
						if (!_forceStop) {
							_scrollAnimate(scrollAmount, ++count);
						} else {
							_scrolling = false;
							_forceStop = false;
						}
					},
					false
				);
			} else {
				_scrolling = false;
				_forceStop = false;
			}
			
			// throw a resize listener to enable/disable the arrows
			_objResize(new Event(Event.RESIZE));
		}
		
		/**
		 * Sets up the scroller's UI.
		 */
		private function _setupScroller():void {
			if ((_settings.up_arrow == null) || (_settings.down_arrow == null)) {
				trace("[simple_vertical_scroller] Error! We need both an UP arrow and a DOWN arrow.");
				return;
			}
			
			// add the overlay mask
			var obj_mask:Sprite = new simple_rectangle(_settings.width, _settings.height, 0x000000, 0, 0x000000);
			obj_mask.cacheAsBitmap = true;
			this.addChild(obj_mask);
			
			// set up the object
			_settings.object.addEventListener(Event.RESIZE, _objResize, false);
			this.addChildAt(DisplayObject(_settings.object), 0);
			_settings.object.cacheAsBitmap = true;
			_settings.object.mask = obj_mask;
			_objResize(new Event(Event.RESIZE));
			
			this.addChild(_settings.up_arrow);
			_settings.up_arrow.y = -(_settings.up_arrow.height + _settings.padding);
			
			this.addChild(_settings.down_arrow);
			_settings.down_arrow.y = (_settings.height + _settings.padding);
			
			_settings.up_arrow.addEventListener(MouseEvent.CLICK, _scroll, false);
			_settings.down_arrow.addEventListener(MouseEvent.CLICK, _scroll, false);
		}
	}
}