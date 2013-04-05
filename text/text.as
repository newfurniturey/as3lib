/**
 * Handles creating dynamic text fields within a movie.
 *
 * @deprecated In favor of rewriting to be more compact.
 *
 * Usage {{{
 *    myText:text = new text("foo bar", [stage]);
 * }}}
 */

package classes.text {
	import classes.effects.arc;
	import classes.utils.string;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class text extends MovieClip {
		// Global vars
		private var _antiAliasType:String		= new String(AntiAliasType.ADVANCED);
		private var _arc:Number					= new Number(0);
		private var _autoSize:String			= new String(TextFieldAutoSize.LEFT);
		private var _background:Boolean			= new Boolean(false);
		private var _backgroundColor:Number		= new Number(0x000000);
		private var _bold:Boolean				= new Boolean(false);
		private var _color:Number				= new Number(0x000000);
		private var _embedFonts:Boolean			= new Boolean(false);
		private var _font:String				= new String("Verdana");
		private var _italic:Boolean				= new Boolean(false);
		private var _mouseEnabled:Boolean		= new Boolean(false);
		private var _multiline:Boolean			= new Boolean(false);
		private var _selectable:Boolean			= new Boolean(false);
		private var _size:Number				= new Number(12);
		private var _thickness:Number			= new Number(0);
		private var _underline:Boolean			= new Boolean(false);
		private var _wordWrap:Boolean			= new Boolean(false);
		private var _width:Number				= new Number(-1);
		private var _archer:arc					= new arc;
		private var _halt_drawing:Boolean		= new Boolean(false);
		private var _parent:Object				= null;
		private var _text:String				= null;
		private var _tmpText:String				= null;
		private var text_bitmap:Bitmap			= null;
		private var text_format:TextFormat		= new TextFormat();
		private var text_string:TextField		= null;
		
		/**
		 * creates a new dynamic text field
		 */
		public function text(string:String=null, clip_obj:Object=null):void {
			if ((string == null) && (clip_obj == null)) {
				// normally used when converting a TextField into a text type
				return;
			}
			
			_archer.addEventListener(Event.COMPLETE,
				function (e:Event):void {
					_halt_drawing = false;
				},
				false
			);
			
			_text = string;
			_tmpText = string;
			
			this.addEventListener(Event.ENTER_FRAME,
				function (e:Event):void {
					removeEventListener(Event.ENTER_FRAME, arguments.callee, false);
					_format();
				},
				false
			);
			
			// check if a parent container has been specified, if so draw away!
			_parent = clip_obj;
			if (_parent != null) {
				_parent.addChild(this);
			}
		}
		
		/**
		 * returns/sets the value of the text's arc angle
		 */
		public function get arch():Number {
			return _arc;
		}
		public function set arch(value:Number):void {
			_arc = value;
			_format();
		}
		
		/**
		 * returns/sets the value of the background of the text
		 */
		public function get background():Boolean {
			return _background;
		}
		public function set background(value:Boolean):void {
			_background = value;
			_format();
		}
		
		/**
		 * returns/sets the value of the background color of the text
		 */
		public function get backgroundColor():Number {
			return _backgroundColor;
		}
		public function set backgroundColor(value:Number):void {
			_backgroundColor = value;
			_format();
		}
		
		/**
		 * returns/sets the value of the bold of the text
		 */
		public function get bold():Boolean {
			return _bold;
		}
		public function set bold(value:Boolean):void {
			_bold = value;
			_format();
		}
		
		/**
		 * returns/sets the value of the color of the text
		 */
		public function get color():Number {
			return _color;
		}
		public function set color(value:Number):void {
			_color = value;
			_format();
		}
		
		/**
		 * converts the specified TextField into an editable text type
		 */
		public function convert(field:TextField):void {
			//text_string = field;
			//text_format = text_string.getTextFormat();
		}
		
		/**
		 * returns/sets the value of the text being enabled or not
		 */
		public override function get mouseEnabled():Boolean {
			return _mouseEnabled;
		}
		public override function set mouseEnabled(value:Boolean):void {
			_mouseEnabled = value;
			_format();
		}
		
		/**
		 * returns/sets the value of embedFonts
		 */
		public function get embedFonts():Boolean {
			return _embedFonts;
		}
		public function set embedFonts(value:Boolean):void {
			_embedFonts = value;
			_format();
		}
		
		/**
		 * returns/sets the current font name
		 */
		public function get font():String {
			return _font;
		}
		public function set font(value:String):void {
			_font = value;
			_format();
		}
		
		/**
		 * returns/sets the value of the italic of the text
		 */
		public function get italic():Boolean {
			return _italic;
		}
		public function set italic(value:Boolean):void {
			_italic = value;
			_format();
		}
		
		/**
		 * returns/sets the value of the text's multiline
		 */
		public function get multiline():Boolean {
			return _multiline;
		}
		public function set multiline(value:Boolean):void {
			_multiline = value;
			_format();
		}
		
		/**
		 * nullifies the current text object
		 */
		public function remove():void {
			_parent.removeChild(this);
		}
		
		/**
		 * performs a string replace on the current text using the specified expression
		 */
		public function replace(pattern:RegExp, replace:String):void {
			if (_text != null) {
				_text = _text.replace(pattern, replace);
				_tmpText = _text;
				_format();
			}
		}
		
		/**
		 * returns/sets the value of the size of the text
		 */
		public function get size():Number {
			return _size;
		}
		public function set size(value:Number):void {
			_size = value;
			_format();
		}
		
		/**
		 * performs a string replace on the current text using the specified search/replace modifiers
		 */
		public function str_replace(search:Object, replace:Object):void {
			if (_text != null) {
				var str:string = new string();
				_text = str.str_replace(search, replace, _text);
				_tmpText = _text;
				_format();
			}
		}
		
		/**
		 * returns/sets the value of the thickness of the text
		 */
		public function get thickness():Number {
			return _thickness;
		}
		public function set thickness(value:Number):void {
			_thickness = value;
			_format();
		}
		
		/**
		 * returns/sets the value of the underline of the text
		 */
		public function get underline():Boolean {
			return _underline;
		}
		public function set underline(value:Boolean):void {
			_underline = value;
			_format();
		}
		
		/**
		 * returns/sets the value of the current text sprite
		 */
		public function get value():String {
			return _text;
		}
		public function set value(string:String):void {
			_text = string;
			_tmpText = _text;
			_format();
		}
		
		/**
		 * returns/sets the value of the text's width
		 */
		public override function get width():Number {
			return _width;
		}
		public override function set width(value:Number):void {
			_width = value;
			_tmpText = _text; // because width can shrink or grow, and text can already be truncated, reset the text for resizing!
			_format();
		}
		
		/**
		 * returns/sets the value of the text's wordWrap
		 */
		public function get wordWrap():Boolean {
			return _wordWrap;
		}
		public function set wordWrap(value:Boolean):void {
			_wordWrap = value;
			_tmpText = _text; // text can be truncated, but now with word-wrap we can allow for more!
			_format();
		}
		
		/**
		 * draws the text using bitmap data, this way arcing is possible
		 */
		private function _draw_text():void {
			if (_halt_drawing) return;
			
			if (_arc == 0) {
				// add the "regular" text string
				if (this.numChildren > 0) {
					this.removeChildAt(0);
				}
				this.addChild(text_string);
			} else {
				_drawing_start();
				// add the arced bitmap data
				try {
					var txt_bmp:BitmapData = new BitmapData(text_string.width, text_string.height, true, 0x00000000);
					txt_bmp.draw(text_string);
					text_bitmap = new Bitmap(txt_bmp);
				} catch (e:ArgumentError) {
					return;
				}
				
				var new_bmp:MovieClip = _archer.arc_object(text_bitmap, _arc);
				if (new_bmp != null) {
					this.removeChildAt(0);
					this.addChild(new_bmp);
				}
			}
		}
		
		/**
		 * marks the flag that drawing is currently taking place
		 */
		private function _drawing_start():void {
			_halt_drawing = true;
		}
		
		/**
		 * sets the current format of the text
		 */
		private function _format():void {
			if (_tmpText != null) {
				if (text_string == null) {
					text_string = new TextField();
				}
				text_string.antiAliasType 		= _antiAliasType;
				text_string.autoSize			= _autoSize;
				text_string.background			= _background;
				text_string.backgroundColor 	= _backgroundColor;
				text_string.embedFonts			= _embedFonts;
				text_string.mouseEnabled		= _mouseEnabled;
				text_string.multiline			= _multiline;
				text_string.selectable			= _selectable;
				text_string.thickness			= _thickness;
				text_string.wordWrap			= _wordWrap;
				//
				text_format.color				= _color;
				text_format.font				= _font;
				text_format.size				= _size;
				text_format.underline			= _underline;
				text_format.italic				= _italic;
				text_format.bold				= _bold;
				//
				text_string.text				= _tmpText;
				//
				text_string.defaultTextFormat	= text_format;
				//
				text_string.setTextFormat(text_format);
				//
				text_string.width = _width;
				if ((_width > 0) && (text_string.width > _width) && !_wordWrap) {
					_tmpText = _text.substr(0, _tmpText.length - ((_tmpText.substr(_tmpText.length - 3) == '...') ? 4 : 1)) + '...';
					_format();
					return;
				}				
				_draw_text();
			}
		}
	}
}