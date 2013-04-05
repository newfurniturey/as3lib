/**
 * Designed to allow for the dynamic loading/embedding of external fonts.
 *
 * Usage: {{{
 *    import classes.file.font_loader;
 *    var fonts:font_loader = new font_loader("font_name.swf", ["font_name"]);
 *    fonts.addEventListener("font_loaded", callbackFunction);
 *    // -OR-
 *    var fonts:font_loader = new font_loader();
 *    fonts.add_image("font_name_1.swf", ["font_name_1"]);
 *    fonts.add_image("font_name_2.swf", ["font_name_2"]);
 *    fonts.load_fonts();
 *    fonts.addEventListener("font_loaded", callbackFunctionSingle);
 *    fonts.addEventListener("all_fonts_loaded", callbackFunctionAll);
 * }}}
 */

package classes.file {
	import classes.events.custom_event;
	import flash.display.Loader;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
    import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.text.Font;
	import flash.system.ApplicationDomain;
	
	public class font_loader extends Sprite {
		// Global vars.
		private var fonts:Array                        = new Array();
		private var font_failed:Boolean                = new Boolean(false);
		private var fontDomain:ApplicationDomain;
		private var fontURLRequest:URLRequest;
		private var fontURLLoader:Loader;
		private var loading:Boolean                    = new Boolean(false);
		private var stopped:Boolean                    = new Boolean(false);
		
		/**
		 * constructor: nuffin to construct =[
		 */
		public function font_loader(path:String=null, font_names:Array=null):void {
			stopped		= false;
			
			// set a new loader and load the passed font file
			fontURLRequest	= new URLRequest();
            fontURLLoader	= new Loader();
			
			// add a listener to the loader so when it finishes it can tell external scripts we be done
			fontURLLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, _fontComplete);
			
			// add a listener to return an I/O error if the HTTP Status is not 200
			fontURLLoader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, _handleStatus);
			
			// add a listener for any I/O errors and dispatch an event to alert the callee if one is found
			fontURLLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,
				function(e:IOErrorEvent):void {
					if (stopped) {
						return;
					}
					trace("[font_loader] Font load encountered an I/O error.");
					dispatchEvent(new custom_event("load_error", {error_info: "IO Error."}));
					font_failed = true;
					_finishLoad();
				},
				false
			);
			fontURLLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,
				function(e:SecurityErrorEvent):void {
					if (stopped) {
						return;
					}
					trace("[font_loader] Font load encountered a security error.");
					dispatchEvent(new custom_event("load_error", {error_info: "Security Error."}));
					font_failed = true;
					_finishLoad();
				},
				false
			);
			
			if ((path != null) && (font_names != null)) {
				add_font(path, font_names);
				load_fonts();
			}
		}
		
		/**
		 * adds the specified fony to the global fony array
		 */
		public function add_font(path:String, font_names:Array, font_id:Number=0):void {
			if (!_fontExists(font_names[0])) {
				var fObj:Object		= new Object();
				fObj.path			= unescape(path);
				fObj.names			= font_names;
				fObj.font_id		= font_id;
				fonts.push(fObj);
			}
		}
		
		/**
		 * checks if there are any fonts currently being loaded, or if any fonts exist in the current array
		 */
		public function is_loading():Boolean {
			return (loading || ((fonts != null) && (fonts.length > 0)));
		}
		
		/**
		 * begins loading the fonts from the global array
		 */
		public function load_fonts():void {
			// check if the loader is already running, or has been stopped
			if (loading) {
				return;
			}
			stopped = false;
			loading = true;
			
			if (fonts.length > 0) {
				// setup the fontURLRequest to use GET method (incase the font is really a dynamic page)
				fontURLRequest.url		= fonts[0].path;
				fontURLRequest.method	= URLRequestMethod.GET;
				// load the font
				trace("[font_loader] Loading font: "+fonts[0].path);
				fontURLLoader.load(fontURLRequest);
			} else {
				fonts = new Array();
				dispatchEvent(new custom_event("all_fonts_loaded"));
				trace("[font_loader] All fonts loaded.");
				loading = false;
			}
		}
		
		/**
		 * aborts all current downloads and clears the full download array
		 */
		public function stop():void {
			// check if the loader is already running or if the font array is empty, if not, well, we're done =P
			if (!loading && (fonts.length == 0)) {
				return;
			}
			stopped = true;
			fonts	= null;
			loading = false;
			trace("[font_loader] Font loading has been stopped.");
		}

		/**
		 * finishes the loading process by decreasing the number of fonts and dispatching an event
		 */
		private function _finishLoad():void {
			if (stopped) {
				font_failed		= false;
				loading			= false;
				return;
			}
			
			if (!font_failed) {
				dispatchEvent(new custom_event("font_loaded", {path: fonts[0].path, name: fonts[0].name, font_id: fonts[0].font_id}));
			}
			font_failed = false;
			fonts.shift();
			loading = false;
			// call the font loading function to check if there are more fonts to be loaded
			load_fonts();
		}

		/**
		 * attempts to register the new font
		 */
		private function _fontComplete(e:Event):void {
			if (stopped) {
				return;
			}
		
			var font_loaded:Boolean = new Boolean(true);
			try {
				fontDomain = fontURLLoader.contentLoaderInfo.applicationDomain;
				for (var i:int=0; i<(fonts[0].names).length; i++) {
					Font.registerFont(Class(fontDomain.getDefinition((fonts[0].names[i]).replace(" ", "_"))));
				}
			} catch(error:TypeError) {
				trace("[font_loader] Font load failed (error: "+error+").");
				dispatchEvent(new custom_event("load_error", {error_info: "data load error."}));
				font_loaded = false;
				font_failed = true;
			} catch(error:ArgumentError) {
				trace("[font_loader] Font load failed (error: "+error+").");
				dispatchEvent(new custom_event("load_error", {error_info: "data load error."}));
				font_loaded = false;
				font_failed = true;
			} finally {
				if (font_loaded) {
					trace("[font_loader] Font load succeeded.");
				}
			}
			_finishLoad();
        }

		/**
		 * checks the list of current fonts to see if the specified font already exists or not
		 * note: this checks only embedded fonts, not system fonts
		 */
		private function _fontExists(font:String):Boolean {
			var font_list:Array = Font.enumerateFonts(false);
	
			for (var i:int=0; i<font_list.length; i++) {
				if (font.replace("_", " ") == font_list[i].fontName) {
					// font found!
					return true;
				}
			}
			
			// font wasn't found
			return false;
		}

		/**
		 * handles the status of the file, and if it ain't 200 throw a error!! (and if it's over 0 [local file])
		 */
		private function _handleStatus(e:HTTPStatusEvent):void {
			if (stopped) {
				return;
			}
			
			if (e.status == 0) {
				trace("[font_loader] Font status unavailable (local file).");
			} else if (e.status != 200) {
				trace("[font_loader] Font HTTP status failed (Status Code: "+e.status+").");
				dispatchEvent(new custom_event("load_error", {error_info: "data load error (Status Code: "+e.status+")."}));
				font_failed = true;
			} else {
				trace("[font_loader] Font HTTP status succeeded.");
			}
		}
	}
}