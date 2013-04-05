/**
 * Allows the creation/dispatching of custom events.
 *
 * Usage: {{{
 *    this.addEventListener("test_event", callbackFunction);
 *    this.dispatchEvent(new custom_event("test_event", {param1: "test parameter 1", param2: "test parameter 2"}));
 * }}}
 */

package classes.events {
	import flash.events.Event;
	
	public class custom_event extends Event {
		// Global vars.
		public var params:Object = null;
		
		/**
		 * constructor: sets up the custom event
		 */
		public function custom_event(type:String, parameters:Object = null, bubbles:Boolean = false, cancelable:Boolean = false):void {
			super(type, bubbles, cancelable);
			this.params = parameters;
		}
		
		/**
		 * creates a duplicate instance of the current event
		 */
		public override function clone():Event {
			return new custom_event(type, this.params, bubbles, cancelable);
		}
	}
}