/**
 * Designed to manage the loading of XML documents and parsing their content.
 *
 * Usage: {{{
 *    import classes.events.custom_event;
 *    import classes.file.xml_loader;
 *    var xml:xml_loader = new xml_loader();
 *    function callback(e:custom_event):void {
 *    	e.target.removeEventListener(Event.COMPLETE, callback, false);
 *    	var xml:XML = new XML(e.params.data);
 *    	trace(xml);
 *    }
 *    xml.load("my_file.xml");
 *    xml.addEventListener(Event.COMPLETE, callback, false);
 * }}}
 */

package classes.file {
	import classes.events.custom_event;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
    import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
    
    public class xml_loader extends Sprite {
		// Events
		public static var HTTP_STATUS:String             = new String("httpStatus");
		public static var FILE_LOADED:String             = new String("fileLoaded");
		public static var IO_ERROR:String                = new String("ioError");
		public static var SECURITY_ERROR:String          = new String("securityError");
		public static var STOPPED:String                 = new String("stopped");
		public static var TYPE_ERROR:String              = new String("typeError");

		// Global vars.
		private static var _events:Sprite                = new Sprite();                  // global event-dispatching tree object
		private static var _failed:Boolean               = new Boolean(false);            // flag to mark if the file loading failed or not
		private static var _files:Array                  = new Array();                   // queue to hold all files for downloading
		private static var _initialized:Boolean          = new Boolean(false);            // flag to mark when the class has been initialized
		private static var _loader:URLLoader             = null;                          // Loader object
		private static var _loading:Boolean              = new Boolean(false);            // flag to mark if an file is being loaded
		private static var _request:URLRequest           = null;                          // URLRequest object
		private static var _stopped:Boolean              = new Boolean(false);            // flag to mark if the downloading has been stopped

		/**
		 * constructor: sets up the XML Loader
		 */
		public function xml_loader():void {
			_loadSecondaryListeners();
			if (_initialized) return;
			_initialized = true;
			
			// setup a new loader to handle the XML files
			_request		= new URLRequest();
			_request.method	= URLRequestMethod.GET;
			_loader			= new URLLoader();
			// add a listener for when the file has completely loaded
			_loader.addEventListener(Event.COMPLETE,						_fileComplete,			false);
			// add a listener for when the status of the image is received
			_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS,			_handleStatus,			false);
			// add a listener for the files progress
			_loader.addEventListener(ProgressEvent.PROGRESS,				_handleProgress,		false);
			// setup listeners for any I/O or Security errors
			_loader.addEventListener(IOErrorEvent.IO_ERROR,					_handleIOError,			false);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,		_handleSecurityError,	false);
			
			dispatchEvent(new Event(Event.INIT));
			trace("[xml_loader] Initialized.");
		}
		
		/**
		 * aborts all current downloads and clears the full download array
		 */
		public function cancel():void {
			try {
				_loader.close();
			} catch (e:Error) { }
			_stopped	= true;
			_loading	= false;
			_files		= new Array();
			_events.dispatchEvent(new Event(Event.CANCEL));
			trace("[xml_loader] Cancelled.");
		}
	
		/**
		 * check if the specified XML node is empty or not by checking if it exists, it's text length, and if it has children
		 */
		public function isEmpty(node:XMLList, exists:Boolean=false):Boolean {
			var len:int = node.length();
			if (exists) return ((len == 0) ? true : false);
			var node_text:String = node.text();
			return ((len == 0) ? true : (((node_text == '') && (node.*.length() == 0)) ? true : false));
		}
		
		/**
		 * loads the top file in the queue
		 */
		public function load(file_path:String=null, id:String="", priority:Number=0):void {
			if (file_path != null) {
				_add_file(file_path, id, priority);
				return;
			} else if (_loading) {
				return;
			}
			
			// mark the flags
			_stopped = false;
			_loading = true;
			
			if (_files.length > 0) {
				// load the first file in the queue
				_request.url = _files[0].path;
				_loader.load(_request);
				trace("[xml_loader] Loading file: " + _files[0].path);
			} else {
				// all files have been loaded
				_files = new Array();
				_loading = false;
				_events.dispatchEvent(new Event(Event.COMPLETE));
				trace("[xml_loader] Complete.");
			}
		}
		
		/**
		 * pauses the current download queue
		 */
		public function pause():void {
			try {
				_loader.close();
			} catch (e:Error) { }
			_stopped	= true;
			_loading	= false;
			trace("[xml_loader] Paused.");
		}
		
		/**
		 * resumes the current download queue
		 */
		public function resume():void {
			if (_stopped && !_loading) load();
			trace("[xml_loader] Resumed.");
		}
		
		/**
		 * adds the specified file to the download queue
		 */
		private function _add_file(file_path:String=null, id:String="", priority:Number=0):void {
			if (file_path == null) return;
			
			var file:Object	= new Object();
			file.path		= unescape(file_path);		// store the file path, unescaped of course
			file.data		= null;						// setup a null container to place the loaded XML data in
			file.id			= id;						// store any specified ID
			
			if ((priority > 0) && (_files.length > 0)) {
				// we have a "top" priority so stop whatever's downloading and move this one to the front of the line
				// we will implement "stacked" priorities at a later time...we don't really care right now =P
				pause();
				_files.unshift(file);
			} else {
				// just a regular file
				_files.push(file);
			}
			load();
		}

		/**
		 * 
		 */
		private function _fileComplete(e:Event):void {
			if (_stopped) {
				// downloading has been stopped, so don't do nuthin
				return;
			}
		
			try {
				// attempt to retrieve the loaded data and store it into the tmp var
				_files[0].data = new XML(e.target.data);
			} catch(error:TypeError) {
				_events.dispatchEvent(new custom_event(TYPE_ERROR, {text: error.message, file: _files[0].path, id: _files[0].id}));
				trace("[xml_loader] Type Error. Cannot retrieve the XML data from the loaded file.");
				_failed = true;
			}
			_finishLoad();
        }

		/**
		 * finishes the loading process by decreasing the number of files and dispatching an event
		 */
		private function _finishLoad():void {
			if (_stopped) {
				// downloading is stopped, reset the flags and continue
				_failed		= false;
				_loading	= false;
				return;
			}
			
			if (!_failed) {
				// there wasn't an error, so dispatch the event to say it loaded!
				_events.dispatchEvent(new custom_event(FILE_LOADED, {file: _files[0].path, data: _files[0].data, id: _files[0].id}));
				trace("[xml_loader] File Loaded.");
			}
			
			// shift the queue and reset the flags
			_files.shift();
			_failed		= false;
			_loading	= false;
			
			// call load to check for any more files in the queue
			load();
		}

		/**
		 * handles any dispatched I/O errors by re-dispatching and then flagging an error and finishing the load
		 */
		private function _handleIOError(e:IOErrorEvent):void {
			if (_stopped) return;
			
			// dispatch the IO_ERROR
			_events.dispatchEvent(new custom_event(IO_ERROR, {text: e.text, file: _files[0].path, id: _files[0].id}));
			trace("[xml_loader] I/O Error. Cannot load XML file.");
			
			// continue loading (if available)
			_failed = true;
			_finishLoad();
		}

		/**
		 * handles the dispatched progress events by re-dispatching them for the outside
		 */
		private function _handleProgress(e:ProgressEvent):void {
			_events.dispatchEvent(e);
		}

		/**
		 * handles any dispatched Security errors by re-dispatching and then flagging an error and finishing the load
		 */
		private function _handleSecurityError(e:SecurityErrorEvent):void {
			if (_stopped) return;
			
			// dispatch the SECURITY_ERROR
			_events.dispatchEvent(new custom_event(SECURITY_ERROR, {text: e.text, file: _files[0].path, id: _files[0].id}));
			trace("[xml_loader] Security Error. Cannot load XML file.");
			
			// continue loading (if available)
			_failed = true;
			_finishLoad();
		}
		
		/**
		 * handles the status of the current xml file
		 *
		 * note: because this is thrown "in-addition-to" any complete/error messages, we only re-dispatch the event
		 * and leave error handling to the error-specific functions
		 */
		private function _handleStatus(e:HTTPStatusEvent):void {
			if (_stopped) return;
			
			// dispatch the HTTP_STATUS
			_events.dispatchEvent(new custom_event(HTTP_STATUS, {status: e.status, file: _files[0].path, id: _files[0].id}));
			trace("[xml_loader] HTTP Status Code: " + e.status);
		}

		/**
		 * setup secondary listeners for the ability to support multiple instances of the xml_loader
		 */
		private function _loadSecondaryListeners():void {
			_events.addEventListener(Event.CANCEL,				_secondaryListener, false);
			_events.addEventListener(Event.COMPLETE,			_secondaryListener, false);
			_events.addEventListener(HTTP_STATUS,				_secondaryListener, false);
			_events.addEventListener(FILE_LOADED,				_secondaryListener, false);
			_events.addEventListener(IO_ERROR,					_secondaryListener, false);
			_events.addEventListener(ProgressEvent.PROGRESS,	_secondaryListener, false);
			_events.addEventListener(SECURITY_ERROR,			_secondaryListener, false);
			_events.addEventListener(TYPE_ERROR,				_secondaryListener, false);
		}

		/**
		 * re-dispatches any dispatched event (for multiple instances of the xml_loader)
		 */
		private function _secondaryListener(e):void {
			dispatchEvent(e);
		}
    }
}