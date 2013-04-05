/**
 * Creates a simple-to-manage dynamic button.
 *
 * Usage: {{{
 *    var btn:button = new button(upState, overState, downState); // up/over/down-State are all movieclip objects
 *    btn.addEventListener(button.CLICK, _clicked, false, 0, true);
 *    function _clicked(e:custom_event):void {
 *    	trace("Clicked!");
 *    }
 * }}}
 */

package classes.controls {
	import classes.events.custom_event;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class button extends MovieClip {
		// Global vars.
		public static var CLICK:String			= new String("buttonClick");
		private var _disabled:Boolean			= false;
		private var _downState:DisplayObject	= null;
		private var _overState:DisplayObject	= null;
		private var _upState:DisplayObject		= null;
		
		/**
		 * constructor: sets up the custom event
		 */
		public function button(upState:DisplayObject, overState:DisplayObject=null, downState:DisplayObject=null):void {
			_upState	= upState;
			_overState	= (overState != null) ? overState : _upState;
			_downState	= (downState != null) ? downState : _overState;
			
			_setupButton();
			_setupListeners();
		}
		
		/**
		 * disables the current button
		 */
		public function disable():void {
			_disabled = true;
			buttonMode = false;
			useHandCursor = false;
		}
		
		/**
		 * enables the current button
		 */
		public function enable():void {
			_disabled = false;
			buttonMode = true;
			useHandCursor = true;
		}
		
		/**
		 * listener for the mouse-click event
		 */
		private function _mouseClick(e:MouseEvent):void {
			if (_disabled) return;
			dispatchEvent(new custom_event(CLICK));
		}
		
		/**
		 * listener for the mouse-down event
		 */
		private function _mouseDown(e:MouseEvent):void {
			if (_disabled) return;
			_downState.alpha	= 1;
			_overState.alpha	= 0;
			_upState.alpha		= 0;
		}
		
		/**
		 * listener for the mouse-out event
		 */
		private function _mouseOut(e:MouseEvent):void {
			if (_disabled) return;
			_upState.alpha		= 1;
			_downState.alpha	= 0;
			_overState.alpha	= 0;
		}
		
		/**
		 * listener for the mouse-over event
		 */
		private function _mouseOver(e:MouseEvent):void {
			if (_disabled) return;
			_overState.alpha	= 1;
			_upState.alpha		= 0;
			_downState.alpha	= 0;
		}
		
		/**
		 * sets up the current button
		 */
		private function _setupButton():void {
			buttonMode = true;
			useHandCursor = true;
			addChild(_downState);
			_downState.alpha = 0;
			addChild(_overState);
			_overState.alpha = 0;
			addChild(_upState);
		}
		
		/**
		 * adds all of the required listeners for the current button
		 */
		private function _setupListeners():void {
			addEventListener(MouseEvent.MOUSE_DOWN,	_mouseDown,		false, 0, true);
			addEventListener(MouseEvent.MOUSE_OUT,	_mouseOut,		false, 0, true);
			addEventListener(MouseEvent.MOUSE_OVER,	_mouseOver,		false, 0, true);
			addEventListener(MouseEvent.MOUSE_UP,	_mouseOver,		false, 0, true);
			addEventListener(MouseEvent.CLICK,		_mouseClick,	false, 0, true);
		}
	}
}