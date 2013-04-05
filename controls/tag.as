/**
 * Generates a simple tag to be used in a Tag Cloud.
 *
 * Usage: {{{
 *    var _tag:tag = new tag(tag_settings);
 *    addChild(_tag);
 * }}}
 */

package classes.controls {
	import classes.geom.simple_rectangle;
	import classes.text.text;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class tag extends MovieClip {
		// Global vars
		private var _bg:simple_rectangle		= null;
		private var _clip:MovieClip				= new MovieClip();
		private var _str:text					= null;
		private var _settings:Object			= null;

		/**
		 * constructor: create a new tag element
		 */
		public function tag(settings:Object):void {
			// create the actual tag text
			_str = new text(settings.text, _clip);
			_str.color = settings.color;
			_str.size = settings.fontSize;
			
			// create the background of the tag
			_bg = new simple_rectangle((_str.width + (settings.padding * 2)), (_str.height + (settings.padding * 2)), 0xffffff, settings.borderWidth, ((settings.borderColor == "transparent") ? 0x000000 : settings.borderColor), 0);
			_bg.bgAlpha = 0;
			_clip.addChild(_bg);
			
			if (settings.borderColor == "transparent") _bg.alpha = .001;
			_clip.setChildIndex(_clip.getChildAt(1), 0);
			_str.x = (_clip.width - _str.width) / 2;
			_str.y = (_clip.height - _str.height) / 2;
			_clip.mouseChildren = false;
			// setup the mouse listeners
			_clip.addEventListener(MouseEvent.MOUSE_OVER, _hilight, false);
			_clip.addEventListener(MouseEvent.MOUSE_OUT, _unhilight, false);			
			if (settings.url != null) {
				_clip.addEventListener(MouseEvent.CLICK, _getURL, false);
				_clip.buttonMode = true;
				_clip.useHandCursor = true;
			}
			_settings = settings;
			this.addChild(_clip);
		}

		/**
		 * the tag has been clicked
		 */
		private function _getURL(e:MouseEvent):void {
			navigateToURL(new URLRequest(_settings.url), _settings.target);
		}

		/**
		 * the tag is being hovered over
		 */
		private function _hilight(e:MouseEvent):void {
			if (_settings.borderColor != _settings.borderColorHover) _bg.color_border = (_settings.borderColorHover == "transparent") ? 0x000000 : _settings.borderColorHover;
			if (_settings.color != _settings.colorHover) _str.color = _settings.colorHover;
			_clip.setChildIndex(_clip.getChildAt(1), 0);
			if (_settings.borderColorHover == "transparent") _bg.alpha = .001;
		}

		/**
		 * the tag is no longer being hovered over
		 */
		private function _unhilight(e:MouseEvent):void {
			if (_settings.borderColor != _settings.borderColorHover) _bg.color_border = (_settings.borderColor == "transparent") ? 0x000000 : _settings.borderColor;
			if (_settings.color != _settings.colorHover) _str.color = _settings.color;
			_clip.setChildIndex(_clip.getChildAt(1), 0);
			if (_settings.borderColor == "transparent") _bg.alpha = .001;
		}
	}
}