/**
 * Creates a configurable and dynamic window pane with whatever content desired.
 *
 * Usage: {{{
 *    var p:pane = new pane({container: stage, height: 250, bar_height: 25});
 *    p.data(myClip, "Test Pane");
 *    p.open();
 * }}}
 *
 * @todo Implemenent "position" to allow for common things such as "center"/"top-center"/"bottom-right"/etc; if
 * none is chosen, do a pseudo windows-tile effect
 */

package classes.controls.window {
	import classes.geom.simple_rectangle;
	import classes.text.text;
	import fl.containers.ScrollPane;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class pane extends MovieClip {
		// Global vars
		protected var _animating:Boolean			= new Boolean(false);		// flag to indicate if we are animating or not
		protected var _bar:MovieClip				= new MovieClip();			// global "bar" object
		protected var _current_position:String		= null;						// flag to indication the current pane position
		protected var _dataBox:MovieClip			= new MovieClip();			// global "data" object
		protected var _initialized:Boolean			= new Boolean(false);		// flag to indicate if the details pane is valid or not
		protected var _scroll_pane:ScrollPane		= new ScrollPane();			// global "scroll pane" for 'long' data
		protected var _settings:Object				= null;						// global settings object
		
		/**
		 * constructor: initializes the pane object
		 */
		public function pane(settings:Object):void {
			_settings = settings;
			_initialized = _defaultSettings();
			if (_initialized) _setupScrollPane();
		}
		
		/**
		 * adds the specified data and optional title to the details pane
		 */
		public function data(clip:MovieClip, title:Object=null):void {
			if (_bar != null) {
				// remove any "existing" title
				if (_bar.getChildByName("title") != null) _bar.removeChild(_bar.getChildByName("title"));
				
				// sets up the title for the current data
				if ((title != null) && (title.text != null)) {
					var t:text = new text(title.text, _bar);
					t.color = (title.color != null) ? title.color : 0xFFFFFF;
					t.bold = ((title.bold != null) && (title.bold == "false")) ? false : true;
					t.size = 18;
					t.name = "title";
					_bar.setChildIndex(_bar.getChildAt((_bar.numChildren - 1)), (_bar.numChildren - 2));
					var btn_width:Number = _bar.getChildByName("button").width;
					t.x = (_settings.bar_btn_position == "left") ? (btn_width + 5) : 0;
					
					// check if the title is "too" long, and if so truncate it!
					if (t.width >= (_settings.width - btn_width - 20)) _truncateTitle(t, (_settings.width - btn_width - 20));
				}
			}
			
			// remove any "previous" data objects
			while (_dataBox.numChildren > 1) _dataBox.removeChildAt(1);
			
			if (clip.height > (_settings.height - 10)) {
				// add the clip to the scroll pane, and then add the scroll pane to the details pane
				_scroll_pane.source = clip;
				if (_scroll_pane.verticalScrollPosition > 0) _scroll_pane.verticalScrollPosition = 0; // reset the scroll position to 0
				_dataBox.addChild(_scroll_pane);
			} else {
				// add the clip "straight up" to the details pane
				_dataBox.addChild(clip);
				clip.x = clip.y = 5;
			}
		}
		
		/**
		 * closes, or hides, from the open state, the pane
		 */
		public function close():void {
			if (_animating || (_current_position == "closed")) return;
			_animating = true;
			addEventListener(Event.ENTER_FRAME, _close, false);
		}
		
		/**
		 * returns a boolean value representing if the pane is open or not
		 */
		public function isOpen():Boolean {
			return ((_current_position == "open") ? true : false);
		}
		
		/**
		 * opens, or displays, from the closed state, the pane
		 */
		public function open():void {
			if (_animating || (_current_position == "open")) return;
			_animating = true;
			addEventListener(Event.ENTER_FRAME, _open, false);
		}
		
		/**
		 * gets/sets the current width of the pane
		 */
		public override function get width():Number {
			return _settings.width;
		}
		public override function set width(value:Number):void {
			_settings.width = value;
			
			if (_bar != null) {
				while (_bar.numChildren > 0) {
					if (_bar.getChildAt(0).name == "button") _bar.getChildAt(0).removeEventListener(MouseEvent.CLICK, _toggleDisplay, false);
					_bar.removeChildAt(0);
				}
				_createBar();
			}
			while (_dataBox.numChildren > 0) {
				_dataBox.removeChildAt(0);
			}
			_createDataBox();
			_setupScrollPane();
		}
		
		/**
		 * hides the pane from view
		 */
		protected function _close(e:Event):void {
			this.removeEventListener(Event.ENTER_FRAME, _close, false);
			this.alpha = 0;			// set the alpha to 0 to "make it not visible"
			this.enabled = false;	// make me not usable
			this.visible = false;	// older versions of flash player require "visible" to be false
			_animating = false;
			_current_position = "closed";
		}
		
		/**
		 * creates the "control bar" for the details pane
		 */
		protected function _createBar():void {
			// create the actual "bar"
			var bar:Sprite = new simple_rectangle(_settings.width, _settings.bar_height, _settings.bar_bgColor, _settings.bar_borderWidth, _settings.bar_borderColor);
			_bar.addChild(bar);
			bar.alpha = _settings.bar_bgTrans;
			bar.name = "bar";
			
			// create the button that goes on the bar
			var bar_btn:MovieClip = _createButton();
			bar_btn.name = "button";
			_bar.addChild(bar_btn);
			
			// add the bar to the pane and position it accordingly
			addChild(_bar);
			_bar.y = (_settings.bar_position == "top") ? 0 : (_settings.height - _settings.bar_height);
		}
		
		/**
		 * creates the show/hide button that belongs to the "control bar"
		 */
		protected function _createButton():MovieClip {
			// create an empty clip to store the bar's "button" in
			var bar_btn:MovieClip = new MovieClip();
			
			// create the "label" that will be in the "button"
			var txt:text	= new text(_settings.bar_btn_textClose, bar_btn);
			txt.color		= _settings.bar_btn_color;
			txt.bold		= _settings.bar_btn_bold;
			txt.italic		= _settings.bar_btn_italic;
			txt.underline	= _settings.bar_btn_underline;
			txt.name		= "text";
			
			// create the background for the "button"
			var btn_bg:Sprite = new simple_rectangle((txt.width + 6), _settings.bar_height, _settings.bar_btn_bgColor, _settings.bar_btn_borderWidth, _settings.bar_btn_borderColor);
			bar_btn.addChild(btn_bg);
			btn_bg.alpha = _settings.bar_btn_bgTrans;
			btn_bg.name = "background";
			
			// re-index the background and re-position the text
			bar_btn.setChildIndex(bar_btn.getChildAt(1), 0);
			txt.x = (bar_btn.width - txt.width) / 2;
			txt.y = (bar_btn.height - txt.height) / 2;
			bar_btn.x = (_settings.bar_btn_position == "left") ? 0 : ((_settings.bar_btn_position == "center") ? ((_settings.width - bar_btn.width) / 2) : (_settings.width - bar_btn.width));
			
			// create the "button" events
			bar_btn.buttonMode = true;
			bar_btn.useHandCursor = true;
			bar_btn.addEventListener(MouseEvent.CLICK, _toggleDisplay, false);
			return bar_btn;
		}
		
		/**
		 * creates the "data box" that holds all of the actual data for the details pane
		 */
		protected function _createDataBox():void {
			var bg:Sprite = new simple_rectangle(_settings.width, (_settings.height - ((_bar != null) ? _settings.bar_height : 0)), _settings.bgColor, _settings.borderWidth, _settings.borderColor, _settings.borderCurve);
			_dataBox.addChild(bg);
			bg.alpha = _settings.bgTrans;
			bg.name = "background";
			_dataBox.y = ((_bar != null) && (_settings.bar_position == "top")) ? _bar.height : 0;
			addChild(_dataBox);
		}
		
		/**
		 * loads/pre-initializes all required settings for the details pane
		 */
		protected function _defaultSettings():Boolean {
			// validate if there is a container
			if (_settings.container == null) return false;
			
			// determine the default pane settings
			try {
				_settings.container_height = (_settings.container.height) ? _settings.container.height : _settings.container.stageHeight;
			} catch (e:ReferenceError) {
				// reference error occurs the container doesn't have a height, or a stageHeight (stageHeight throws the error)
				_settings.container_height = _settings.height;
			}
			try {
				_settings.container_width = (_settings.container.width) ? _settings.container.width : _settings.container.stageWidth;
			} catch (e:ReferenceError) {
				// reference error occurs the container doesn't have a width, or a stageWidth (stageWidth throws the error)
				_settings.container_width = _settings.width
			}
			_settings.height		||= _settings.container_height;
			_settings.width			||= _settings.container_width;
			_settings.borderColor	||= 0x000000;
			_settings.borderCurve	||= 0;
			_settings.borderWidth	||= 0;
			_current_position		= "closed";
			_settings.bgColor		||= 0x000000;
			_settings.bgTrans		= ((_settings.bgTrans != null) && (_settings.bgTrans != "transparent")) ? _settings.bgTrans : 0;
			
			if (_settings.bar_height > 0) {
				// bar settings
				_settings.bar_bgColor		||= 0x000000;
				_settings.bar_bgTrans		||= 0;
				_settings.bar_borderWidth	||= 0;
				_settings.bar_borderColor	||= 0x000000;
				_settings.bar_height		||= 25;
				_settings.bar_position		||= "top";
				
				// bar's button settings
				_settings.bar_btn_bgColor	||= 0x000000;
				_settings.bar_btn_bgTrans	||= 0;
				_settings.bar_btn_color		= (_settings.bar_btn_color != null) ? _settings.bar_btn_color : 0xffffff;
				_settings.bar_btn_bold		= ((_settings.bar_btn_bold != null) && (_settings.bar_btn_bold == true)) ? true : false;
				_settings.bar_btn_italic	= ((_settings.bar_btn_italic != null) && (_settings.bar_btn_italic == true)) ? true : false;
				_settings.bar_btn_position	||= "right";
				_settings.bar_btn_textClose	||= "X";
				_settings.bar_btn_underline	= ((_settings.bar_btn_underline != null) && (_settings.bar_btn_underline == true)) ? true : false;
			
				// create the "bar"
				_createBar();
			} else {
				// no bar height was specified, don't set one up =]
				_bar = null;
			}
			
			// setup the "initial" position (this is not user-defined)
			this.x = _settings.x = (_settings.container_width - _settings.width) / 2;
			this.y = _settings.y = (_settings.container_height - _settings.height) / 2;
			
			// create the "data box" for quick-loading
			_createDataBox();
			return true;
		}
		
		/**
		 * makes the pane visible
		 */
		protected function _open(e:Event):void {
			this.removeEventListener(Event.ENTER_FRAME, _open, false);
			this.alpha = 1;			// set the alpha to 1 to "make it visible"
			this.enabled = true;	// make me usable again
			this.visible = true;	// well...just make it visible already!
			_animating = false;
			_current_position = "open";
		}
		
		/**
		 * sets up the scroll pane that holds "extra large" data clips in the data box
		 */
		protected function _setupScrollPane():void {
			// setup the "blank" skin for the scroll pane
			var scroll_pane_skin:MovieClip = new MovieClip();
			_scroll_pane.setStyle("skin",	scroll_pane_skin);
			_scroll_pane.setStyle("upSkin",	scroll_pane_skin);
			
			// setup the size of the scroll pane and position it accordingly
			_scroll_pane.width = (_settings.width - 10); // the "-10" is to give a 5px/5px padding appearance inside the pane
			_scroll_pane.height = (_settings.height - _settings.bar_height - 10);
			_scroll_pane.move(5, 5);
		}
		
		/**
		 * toggle the current display state between closed/open
		 */
		protected function _toggleDisplay(e:MouseEvent):void {
			switch (_current_position) {
				case "closed":	open();		break;
				case "open":	close();	break;
			}
		}
		
		/**
		 * truncates the title to be the maximum width
		 */
		protected function _truncateTitle(t:text, max_width:Number):void {
			var tmp:String = new String();
			while (t.width >= max_width) {
				// we're too long, take off another letter
				tmp = t.value;
				t.value = ((tmp).substr(0, (tmp.length - 1)));
			}
			t.value += '...';
		}
	}
}