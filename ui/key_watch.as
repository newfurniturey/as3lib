/**
 * Manages listeners and actions for keyboard events (aka: pressing a key).
 *
 * Usage {{{
 *    import flash.ui.Keyboard;
 *    var key:key_watch = new key_watch(stage);
 *    if (key.isDown(65)) { }
 *    if (key.isUp(65)) { }
 * }}}
 */

package classes.ui {
	import flash.events.KeyboardEvent;
	
	public class key_watch {
		// Global vars
		private static var arKeys:Array = new Array(222);	// array to hold all "possible" key presses
		
		/**
		 * constructor: sets up the stage listeners for the keyboard events
		 */
		public function key_watch(stage:Object):void {
			// setup the listeners for the keyboard being pressed and released
			stage.addEventListener(KeyboardEvent.KEY_DOWN,	_keyPress,		false, 0, true);
			stage.addEventListener(KeyboardEvent.KEY_UP,	_keyRelease,	false, 0, true);
		}

		/**
		 * checks if the specified key is being pressed
		 */
		public function isDown(keyCode:uint):Boolean {
			return arKeys[keyCode];
		}

		/**
		 * checks if the specified key is not being pressed
		 */
		public function isUp(keyCode:uint):Boolean {
			return !arKeys[keyCode];
		}

		/**
		 * sets the corresponding value in the key array to true, representing the key being pressed
		 */
		private function _keyPress(e:KeyboardEvent):void {
			trace("Key Pressed: "+e.keyCode);
			arKeys[e.keyCode] = true;
		}

		/**
		 * sets the corresponding value in the key array to true, representing the key being released
		 */
		private function _keyRelease(e:KeyboardEvent):void {
			trace("Key Released: "+e.keyCode);
			arKeys[e.keyCode] = false;
		}
	}
}