/**
 * Handles dragging events on created objects.
 *
 * Usage {{{
 *    var dragger:drag;
 *    dragger = new drag(stage, movie_clip, [new Rectangle([x], [y], [width], [height])]);
 * }}}
 */

package classes.ui {
	import classes.custom_event;
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
	
	public class drag {
		// Global vars
		private var bounds:Rectangle;
		private var _obj:Object;
		private var _params:Object = {x_start: 0, y_start: 0, x_end: 0, y_end: 0};
		private var _pseudo_obj:Object;
		private var _stage:Object;
		
		/**
		 * constructor: sets up the drag object
		 */
		public function drag(stage:Object, obj:Object, bound_rec:Rectangle=null, pseudo_obj:Object=null) {
			bounds				= bound_rec;
			_obj				= obj;
			_obj.mouseChildren	= false;
			_obj.buttonMode		= true;
			_obj.useHandCursor	= true;
			_pseudo_obj			= pseudo_obj;
			_stage				= stage;
			
			// setup the mouse-down listener for the main object
			_obj.addEventListener(MouseEvent.MOUSE_DOWN, _startDrag, false);
		}
		
		/**
		 * remove the drag properties from the specified object
		 */
		public function remove(obj:Object) {
			obj.removeEventListener(MouseEvent.MOUSE_DOWN, _startDrag, false);
			obj.mouseChildren	= true;
			obj.buttonMode		= false;
			obj.useHandCursor	= false;
		}
		
		/**
		 * starts the dragging actions of the object and sets the boundary box to that specified
		 */
		private function _startDrag(e:MouseEvent):void {
			// add the mouse-up listener to the stage incase the user goes "outside" of the boundary box (if any)
			_stage.addEventListener(MouseEvent.MOUSE_UP, _stopDrag, false);
			
			// dispatch an event to say that dragging has started
			_obj.dispatchEvent(new custom_event("drag_started"));
			
			// mark the starting parameters
			_params.x_start = _obj.x;
			_params.y_start = _obj.y;
			
			// start the dragging!
			var w:Number = new Number(((_pseudo_obj != null) ? _pseudo_obj.width : _obj.width));
			var h:Number = new Number(((_pseudo_obj != null) ? _pseudo_obj.height : _obj.height));
			if (_pseudo_obj != null) {
				_pseudo_obj.startDrag(false, ((bounds != null) ? new Rectangle((bounds.x+(w/2)), (bounds.y+(h/2)), (bounds.width-w), (bounds.height-h)) : null));
			} else {
				_obj.startDrag(false, ((bounds != null) ? new Rectangle((bounds.x+(w/2)), (bounds.y+(h/2)), (bounds.width-w), (bounds.height-h)) : null));
			}
		}
		
		/**
		 * ends the draggins actions of the object
		 */
		private function _stopDrag(e:MouseEvent):void {
			_stage.removeEventListener(MouseEvent.MOUSE_UP, _stopDrag, false);
			
			// mark the ending parameters
			_params.x_end = _obj.x;
			_params.y_end = _obj.y;
			
			// dispatch the "stopped" event and stop the dragging!
			_obj.dispatchEvent(new custom_event("drag_stopped", _params));
			if (_pseudo_obj != null) {
				_pseudo_obj.stopDrag();
			} else {
				_obj.stopDrag();
			}
		}
	}
}