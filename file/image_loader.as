/**
 * Designed to handle/manage image loading operations.
 *
 * Usage: {{{
 *    var images:image_loader = new image_loader();
 *    var my_container:MovieClip = new MovieClip();
 *    images.load("my_image.jpg", my_container);
 *    stage.add(my_container);
 * }}}
 */

package classes.file {
	import classes.events.custom_event;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
    import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.Timer;
    
    public class image_loader extends Sprite {
		// Events
		public static var HTTP_STATUS:String    = new String("httpStatus");
		public static var IMAGE_LOADED:String   = new String("imageLoaded");
		public static var IO_ERROR:String       = new String("ioError");
		public static var SECURITY_ERROR:String = new String("securityError");
		public static var STOPPED:String        = new String("stopped");
		public static var TYPE_ERROR:String     = new String("typeError");
		// Global vars.
		private static var _events:Sprite                 = new Sprite();           // global sprite to christmas-tree out events
		private static var _failed:Boolean                = new Boolean(false);     // flag to mark if the image loading failed or not
		private static var _images:Array                  = new Array();            // queue to hold all images for downloading
		private static var _initialized:Boolean           = new Boolean(false);     // flag to mark when the class has been initialized
		private static var _loader:Loader                 = null;                   // Loader object
		private static var _loading:Boolean               = new Boolean(false);     // flag to mark if an image is being loaded
		private static var _request:URLRequest            = null;                   // URLRequest object
		private static var _stopped:Boolean               = new Boolean(false);     // flag to mark if the downloading has been stopped
		private static var _timer:Timer                   = null;                   // backup timer that insures all images are downloaded
		private static var _timerCount:Number             = 0;                      // the current tick # the timer is on
		private static var _timerIntervalMax:Number       = 5000;                   // the max length of time for the timer to run after all images are finished
		private static var _timerImageIntervalMax:Number  = 1000;                   // the max length of time for an image to download without any progress
		private static var _timerInterval:Number          = 250;                    // the interval each timer tick should execute at
		private static var _timerCurrentImage:String      = null;                   // flag to hold the name of the current image
		private static var _timerCurrentBytes:Number      = -1;                     // flag to hold the current # of bytes loaded
		private static var _timerCurrentImageCount:Number = 0;                      // the current count # the current image has passed

		/**
		 * constructor: begins loading the specified image file (if any)
		 */
        public function image_loader():void {
			_init();
		}
		
		/**
		 * aborts all current downloads and clears the full download array
		 */
		public function cancel():void {
			try {
				_loader.close();
				_loader.unload();
			} catch (e:Error) { }
			_stopped	= true;
			_loading	= false;
			_images		= new Array();
			_events.dispatchEvent(new Event(Event.CANCEL));
			trace("[image_loader] Cancelled.");
		}
		
		/**
		 * loads the top image in the queue
		 */
		public function load(image_path:String=null, container:DisplayObject=null, id:String=null, priority:Number=0):void {
			if (image_path != null) {
				// before loading, add the specified image information into the queue
				_add_image(image_path, container, id, priority);
				return;
			} else if (_loading) {
				// we are already loading, wait your turn!
				return;
			}
			
			// mark the flags
			_stopped = false;
			_loading = true;
			
			if (_images.length > 0) {
				// load the first image in the queue
				_request.url = _images[0].path;
				_loader.load(_request);
				trace("[image_loader] Loading image: " + _images[0].path);
			} else {
				// all images have been loaded
				_images = new Array();
				_loading = false;
				_events.dispatchEvent(new Event(Event.COMPLETE));
				trace("[image_loader] Complete.");

				if (!_timer.running) _timer.start();
			}
		}
		
		/**
		 * pauses the current download queue
		 */
		public function pause():void {
			try {
				_loader.close();
				_loader.unload();
			} catch (e:Error) { }
			_stopped	= true;
			_loading	= false;
			trace("[image_loader] Paused.");
		}
		
		/**
		 * resumes the current download queue
		 */
		public function resume():void {
			if (_stopped && !_loading) load();
			trace("[image_loader] Resumed.");
		}
		
		/**
		 * adds the specified image to the download queue
		 */
		private function _add_image(image_path:String=null, container:DisplayObject=null, id:String=null, priority:Number=0):void {
			if (image_path == null) return;
			
			var image:Object	= new Object();
			image.path			= unescape(image_path);		// store the image path, unescaped of course
			image.container		= container;				// store the container to place the image into
			image.id			= id;						// store any specified ID
			image.index			= -1;						// the images index within the container
			
			if ((priority > 0) && (_images.length > 0)) {
				// we have a "top" priority so stop whatever's downloading and move this one to the front of the line
				// we will implement "stacked" priorities at a later time...we don't really care right now =P
				_images.splice(1, 0, image);
			} else {
				// just a regular image
				_images.push(image);
			}
			load();
		}

		/**
		 * finishes the loading process by decreasing the number of images and dispatching an event
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
				_events.dispatchEvent(new custom_event(IMAGE_LOADED, {image: _images[0].path, container: _images[0].container, id: _images[0].id, index: _images[0].index, content: _images[0].content}));
				trace("[image_loader] Image Loaded.");
			}
			
			// shift the queue and reset the flags
			_images.shift();
			_failed		= false;
			_loading	= false;
			
			// call load to check for any more images in the queue
			load();
		}

		/**
		 * handles any dispatched I/O errors by re-dispatching and then flagging an error and finishing the load
		 */
		private function _handleIOError(e:IOErrorEvent):void {
			if (_stopped) return;
			
			// dispatch the IO_ERROR
			_events.dispatchEvent(new custom_event(IO_ERROR, {text: e.text, image: _images[0].path, id: _images[0].id}));
			trace("[image_loader] I/O Error. Cannot load image.");
			
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
			_events.dispatchEvent(new custom_event(SECURITY_ERROR, {text: e.text, image: _images[0].path, id: _images[0].id}));
			trace("[image_loader] Security Error. Cannot load image.");
			
			// continue loading (if available)
			_failed = true;
			_finishLoad();
		}

		/**
		 * handles the status of the current image
		 *
		 * note: because this is thrown "in-addition-to" any complete/error messages, we only re-dispatch the event
		 * and leave error handling to the error-specific functions
		 */
		private function _handleStatus(e:HTTPStatusEvent):void {
			if (_stopped) return;
			
			// dispatch the HTTP_STATUS
			_events.dispatchEvent(new custom_event(HTTP_STATUS, {status: e.status, image: _images[0].path, id: _images[0].id}));
			trace("[image_loader] HTTP Status Code: " + e.status);
		}

		/**
		 * attempts to put the loaded image into the specified container
		 */
		private function _imageComplete(e:Event):void {
			if (_stopped) {
				// downloading has been stopped, so don't do nuthin
				return;
			} else if (_images[0].container == null) {
				// there is no specified container to put the image, most likely because this was just to pre-load the image
				_finishLoad();
				return;
			}
		
			try {
				// add the image child and send out a signal to alert external scripts we be in business
				_images[0].content = e.target.content;
				var image:Bitmap = new Bitmap(e.target.content.bitmapData);
				_images[0].index = _images[0].container.numChildren;
				_images[0].container.addChildAt(image, _images[0].index);
			} catch(error:TypeError) {
				_events.dispatchEvent(new custom_event(TYPE_ERROR, {text: error.message, image: _images[0].path, id: _images[0].id, content: e.target.content}));
				trace("[image_loader] Type Error. Cannot store image into the given container.");
				_failed = true;
			}
			_finishLoad();
        }

		/**
		 * sets up the image loaders and their listeners
		 */
		private function _init():void {
			_loadSecondaryListeners();
			if (_initialized) return;
			_initialized = true;

			// setup a new loader to handle the images
			_request		= new URLRequest();
			_request.method	= URLRequestMethod.GET;
			_loader	= new Loader();
			// add a listener for when the image has completely loaded
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,						_imageComplete,			false);
			// add a listener for the images progress
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,				_handleProgress,		false);
			// add a listener for when the status of the image is received
			_loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS,			_handleStatus,			false);
			// setup listeners for any I/O or Security errors
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,				_handleIOError,			false);
			_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,	_handleSecurityError,	false);

			// setup the backup timer that will check for ill-timed images
			_timer = new Timer(_timerInterval, 0);
			_timer.addEventListener(TimerEvent.TIMER, _timerCheck, false);
			_timer.start();
			
			dispatchEvent(new Event(Event.INIT));
			trace("[image_loader] Initialized.");
		}

		/**
		 * setup secondary listeners for the ability to support multiple instances of the image loader
		 */
		private function _loadSecondaryListeners():void {
			_events.addEventListener(Event.CANCEL,				_secondaryListener, false);
			_events.addEventListener(Event.COMPLETE,			_secondaryListener, false);
			_events.addEventListener(HTTP_STATUS,				_secondaryListener, false);
			_events.addEventListener(IMAGE_LOADED,				_secondaryListener, false);
			_events.addEventListener(IO_ERROR,					_secondaryListener, false);
			_events.addEventListener(ProgressEvent.PROGRESS,	_secondaryListener, false);
			_events.addEventListener(SECURITY_ERROR,			_secondaryListener, false);
			_events.addEventListener(TYPE_ERROR,				_secondaryListener, false);
		}

		/**
		 * re-dispatches any dispatched event (for multiple instances of the image loader)
		 */
		private function _secondaryListener(e):void {
			dispatchEvent(e);
		}

		/**
		 * periodically checks if there are any more images left to load that we have missed
		 */
		private function _timerCheck(e:TimerEvent):void {
			if (_images.length > 0) {
				// we're loading an image, let's make sure we're not "stuck" on the image
				if ((_timerCurrentImage == _images[0].path) && ((++_timerCurrentImageCount * _timerInterval) >= _timerImageIntervalMax)) {
					// well damn, this image is stuck!... pause it and re-load it ...works like a charm =]
					pause();
				} else if (_timerCurrentImage == _images[0].path) {
					// we're still loading the same image that we've been loading... check if the bytes have incremented and, if so, reset the count for the current image
					var bytes:Number = _loader.contentLoaderInfo.bytesLoaded;
					if (bytes != _timerCurrentBytes) _timerCurrentImageCount = 0;
					_timerCurrentBytes = _loader.contentLoaderInfo.bytesLoaded;
				} else if (_timerCurrentImage != _images[0].path) {
					// we started loading a new image, let's reset our info
					_timerCurrentImage = _images[0].path;
					_timerCurrentImageCount = 0;
					_timerCurrentBytes = 0;
				}
			
				load();
			} else if (_timerCurrentBytes > -1) {
				// we will reach here if we finished loading all images in the current array, reset everything!
				_timerCurrentImage = null;
				_timerCurrentImageCount = 0;
				_timerCurrentBytes = -1;
			} else if ((++_timerCount * _timerInterval) >= _timerIntervalMax) {
				// we have reached our max interval, we can kill the timer (for now)
				_timer.reset();
			}
		}
    }
}