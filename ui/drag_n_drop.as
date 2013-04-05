/**
 * Handles dragging objects, as well as drop targets. This has been built on top of the original "drag" class.
 *
 * Usage {{{
 *    var dragNDrop:drag_n_drop = new drag_n_drop(stage);
 *    dragNDrop.returnHome = true;
 *    dragNDrop.snapCenter = true;
 *    var drags:Array = new Array(drag1, drag2, drag3);
 *    var drops:Array = new Array(drop1, drop2, drop3);
 *    for (var i:int=0; i<drags.length; i++)	dragNDrop.addDragObject(drags[i]);
 *    for (i=0; i<drops.length; i++)			dragNDrop.addDropTarget(drops[i]);
 * }}}
 */

package classes.ui {
	import classes.events.custom_event;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class drag_n_drop {
		// events
		public static var DRAG_START:String				= new String("dragStarted");
		public static var DRAG_STOP:String				= new String("dragStopped");
		
		// Global vars
		private var _bounds:Rectangle					= null;								// boundary container
		private var _dragObjects:Array					= new Array();						// stack of draggable items
		private var _dropTargets:Array					= new Array();						// stack of drop targets
		private var _enabled:Boolean					= new Boolean(true);				// flag to indicate if dragging is enabled
		private var _returnHome:Boolean					= new Boolean(false);				// flag to indicate if we will "return" to the starting position
		private var _snapCenter:Boolean					= new Boolean(false);				// flag to indicate if we will "snap" to the center
		private var _stage:Object						= null;								// global "stage" object
		
		/**
		 * constructor: sets up the drag_n_drop object
		 */
		public function drag_n_drop(stage:Object, bound_rec:Rectangle=null) {
			_bounds = bound_rec;
			_stage = stage;
		}

		/**
		 * adds a drag object to the current drag_n_drop object
		 */
		public function addDragObject(obj:Object):void {
			// create a new "object" that will hold all of the object's current information
			var tmp:Object = new Object();
			tmp.object	= obj;
			tmp.x_start	= obj.x;
			tmp.y_start = obj.y;
			tmp.parent = -1;
			_dragObjects.push(tmp);
			
			// setup the object's main settings
			obj.mouseChildren	= false;
			obj.buttonMode		= true;
			obj.useHandCursor	= true;
			obj.addEventListener(MouseEvent.MOUSE_DOWN, _startDrag, false);
		}

		/**
		 * adds a drop target to the list of all available drop targets =]
		 */
		public function addDropTarget(obj:Object):void {
			// create a new "object" that will hold the new drop target's information
			var tmp:Object = new Object();
			tmp.target = obj;
			tmp.child = -1;
			_dropTargets.push(tmp);
		}

		/**
		 * gets/sets the current "enabled" flag
		 */
		public function get enabled():Boolean {
			return _enabled;
		}
		public function set enabled(value:Boolean):void {
			_enabled = value;
		}

		/**
		 * gets/sets the current "return home" flag
		 */
		public function get returnHome():Boolean {
			return _returnHome;
		}
		public function set returnHome(value:Boolean):void {
			_returnHome = value;
		}

		/**
		 * gets/sets the current "snap center" flag
		 */
		public function get snapCenter():Boolean {
			return _snapCenter;
		}
		public function set snapCenter(value:Boolean):void {
			_snapCenter = value;
		}

		/**
		 * finds the current "position" of the specified drag object
		 */
		private function _findDragObj(obj:MovieClip):Number {
			for (var i:int=0; i<_dragObjects.length; i++) if (_dragObjects[i].object == obj) return i;
			return -1;
		}

		/**
		 * determines if a drop target has been hit or not
		 */
		private function _findDropTarget(pos:Number):Number {
			var found:Boolean = new Boolean(false);
			for (var i:int=0; i<_dropTargets.length; i++) {
				var hit:Boolean = _dropTargets[i].target.hitTestObject(_dragObjects[pos].object);
				if (hit && (_dropTargets[i].child == -1)) {
					// we have a legitamite hit
					if (_dragObjects[pos].parent > -1) _dropTargets[_dragObjects[pos].parent].child = -1;
					_dragObjects[pos].parent = i;
					_dropTargets[i].child = pos;
					found = true;
					break;
				} else if (hit && (_dragObjects[pos].parent > -1)) {
					// we have a legitamite hit, but we need to swap two elements that are on top of drop targets
					// swap the "parents"
					var tmp_parent:Number = _dragObjects[pos].parent;
					_dragObjects[pos].parent = i;
					_dragObjects[_dropTargets[i].child].parent = tmp_parent; 
					// swap the "children"
					var tmp_child:Number = _dropTargets[i].child;
					_dropTargets[i].child = pos;
					_dropTargets[tmp_parent].child = tmp_child;
					// reposition the "swapped" clip
					var tmp_obj = _dragObjects[_dropTargets[tmp_parent].child];
					tmp_obj.object.x = (_dropTargets[tmp_parent].target.x + ((_dropTargets[tmp_parent].target.width - tmp_obj.object.width) / 2));
					tmp_obj.object.y = (_dropTargets[tmp_parent].target.y + ((_dropTargets[tmp_parent].target.height - tmp_obj.object.height) / 2));
					// re-dispatch a "drag stop" event for the "swapped" clip so any external listeners know it moved
					dispatchEvent(new custom_event(DRAG_STOP, {target: tmp_obj, drop_target: _dropTargets[tmp_parent].target, originX: _dragObjects[pos].object.x, originY: _dragObjects[pos].object.y, x: tmp_obj.object.x, y: tmp_obj.object.y}));
					found = true;
					break;
				}
			}
			return ((found) ? i : -1);
		}
		
		/**
		 * starts the dragging actions of the object and sets the boundary box to that specified
		 */
		private function _startDrag(e:MouseEvent):void {
			if (!_enabled) return;
			// add the mouse-up listener to the stage incase the user goes "outside" of the boundary box (if any)
			_stage.addEventListener(MouseEvent.MOUSE_UP, _stopDrag, false);
			
			var clip:Number = _findDragObj(MovieClip(e.target));
			// dispatch an event to say that dragging has started
			dispatchEvent(new custom_event(DRAG_START, {target: _dragObjects[clip].object, x: _dragObjects[clip].object.x, y: _dragObjects[clip].object.y});
			_dragObjects[clip].object.parent.addChild(_dragObjects[clip].object);
			
			// mark the starting parameters
			_dragObjects[clip].x_start = _dragObjects[clip].object.x;
			_dragObjects[clip].y_start = _dragObjects[clip].object.y;
			
			// start the dragging!
			var w:Number = new Number(_dragObjects[clip].object.width);
			var h:Number = new Number(_dragObjects[clip].object.height);
			_dragObjects[clip].object.startDrag(false, ((_bounds != null) ? new Rectangle((_bounds.x+(w/2)), (_bounds.y+(h/2)), (_bounds.width-w), (_bounds.height-h)) : null));
		}
		
		/**
		 * ends the draggins actions of the object
		 */
		private function _stopDrag(e:MouseEvent):void {
			_stage.removeEventListener(MouseEvent.MOUSE_UP, _stopDrag, false);
			
			var clip:Number = _findDragObj(MovieClip(e.target));
			var dropped:Number = _findDropTarget(clip);
			
			if (dropped > -1) {
				// drop target has been hit
				if (_snapCenter) {
					_dragObjects[clip].object.x = (_dropTargets[dropped].target.x + ((_dropTargets[dropped].target.width - _dragObjects[clip].object.width) / 2));
					_dragObjects[clip].object.y = (_dropTargets[dropped].target.y + ((_dropTargets[dropped].target.height - _dragObjects[clip].object.height) / 2));
				}
			} else if (_returnHome) {
				// snap the object back to its starting point
				_dragObjects[clip].object.x = _dragObjects[clip].x_start;
				_dragObjects[clip].object.y = _dragObjects[clip].y_start;
			}
			
			// mark the ending parameters
			_dragObjects[clip].x_end = _dragObjects[clip].object.x;
			_dragObjects[clip].y_end = _dragObjects[clip].object.y;
			
			// dispatch the "stopped" event and stop the dragging!
			dispatchEvent(new custom_event(DRAG_STOP, {target: _dragObjects[clip].object, drop_target: ((dropped > -1) ? _dropTargets[dropped].target : null), originX: _dragObjects[clip].x_start, originY: _dragObjects[clip].y_start, x: _dragObjects[clip].x_end, y: _dragObjects[clip].y_end}));
			_dragObjects[clip].object.stopDrag();
		}
	}
}