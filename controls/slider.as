/**
 * Creates an easy-to-use slider control with horizontal, vertical (going down), and vertical (going up) abilities.
 *
 * Usage: {{{
 *    var s:slider = new slider(settings);
 *    addChild(s);
 *    s.addEventListener(slider.CHANGE, function (e:custom_event):void { trace("value: " + e.params.value); }, false);
 * }}}
 */

package classes.controls {
	import classes.events.custom_event;
	import classes.geom.simple_rectangle;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class slider extends MovieClip {
		// Global vars
		public static var CHANGE:String			= new String("change");
		public static var HORIZONTAL:String		= new String("horizontal");
		public static var THUMB_DRAG:String		= new String("thumbDrag");
		public static var VERTICAL_DOWN:String	= new String("verticalDown");
		public static var VERTICAL_UP:String	= new String("verticalUp");
		protected var _scrubber:MovieClip		= null;	// the scrubber object
		protected var _settings:Object			= null;	// the global settings object
		protected var _sliderBar:MovieClip		= null;	// the background bar object
		protected var _sliderRect:Rectangle		= null;	// the drag-area rectangle for the scrubber to follow
		
		/**
		 * constructor: sets up the slider
		 */
		public function slider(settings:Object=null):void {
			if (settings != null) {
				_processSettings(settings);
				_createUI();
			}
		}
		
		/**
		 * updates the scrubber's position to the value specified
		 */
		public function update(value:Number):void {
			value = ((value < 0) ? 0 : ((value > 1) ? 1 : value));
			
			if (_settings.direction == HORIZONTAL) {
				_scrubber.x = (_settings.length * value);
			} else if (_settings.direction == VERTICAL_DOWN) {
				_scrubber.y = (_settings.length * value);
			} else if (_settings.direction == VERTICAL_UP) {
				_scrubber.y = _settings.length - (_settings.length * value);
			}
		}
		
		/**
		 * builds the UI for the slider
		 */
		protected function _createUI():void {
			var scrubWidth:Number = (_settings.direction == HORIZONTAL) ? 4 : 11;
			var scrubHeight:Number = (_settings.direction == HORIZONTAL) ? 11 : 4;
			var scrub:simple_rectangle = new simple_rectangle(scrubWidth, scrubHeight, 0xcccccc, 1, 0xaaaaaa, 0);
			_scrubber = new MovieClip();
			_scrubber.addChild(scrub);
			_scrubber.buttonMode = true;
			_scrubber.addEventListener(MouseEvent.MOUSE_DOWN, _handleMouseDown, false);
			
			_settings.length = (_settings.length > ((_settings.direction == HORIZONTAL) ? (scrubHeight * 2) : (scrubWidth * 2))) ? _settings.length : 100;
			var barWidth:Number = (_settings.direction == HORIZONTAL) ? _settings.length : 2;
			var barHeight:Number = (_settings.direction == HORIZONTAL) ? 2 : _settings.length;
			var bar:simple_rectangle = new simple_rectangle(barWidth, barHeight, 0x888888, 0, 0x000000, 0);
			_sliderBar = new MovieClip();
			_sliderBar.addChild(bar);
			_sliderBar.addEventListener(MouseEvent.MOUSE_DOWN, _handleBarMouseDown, false);
			
			if (_settings.direction == HORIZONTAL) {
				_sliderBar.y = -(_sliderBar.height / 2);
				_scrubber.y = -(_scrubber.height / 2);
				
				_scrubber.x = (((_settings.value - _settings.minValue) / (_settings.maxValue - _settings.minValue)) * (_settings.maxValue - _settings.minValue));
			} else {
				_sliderBar.x = -(_sliderBar.width / 2);
				_scrubber.x = -(_scrubber.width / 2);
				
				_scrubber.y = ((((_settings.value - _settings.minValue) / (_settings.maxValue - _settings.minValue)) * _settings.length) + ((_settings.direction == VERTICAL_UP) ? -_settings.length : 0)) * ((_settings.direction == VERTICAL_UP) ? -1 : 1);
			}
			addChild(_sliderBar);
			addChild(_scrubber);
			
			_sliderRect = new Rectangle();
			_sliderRect.x = _sliderBar.x - ((_settings.direction == HORIZONTAL) ? 0 : (scrubWidth / 2));
			_sliderRect.y = _sliderBar.y - ((_settings.direction == HORIZONTAL) ? (scrubHeight / 2) : 0);
			_sliderRect.width = (_settings.direction == HORIZONTAL) ? _sliderBar.width : 0;
			_sliderRect.height = (_settings.direction == HORIZONTAL) ? 0 : _sliderBar.height;
			
		}
		
		/**
		 * returns the current value of the scrubber
		 */
		private function _currentValue():int {
			return (_settings.minValue + ((((_settings.direction == HORIZONTAL) ? _scrubber.x : ((_settings.direction == VERTICAL_DOWN) ? _scrubber.y : (_settings.length - _scrubber.y))) / _settings.length) * (_settings.maxValue - _settings.minValue)));
		}
		
		/**
		 * directly positions the scrubber to where the mouse was clicked and then starts dragging
		 */
		protected function _handleBarMouseDown(e:MouseEvent):void {
			_sliderBar.removeEventListener(MouseEvent.MOUSE_DOWN, _handleBarMouseDown, false);
			(_settings.direction == HORIZONTAL) ? (_scrubber.x = e.localX) : (_scrubber.y = e.localY);
			_handleMouseDown(new MouseEvent(MouseEvent.MOUSE_DOWN));
		}
		
		/**
		 * starts the scrubber dragging
		 */
		protected function _handleMouseDown(e:MouseEvent):void {
			_sliderBar.removeEventListener(MouseEvent.MOUSE_DOWN, _handleBarMouseDown, false);
			_scrubber.startDrag(false, _sliderRect);
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, _handleMouseMove, false);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, _handleMouseUp, false);
		}
		
		/**
		 * dispatches an update event with the current value
		 */
		protected function _handleMouseMove(e:MouseEvent):void {
			if (!_settings.liveUpdate) return;
			dispatchEvent(new custom_event(THUMB_DRAG, {target: e.target, currentTarget: e.currentTarget, value: _currentValue()}));
		}
		
		/**
		 * stops the scrubber drag and dispatches a CHANGE event with the new value
		 */
		protected function _handleMouseUp(e:MouseEvent):void {
			stopDrag();
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, _handleMouseMove, false);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, _handleMouseUp, false);
			dispatchEvent(new custom_event(CHANGE, {target: e.target, currentTarget: e.currentTarget, value: _currentValue()}));
			_sliderBar.addEventListener(MouseEvent.MOUSE_DOWN, _handleBarMouseDown, false);
		}
		
		/**
		 * process all of the given settings and set any defaults required
		 */
		protected function _processSettings(settings:Object):void {
			_settings = new Object();
			
			// general control settings
			_settings.direction 	= (settings.direction != null) ? ((settings.direction == VERTICAL_UP) ? VERTICAL_UP : ((settings.direction == VERTICAL_DOWN) ? VERTICAL_DOWN : HORIZONTAL)) : HORIZONTAL;
			_settings.length		= ((settings.length != null) && (settings.length > 0)) ? settings.length : 100;
			_settings.minValue		= ((settings.minValue != null) && (int(settings.minValue) >= 0)) ? int(settings.minValue) : 0;
			_settings.maxValue		= ((settings.maxValue != null) && (int(settings.maxValue) >= _settings.minValue)) ? int(settings.maxValue) : (_settings.minValue + 100);
			_settings.liveUpdate	= ((settings.liveUpdate != null) && (settings.liveUpdate == true)) ? true : false;
			_settings.value			= ((settings.value != null) && (int(settings.value) >= _settings.minValue) && (int(settings.value) <= _settings.maxValue)) ? int(settings.value) : ((_settings.maxValue + _settings.minValue) / 2);
		}
	}
}