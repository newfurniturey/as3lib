/**
 * Creates a fader transition for specified objects
 *
 * Usage: {{{
 *    fade:fader = new fader();
 *    fade.fade(object);
 * }}}
 */

package classes.effects {
	import classes.events.custom_event;
	import flash.events.Event;
	
	public class fader {
		// Global vars.
		public static var TRANSITION_COMPLETE:String = new String("transitionComplete");
		public static var TRANSITION_STOPPED:String	= new String("transitionStopped");
		private var _dir:String = new String();					// current direction
		private var _speed:Number = new Number(.08);			// speed to fade in/out
		private static var _stop:Boolean = new Boolean(false);	// flag to stop transitions
		private static var _transitions:int = new Number(0);	// current number of transitions
		
		/**
		 * constructor: setup the fader object by setting the speed
		 */
		public function fader(speed:Number=12, fps:Number=24):void {
			_speed = (fps / speed) / fps;
		}
		
		/**
		 * fades the specified object in the specified direction (In // Out)
		 */
		public function fade(obj:Object, dir:String=null):void {
			_dir = ((dir == null) || ((dir != "Out") && (dir != "In"))) ? ((obj.alpha > 0) ? "Out" : "In") : dir;
			_transitions++;
			
			// add a listener for the clip entering the frame
			obj.addEventListener(Event.ENTER_FRAME,
				function (e:Event):void {
					e.target.removeEventListener(Event.ENTER_FRAME, arguments.callee, false);
					_transition(obj);
				},
				false
			);
		}
		
		/**
		 * checks if there are any current transitions
		 */
		public function isFading():Boolean {
			return (_transitions > 0);
		}
		
		/**
		 * reverses the current direction of the fade
		 */
		public function reverse():void {
			_dir = (_dir == "Out") ? "In" : "Out";
		}
		
		/**
		 * stops all fades
		 */
		public function stop():void {
			if (_transitions > 0) {
				_stop = true;
			}
		}
		
		/**
		 * will transition the current target into the specified direction (In or Out) and
		 * then will dispatch a COMPLETE event once its finished
		 */
		private function _transition(obj:Object):void {
			if (_stop === true) {
				obj.dispatchEvent(new custom_event(TRANSITION_STOPPED));
				_transitions--;
				if (_transitions == 0) {				
					_stop = false;
				}
				return;
			}

			var target_value:Number = new Number(0);
			if (_dir == "In") {
				// fading the object to 100% visible
				obj.visible		= true;
				obj.alpha	   += _speed;
				target_value	= 1;
			} else {
				// fading the object to 0% visible
				obj.alpha	   -= _speed;
				target_value	= 0;
			}
			
			if ((_stop === true) || ((obj.alpha <= target_value) && (target_value == 0)) || ((obj.alpha >= target_value) && (target_value == 1))) {
				// object has been faded to its target value
				if (_dir == "Out") {
					obj.visible = false;
				}
				_transitions--;
				obj.dispatchEvent(new custom_event(TRANSITION_COMPLETE));
				if (_transitions == 0) {
					_stop = false;
				}
			} else {
				// object ain't done fading, keep the circle going!
				obj.addEventListener(Event.ENTER_FRAME,
					function (e:Event):void {
						e.target.removeEventListener(Event.ENTER_FRAME, arguments.callee, false);
						_transition(obj);
					},
					false
				);
			}
		}
	}
}