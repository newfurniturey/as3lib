/**
 * Handles "undo" and "redo" states for whatever the case may be.
 *
 * Usage {{{
 *    var history:history_manager = new history_manager(10);
 *    history.push("Change!", (function():void { trace("im undone!"); }), (function():void { trace("im redone!"); }));
 *    history.undo();
 *    history.redo();
 * }}}
 */

package classes.utils {
	public class history_manager {
		// Global vars
		private var _index:int		= new int(-1);
		private var _max:Number		= new Number(10);
		private var _stack:Array	= new Array();
		
		/**
		 * constructor: sets up the history manager
		 */
		public function history_manager(stack_size:Number=10) {
			_max = (stack_size >= 0) ? stack_size : 10;
		}
		
		/**
		 * clears the history stack
		 */
		public function clear():void {
			_stack = new Array();
			_index = -1;
		}
		
		/**
		 * returns a boolean value for if the stack is empty or not
		 */
		public function isEmpty():Boolean {
			return (_index == -1);
		}
		
		/**
		 * returns a boolean value for if the stack is full or not
		 */
		public function isFull():Boolean {
			return ((_max > 0) && (_stack.length == _max));
		}
		
		/**
		 * add a step to the history stack using the provided undo / redo functions
		 */
		public function push(history_title:String, undo:Function, redo:Function=null):void {
			if (_index != _stack.length) {
				// the index pointer is not at the top of the stack, erase all nodes from the current point up
				_stack.splice(_index, (_stack.length - _index));
			}
		
			if (isFull()) {
				// check if the stack is full or not, if so drop the bottom step
				_stack.shift();
				_index--;
			}
			
			// get the top-most index and set the _index to it
			_index = _stack.length;
			
			// setup the new stack element
			_stack[_index]				= new Array();
			_stack[_index]["title"]		= history_title;			// title of the current step
			_stack[_index]["undo"]		= undo;						// undo function for the current step
			_stack[_index]["redo"]		= redo;						// redo function for the current step
			_stack[_index]["flag"]		= new Boolean(false);		// flag to indicate if the current history step has been "undone" or not
			
			// set the index to be right above the top-most index
			_index++;
			trace("[history_manager] Added history step \"" + history_title + "\".");
		}
		
		/**
		 * performs the undo step at the current index (if any)
		 */
		public function redo():void {
			if (_index == -1) {
				trace("[history_manager] Cannot perform redo. No history steps exist.");
				return;
			} else if ((_index == _stack.length) || !_stack[_index]["flag"]) {
				trace("[history_manager] Cannot perform redo. Nothing has been undone at the current step" + ((_index != _stack.length) ? ("(" + _stack[_index]["title"] + ")") : "") + ".");
				return;
			} else if (_stack[_index]["redo"] == null) {
				trace("[history_manager] Cannot perform redo. There is no redo function specified for the current step (" + _stack[_index]["title"] + ").");
				return;
			}
			
			trace("[history_manager] Redoing step: " + _stack[_index]["title"]);
			_stack[_index]["redo"]();
			_stack[_index]["flag"] = false;
			_index++;
		}
		
		/**
		 * performs the last-specified undo step
		 */
		public function undo():void {
			// check if there are any valid "undo" steps
			var tmp_index:int = new int(_index - 1);
			while (tmp_index >= 0) {
				if (_stack[tmp_index]["flag"]) {
					// the "current" history step has already been "undone", skip it
					tmp_index--;
				} else {
					// the "current" history step hasn't been touched yet, "undoes" it
					break;
				}
			}
			
			if (tmp_index < 0) {
				trace("[history_manager] Cannot perform undo. No history steps exist.");
				return;
			}
			_index = tmp_index;
		
			trace("[history_manager] Undoing step #" + _index + ": " + _stack[_index]["title"]);
			_stack[_index]["undo"]();
			_stack[_index]["flag"] = true;
		}
	}
}