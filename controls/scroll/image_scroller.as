/**
 * Manages multiple scrolling objects with rollover effects.
 *
 * @deprecated Replaced by `scroller`.
 *
 * Usage: {{{
 *    var scroll:image_scroller;
 *    scroll = new image_scroller(pic1, "http://google.com");
 *    scroll = new image_scroller(pic2);
 *    scroll = new image_scroller(pic3, "http://yahoo.com");
 *    scroll.speed(3);	// speed the scroller goes
 *    scroll.offset(1);	// offset of the images when they jump back to the "end"
 */

package classes.controls.scroll {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
    import flash.net.navigateToURL;
    import flash.net.URLRequest;
	
	public class image_scroller extends MovieClip {
		// Global vars
		private var _index:Number				= new Number(0);				// holds the current object's index in the stack
		private var _obj:Object					= null;							// holds a reference to the current object
		private var _url:String					= null;							// holds the current objects url (if any)
		private static var _end:Number			= new Number(0);				// pointer to the current end of the objects stack
		private static var _objs:Array			= new Array();					// full stack of all added objects
		private static var _offset:Number		= new Number(2);				// pixel-offset from the end object when moving
		private static var _paused:Boolean		= new Boolean(false);			// flag to indicate if the scroller is paused
		private static var _speed:Number		= new Number(4);				// speed of the slider
		
		/**
		 * Constructor: sets up the image_scroller item.
		 *
		 * @param Object clip
		 * @param String url
		 */
		public function image_scroller(clip:Object, url:String = null):void {
			_obj	= clip;
			_url	= url;
			_objs.push(_obj);
			_index	= (_objs.length - 1);
			_end	= _index;
			_obj.addEventListener(Event.ENTER_FRAME,		_slide,		false, 0, true);
			_obj.addEventListener(MouseEvent.MOUSE_OVER,	pause,		false, 0, true);
			_obj.addEventListener(MouseEvent.MOUSE_OUT,		unpause,	false, 0, true);
			if (url != null) {
				_obj.useHandCursor	= true;
				_obj.buttonMode		= true;
				_obj.addEventListener(MouseEvent.CLICK, _gotoUrl, false);
			}
		}
		
		/**
		 * Gets/sets the offset of the slider.
		 *
		 * @param Number
		 * @return Number
		 */
		public function get offset():Number {
			return _offset;
		}
		public function set offset(val:Number):void {
			_offset = val;
		}
		
		/**
		 * Pause the sliding animation.
		 *
		 * @param MouseEvent e Event arguments.
		 */
		public function pause(e:MouseEvent):void {
			_paused = true;
		}
		
		/**
		 * Resume the sliding animation.
		 *
		 * @param MouseEvent e Event arguments.
		 */
		public function resume(e:MouseEvent):void {
			_paused = false;
		}
		
		/**
		 * Gets/sets the speed of the slider.
		 *
		 * @param Number
		 * @return Number
		 */
		public function get speed():Number {
			return _speed;
		}
		public function set speed(val:Number):void {
			_speed = val;
		}
		
		/**
		 * Open the current URL.
		 *
		 * @param MouseEvent e Event arguments.
		 */
		private function _gotoUrl(e:MouseEvent):void {
			navigateToURL(new URLRequest(_url), "_self");
		}
		
		/**
		 * Slide the object.
		 *
		 * @param Event e Event arguments.
		 */
		private function _slide(e:Event):void {
			if (_paused) return;
			
			_obj.x -= _speed;
			if ((_obj.x + _obj.width) < 0) {
				_obj.x = _objs[_end].x + _objs[_end].width + _offset;
				_end = _index;
			}
		}
	}
}