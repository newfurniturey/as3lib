/**
 * Creates a configurable and dynamic details pane with whatever content desired.
 *
 * Usage: {{{
 *    var dp:details_pane = new details_pane({container: stage, auto_hide: true, height: 250, bar_height: 25});
 *    dp.data(my_display_object, "Test Title");
 *    dp.display();
 * }}}
 *
 * @note The details pane only supports "top"/"bottom" positions, however I have the desire to create "left"/"right" positions as well.
 */

package classes.controls.window {
	import classes.controls.window.pane;
	import classes.geom.simple_rectangle;
	import classes.text.text;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class details_pane extends pane {		
		/**
		 * constructor: sets up the details pane
		 */
		public function details_pane(settings:Object):void {
			super(settings);
		}
		
		/**
		 * hides, from the displayed state, the details pane
		 */
		public override function close():void {
			if (_animating || (_current_position == "closed")) return;
			_animating = true;
			
			addEventListener(Event.ENTER_FRAME,
				function (e:Event):void {
					e.target.removeEventListener(Event.ENTER_FRAME, arguments.callee, false);
					_slide("Out", (((_settings.position == "bottom") ? 1 : -1) * ((_settings.height - _settings.bar_height) / _settings.display_speed)), ((_settings.position == "bottom") ? (_settings.container_height - _settings.bar_height) : (-_settings.height + _settings.bar_height)));
				},
				false
			);
		}
		
		/**
		 * displays, from the hidden state, the details pane
		 */
		public override function open():void {
			if (_animating || (_current_position == "open")) return;
			_animating = true;
			
			addEventListener(Event.ENTER_FRAME,
				function (e:Event):void {
					e.target.removeEventListener(Event.ENTER_FRAME, arguments.callee, false);
					_slide("In", (((_settings.position == "bottom") ? -1 : 1) * ((_settings.height - _settings.bar_height) / _settings.display_speed)), ((_settings.position == "bottom") ? (_settings.container_height - _settings.height) : 0));
				},
				false
			);
		}
		
		/**
		 * creates the show/hide button that belongs to the "control bar"
		 */
		protected override function _createButton():MovieClip {
			// create an empty clip to store the bar's "button" in
			var bar_btn:MovieClip = new MovieClip();
			
			// create the "label" that will be in the "button"
			var txt:text	= new text(((_settings.auto_hide) ? _settings.bar_btn_textShow : _settings.bar_btn_textHide), bar_btn);
			txt.color		= _settings.bar_btn_color;
			txt.bold		= _settings.bar_btn_bold;
			txt.italic		= _settings.bar_btn_italic;
			txt.underline	= _settings.bar_btn_underline;
			txt.name		= "text";
			
			// because one string can be "wider" than another, set the text (temporarily) to the opposite string and check if it has a longer width, if so, keep the width
			var tmp_width:Number = txt.width;
			txt.value = (_settings.auto_hide) ? _settings.bar_btn_textHide : _settings.bar_btn_textShow;
			if (txt.width > tmp_width) tmp_width = txt.width;
			txt.value = (_settings.auto_hide) ? _settings.bar_btn_textShow : _settings.bar_btn_textHide;
			
			// create the background for the "button"
			var btn_bg:Sprite = new simple_rectangle((tmp_width + 6), _settings.bar_height, _settings.bar_btn_bgColor, _settings.bar_btn_borderWidth, _settings.bar_btn_borderColor);
			bar_btn.addChild(btn_bg);
			btn_bg.alpha = _settings.bar_btn_bgTrans;
			btn_bg.name = "background";
			
			// re-index the background and re-position the text
			bar_btn.setChildIndex(bar_btn.getChildAt(1), 0);
			txt.x = (bar_btn.width - tmp_width) / 2;
			txt.y = (bar_btn.height - txt.height) / 2;
			bar_btn.x = (_settings.bar_btn_position == "left") ? 0 : ((_settings.bar_btn_position == "center") ? ((_settings.width - bar_btn.width) / 2) : (_settings.width - bar_btn.width));
			
			// create the "button" events
			bar_btn.buttonMode = true;
			bar_btn.useHandCursor = true;
			bar_btn.addEventListener(MouseEvent.CLICK, _toggleDisplay, false);
			return bar_btn;
		}
		
		/**
		 * loads/pre-initializes all required settings for the details pane
		 */
		protected override function _defaultSettings():Boolean {			
			// determine the default pane settings
			_settings.auto_hide		||= false;
			_settings.display_speed	||= 12;
			_settings.position		||= "bottom";
			_current_position		= (_settings.auto_hide) ? "closed" : "open";
			
			// bar settings
			_settings.bar_position = (_settings.position == "bottom") ? "top" : "bottom";
			
			// bar's button settings
			_settings.bar_btn_textHide	||= "Hide";
			_settings.bar_btn_textShow	||= "Show";
			
			// load the "pane"'s default settings
			if (!super._defaultSettings()) return false;
			
			// setup the "initial" position (this is not user-defined)
			_settings.y = (_settings.position == "bottom") ? ((_settings.auto_hide) ? (_settings.container_height - _settings.bar_height) : (_settings.container_height - _settings.height)) : ((_settings.auto_hide) ? (-_settings.height + _settings.bar_height) : 0);
			this.y = _settings.y;
			return true;
		}
		
		/**
		 * slides the details pane into the given direction, using the set steps for each interval until it reaches the end
		 */
		private function _slide(direction:String, step:Number, end:Number):void {
			this.y += step;

			if (((direction == "In") && (((_settings.position == "bottom") && (this.y <= end)) || ((_settings.position == "top") && (this.y >= end)))) || ((direction == "Out") && (((_settings.position == "bottom") && (this.y >= end)) || ((_settings.position == "top") && (this.y <= end))))) {
				// we have reached the end, finish everything up
				this.y = end;
				_current_position = (_current_position == "closed") ? "open" : "closed";
				Object(_bar.getChildByName("button")).getChildByName("text").value = (_current_position == "closed") ? _settings.bar_btn_textShow : _settings.bar_btn_textHide;
				_animating = false;
			} else {
				// still got a lil bit to go, watch for the next frame and hi-jax it!
				addEventListener(Event.ENTER_FRAME,
					function (e:Event):void {
						e.target.removeEventListener(Event.ENTER_FRAME, arguments.callee, false);
						_slide(direction, step, end);
					},
					false
				);
			}
		}
	}
}