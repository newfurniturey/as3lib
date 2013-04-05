/**
 * Allows the creation/management of custom messages.
 *
 * Usage: {{{
 *    var message_handler:message = new message(stage);
 *    message_handler.addLocation("myLocation", myLocationObj, true);
 *    dispatchEvent(new custom_event("message", {message: "This is my super awesome message!", location: "myLocation"}));
 *    // or...
 *    dispatchEvent(new custom_event("message", {message: "This is my other, kinda fun message...", x: 45, y: 90, width: 150, height: 70}));
 * }}}
 */

package classes.controls.window {
	import classes.events.custom_event;
	import classes.effects.fader;
	import classes.geom.simple_rectangle;
	import classes.text.text;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class messages extends MovieClip {
		// Global vars
		private var _default_bg_color:Number		= new Number(0xFED575);
		private var _default_border_color:Number	= new Number(0xFF8E07);
		private var _locations:Array				= new Array();
		private var _stage:Object					= null;
		private var _stage_block:MovieClip			= null;
		private var _visible:Boolean				= new Boolean(false);
		
		/**
		 * constructor: store the stage for future use
		 */
		public function messages(stage:Object):void {
			_stage = stage;
			
			// add the message event listeners to the stage
			_stage.addEventListener("message",		_display_message,	false);
			_stage.addEventListener("message_end",	_hide_message,		false);
			_stage.addChild(this);
			
			// cache this clip as a bitmap so it will work well with the mask / transparency
			this.cacheAsBitmap = true;
			
			// create the "stage blocker" that is used to overlay the entire stage so nothing can be used
			_stage_block = new MovieClip();
			var block:simple_rectangle = new simple_rectangle(_stage.stageWidth, _stage.stageHeight, 0x454545, 0, 0x000000, 0);
			_stage_block.addChild(block);
			_stage_block.alpha = .20;
		}
		
		/**
		 * adds the specified message location for future use
		 */
		public function add_location(title:String, obj:Object, animate:Boolean=true):void {
			if (_locations[title] == null) {
				_locations[title] = new Array();
				
				_locations[title]["x"]			= obj.x + 1;
				_locations[title]["y"]			= obj.y;
				_locations[title]["width"]		= obj.width;
				_locations[title]["height"]		= obj.height;
				
				var mask_clip:MovieClip = new MovieClip();
				var obj_mask:BitmapData	= new BitmapData(obj.width, obj.height, true, 0x000000);
				obj_mask.draw(DisplayObject(obj));
				var obj_mask_bmp:Bitmap = new Bitmap(obj_mask);
				mask_clip.addChild(obj_mask_bmp);
				mask_clip.cacheAsBitmap = true;
				
				_locations[title]["mask"] = mask_clip;
			} else {
				trace("[messages] Cannot add location. The specified location already exists.");
			}
		}
		
		/**
		 * displays the specified message in its specified location
		 */
		private function _display_message(e:custom_event):void {
			if (_visible) return;
			_visible = true;
			
			if (e.params.message == null) {
				trace("[messages] Error! An empty message was passed.");
				return;
			}
			
			// setup the message
			var msg_clip:MovieClip	= new MovieClip();
			var msg:text			= new text(e.params.message, msg_clip);				
			msg.wordWrap			= true;
			msg.multiline			= true;
			var bg:simple_rectangle	= null;
			var ani_end_y:Number	= new Number(0);
			
			if ((e.params.location != null) && (_locations[e.params.location] != null)) {
				var loc:Array	= _locations[e.params.location];
				msg.width		= loc["width"];
				msg_clip.x		= loc["x"];
				msg_clip.y		= loc["y"];
				msg_clip.mask	= loc["mask"];
				this.addChild(loc["mask"]);
				loc["mask"].x	= loc["x"];
				loc["mask"].y	= loc["y"];
				loc["mask"].cacheAsBitmap	= true;
				bg = new simple_rectangle((loc["width"] + 20), (msg.height + 20), ((e.params.bg_color != null) ? e.params.bg_color : _default_bg_color), 1, ((e.params.border_color != null) ? e.params.border_color : _default_border_color));
				msg_clip.addChild(bg);
				bg.x = -10;
				bg.y = -5;
			} else if (e.params.location != null) {
				trace("[messages] Error! The specified location (" + e.params.location + ") is undefined.");
				return;
			} else {
				msg.width	= (e.params.width != null)	? e.params.width	: _stage.stageWidth;
				msg_clip.x	= (e.params.x != null)		? e.params.x		: 0;
				msg_clip.y	= (e.params.y != null)		? e.params.y		: 0;
				bg = new simple_rectangle((e.params.width + 10), (msg.height + 20), ((e.params.bg_color != null) ? e.params.bg_color : _default_bg_color), 1, ((e.params.border_color != null) ? e.params.border_color : _default_border_color));
				msg_clip.addChild(bg);
				bg.x = -5;
				bg.y = -5;
				
				var obj_mask:Bitmap	= new Bitmap(new BitmapData((e.params.width), (msg.height + 10), false, 0x000000));
				obj_mask.x = e.params.x;
				obj_mask.y = e.params.y;
				this.addChild(obj_mask);
				obj_mask.cacheAsBitmap = true;
				msg_clip.mask = obj_mask;
			}				
			ani_end_y		= msg_clip.y;
			msg_clip.y		-= (msg_clip.height - 10);
			msg_clip.alpha	= .5;
			msg.y			= 5;
			bg.alpha = .65;
			msg_clip.setChildIndex(msg_clip.getChildAt((msg_clip.numChildren - 1)), 0);
			
			this.addChild(msg_clip);
			msg_clip.name			= "text_clip";
			msg_clip.cacheAsBitmap	= true;
			
			_stage.setChildIndex(this, _stage.numChildren - 1);
			
			msg_clip.addEventListener(Event.ENTER_FRAME,
				function (e:Event):void {
					if (msg_clip.y >= ani_end_y) {
						msg_clip.removeEventListener(Event.ENTER_FRAME, arguments.callee, false);
						msg_clip.y		= ani_end_y;
						msg_clip.alpha	= 1;
						dispatchEvent(new custom_event("message_displayed"));
					} else {
						msg_clip.y += 3;
						if (msg_clip.alpha < 1) {
							msg_clip.alpha += .05;
						}
					}
				},
				false
			);
		}
		
		/**
		 * hides the currently displayed message from the screen
		 */
		private function _hide_message(e:custom_event):void {
			if (!_visible || (this.numChildren == 0)) {
				dispatchEvent(new custom_event("message_removed"));
				return;
			}
			
			if ((e.params != null) && (e.params.quick_remove != null) && (e.params.quick_remove == true)) {
				_remove_message();
			} else {
				var msg_clip:Object = this.getChildAt(this.numChildren - 1);
				var ani_end_y:Number = new Number(msg_clip.y - (msg_clip.height - 10));
				msg_clip.addEventListener(Event.ENTER_FRAME,
					function (e:Event):void {
						if ((msg_clip.y <= ani_end_y) || (msg_clip.alpha <= 0)) {
							msg_clip.removeEventListener(Event.ENTER_FRAME, arguments.callee, false);
							_remove_message();
						} else {
							msg_clip.y -= 3;
							if (msg_clip.alpha > 0) {
								msg_clip.alpha -= .05;
							}
						}
					},
					false
				);
			}
		}
		
		/**
		 * removes all of the current children off of the screen
		 */
		private function _remove_message():void {
			while (this.numChildren > 0) {
				this.removeChildAt(0);
			}
			_visible = false;
			dispatchEvent(new custom_event("message_removed"));
		}
	}
}