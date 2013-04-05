/**
 * Creates a vertical-scrolling data panel.
 *
 * Usage: {{{
 *    var p:data_panel = new data_panel(400, 350);
 *    p.addChild(super_big_scrolly_clip);
 *    addChild(p);
 * }}}
 *
 * @note The ScrollPane component needs to be in your Library before using this class.
 */

package classes.controls {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import fl.containers.ScrollPane;
	
	public class data_panel extends MovieClip {
		// Global vars.
		private var _container:MovieClip = new MovieClip();		// container to hold all of the "clips"
		private var _scroller:ScrollPane = new ScrollPane();	// global "scroll pane" object
		
		/**
		 * constructor: sets up the data panel
		 */
		public function data_panel(width:Number, height:Number):void {
			var scroll_pane_skin:MovieClip = new MovieClip();
			_scroller.setStyle('skin', scroll_pane_skin);
			_scroller.setStyle('upSkin', scroll_pane_skin);
			_scroller.horizontalScrollPolicy = 'off';
			_scroller.setSize(width, height);
			super.addChild(_scroller);
			_scroller.source = _container;
		}
		
		/**
		 * adds the specified contents to the container
		 */
		public override function addChild(clip:DisplayObject):DisplayObject {
			_container.addChild(clip);
			_resetScrollPane();
			return clip;
		}
		
		/**
		 * adds the specified contents to the container in the specified index location
		 */
		public override function addChildAt(clip:DisplayObject, index:int):DisplayObject {
			_container.addChildAt(clip, index);
			_resetScrollPane();
			return clip;
		}
		
		/**
		 * clears all current contents from the container
		 */
		public function clear():void {
			while (_container.numChildren > 0) _container.removeChildAt(0);
			_resetScrollPane();
		}
		
		/**
		 * returns the specified child from inside the container
		 */
		public override function getChildByName(name:String):DisplayObject {
			return _container.getChildByName(name);
		}
		
		/**
		 * returns the current number of children in the container
		 */
		public override function get numChildren():int {
			return _container.numChildren;
		}
		
		/**
		 * removes the specified child from the container
		 */
		public override function removeChild(child:DisplayObject):DisplayObject {
			var obj:DisplayObject = _container.removeChild(child);
			_resetScrollPane();
			return obj;
		}
		
		/**
		 * removes the specified child from the container
		 */
		public override function removeChildAt(loc:int):DisplayObject {
			var obj:DisplayObject = _container.removeChildAt(loc);
			_resetScrollPane();
			return obj;
		}
		
		/**
		 * removes the specified child from the container
		 */
		public override function get width():Number {
			return _container.width;
		}
		
		/**
		 * resets the scrollpane so that it "captures" the new height of the content
		 */
		private function _resetScrollPane():void {
			_scroller.source = null;
			_scroller.source = _container;
			_scroller.verticalScrollPosition = 0;
			_scroller.update();
		}
	}
}