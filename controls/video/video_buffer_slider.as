/**
 * Implementation of a slider object to display as a video's seek bar, with visual buffer abilities.
 *
 * Usage: {{{
 *   var seekBar:video_buffer_slider = new video_buffer_slider(settings);	// 'settings' is an object with all required settings specified
 *   seekBar.addEventListener(slider.CHANGE, _seekChanged, false, 0, true);
 *   function _seekChanged(e:custom_event):void {
 *   trace("Seek To: " + e.params.value);
 *   }
 * }}}
 */

package classes.controls.video {
	import classes.controls.slider;
	import classes.events.custom_event;
	import classes.file.image_loader;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class video_buffer_slider extends slider {
		// Global vars.
		public static var SLIDER_READY:String			= new String("sliderReady");
		private var _bufferLevel:Number					= 0;									// current video buffer level
		private var _disabled:Boolean					= false;								// flag to indicate if the slider is disabled
		private var _imageLoader:image_loader			= null;									// global image_loader object
		private var _imageLoaderID:String				= new String("videoBufferSliderID");	// ID to use in the image loader
		private var _lockUpdate:Boolean					= false;								// flag to indicate if updating is enabled
		private var _numberOfImages:int					= 0;									// current number of images
		private var _numberOfImagesLoaded:int			= 0;									// current number of images loaded
		private var _sliderBarBuffer:MovieClip			= null;									// graphics holder for the buffer clip
		private var _sliderBarBufferMask:MovieClip		= null;									// graphics holder for the buffer clip's mask
		private var _sliderBarPlayed:MovieClip			= null;									// graphics holder for the played clip
		private var _sliderBarPlayedMask:MovieClip		= null;									// graphics holder for the played clip's mask
		private var _uiReady:Boolean					= false;								// flag to indicate if the UI is ready
		
		/**
		 * Constructor: sets up the slider.
		 *
		 * @param Object settings
		 */
		public function video_buffer_slider(settings:Object):void {
			_setupImageLoader();
			_processSettings(settings);
		}
		
		/**
		 * Disables the slider.
		 */
		public function disable():void {
			_disabled = true;
		}
		
		/**
		 * Enables the slider.
		 */
		public function enable():void {
			_disabled = false;
		}
		
		/**
		 * Gets the 'is locked' flag.
		 *
		 * @return Boolean
		 */
		public function isLocked():Boolean {
			return _lockUpdate;
		}
		
		/**
		 * Updates the current played level.
		 *
		 * @param Number value Value to update the current-played-level to.
		 */
		public override function update(value:Number):void {
			if (_lockUpdate) return;
			super.update(value);
			
			if (_settings.direction == HORIZONTAL) {
				_sliderBarPlayedMask.x = (_scrubber.x - _settings.length);
			} else if (_settings.direction == VERTICAL_UP) {
				_sliderBarPlayedMask.y = _scrubber.y;
			} else if (_settings.direction == VERTICAL_DOWN) {
				_sliderBarPlayedMask.y = _scrubber.y - _settings.length;
			}
		}
		
		/**
		 * Updates the current buffer level.
		 *
		 * @param Number value Value to update the buffer by.
		 */
		public function updateBuffer(value:Number):void {
			if (!_uiReady || (_sliderBarBuffer == null)) return;
		
			_bufferLevel = value;
			
			if (_settings.direction == HORIZONTAL) {
				_sliderBarBufferMask.x = ((_settings.length * value) - _settings.length);
			} else if (_settings.direction == VERTICAL_UP) {
				_sliderBarBufferMask.y = (_settings.length - (_settings.length * value));
			} else if (_settings.direction == VERTICAL_DOWN) {
				_sliderBarBufferMask.y = (_settings.length * value);
			}
		}
		
		/**
		 * Creates the UI and all defined components.
		 */
		protected override function _createUI():void {
			_scrubber.buttonMode = true;
			_scrubber.addEventListener(MouseEvent.MOUSE_DOWN, _handleMouseDown, false, 0, true);
			
			_settings.length = _sliderBar.width;
			_sliderBar.addEventListener(MouseEvent.MOUSE_DOWN, _handleBarMouseDown, false, 0, true);
			
			if (_settings.direction == HORIZONTAL) {
				//_sliderBar.y = -(_sliderBar.height / 2);
				_scrubber.y = -(_scrubber.height / 2);
				_scrubber.x = (((_settings.value - _settings.minValue) / (_settings.maxValue - _settings.minValue)) * (_settings.maxValue - _settings.minValue));
			} else {
				//_sliderBar.x = -(_sliderBar.width / 2);
				_scrubber.x = -(_scrubber.width / 2);
				_scrubber.y = ((((_settings.value - _settings.minValue) / (_settings.maxValue - _settings.minValue)) * _settings.length) + ((_settings.direction == VERTICAL_UP) ? -_settings.length : 0)) * ((_settings.direction == VERTICAL_UP) ? -1 : 1);
			}
			addChild(_sliderBar);
			
			_createBufferBarMask();
			_createPlayedBarMask();
			
			addChild(_scrubber);
			
			_sliderRect = new Rectangle();
			_sliderRect.x = (_settings.direction == HORIZONTAL) ? _sliderBar.x : _scrubber.x;
			_sliderRect.y = (_settings.direction == HORIZONTAL) ? _scrubber.y : _sliderBar.y;
			_sliderRect.width = (_settings.direction == HORIZONTAL) ? _sliderBar.width : 0;
			_sliderRect.height = (_settings.direction == HORIZONTAL) ? 0 : _sliderBar.height;
		
			_uiReady = true;
			dispatchEvent(new custom_event(SLIDER_READY));
		}
		
		/**
		 * Creates the buffer bar and its mask.
		 */
		private function _createBufferBarMask():void {
			if (_sliderBarBuffer == null) return;
			
			var maskBmp = new Bitmap(Bitmap(_sliderBar.getChildAt(0)).bitmapData.clone());
			
			_sliderBarBufferMask = new MovieClip();
			
			_sliderBarBufferMask.addChild(maskBmp);
			_sliderBarBufferMask.cacheAsBitmap = true;
			_sliderBarBuffer.cacheAsBitmap = true;
			
			if (_settings.direction == HORIZONTAL) {
				_sliderBarBufferMask.x = -_settings.length;
				_sliderBarBuffer.x = _sliderBar.x;
				_sliderBarBufferMask.y = _sliderBarBuffer.y = _sliderBar.y;
			} else {
				_sliderBarBufferMask.y = (_settings.direction == VERTICAL_DOWN) ? -_settings.length : _settings.length;
				_sliderBarBuffer.y = _sliderBar.y;
				_sliderBarBufferMask.x = _sliderBarBuffer.x = _sliderBar.x;
			}
			
			_sliderBarBuffer.mouseChildren = true;
			_sliderBarBuffer.enabled = false;
			_sliderBarBufferMask.mouseChildren = true;
			_sliderBarBufferMask.enabled = false;
			
			addChild(_sliderBarBuffer);
			addChild(_sliderBarBufferMask);
			_sliderBarBuffer.mask = _sliderBarBufferMask;
		}
		
		/**
		 * Creates the played bar and its mask.
		 */
		private function _createPlayedBarMask():void {
			var maskBmp = new Bitmap(Bitmap(_sliderBar.getChildAt(0)).bitmapData.clone());
			_sliderBarPlayedMask = new MovieClip();
			
			_sliderBarPlayedMask.addChild(maskBmp);
			_sliderBarPlayedMask.cacheAsBitmap = true;
			_sliderBarPlayed.cacheAsBitmap = true;
			
			if (_settings.direction == HORIZONTAL) {
				_sliderBarPlayedMask.x = -_settings.length;
				_sliderBarPlayed.x = _sliderBar.x;
				_sliderBarPlayedMask.y = _sliderBarPlayed.y = _sliderBar.y;
			} else {
				_sliderBarPlayedMask.y = (_settings.direction == VERTICAL_DOWN) ? -_settings.length : _settings.length;
				_sliderBarPlayed.y = _sliderBar.y;
				_sliderBarPlayedMask.x = _sliderBarPlayed.x = _sliderBar.x;
			}
			
			_sliderBarPlayed.mouseChildren = true;
			_sliderBarPlayed.enabled = false;
			_sliderBarPlayedMask.mouseChildren = true;
			_sliderBarPlayedMask.enabled = false;
			
			addChild(_sliderBarPlayed);
			addChild(_sliderBarPlayedMask);
			_sliderBarPlayed.mask = _sliderBarPlayedMask;
		}
		
		/**
		 * Removes the listeners for the image loader.
		 */
		private function _destroyImageLoader():void {
			_imageLoader.removeEventListener(image_loader.IMAGE_LOADED,		_imageLoaded, false);
			_imageLoader.removeEventListener(image_loader.IO_ERROR,			_imageFailed, false);
			_imageLoader.removeEventListener(image_loader.SECURITY_ERROR,	_imageFailed, false);
			_imageLoader.removeEventListener(image_loader.TYPE_ERROR,		_imageFailed, false);
			_imageLoader = null;
		}
		
		/**
		 * Checks if disabled and then calls the parent, moving the played mask with the slider.
		 *
		 * @param custom_event e Event arguments.
		 */
		protected override function _handleBarMouseDown(e:MouseEvent):void {
			if (_disabled) return;
			
			super._handleBarMouseDown(e);
			
			if (_settings.direction == HORIZONTAL) {
				_sliderBarPlayedMask.x = _scrubber.x - _settings.length;
				if ((_sliderBarBuffer != null) && (_sliderBarPlayedMask.x > _sliderBarBufferMask.x)) _sliderBarPlayedMask.x = _sliderBarBufferMask.x;
			} else if (_settings.direction == VERTICAL_UP) {
				_sliderBarPlayedMask.y = _scrubber.y;
				if ((_sliderBarBuffer != null) && (_sliderBarPlayedMask.y < _sliderBarBufferMask.y)) _sliderBarPlayedMask.y = _sliderBarBufferMask.y;
			} else if (_settings.direction == VERTICAL_DOWN) {
				_sliderBarPlayedMask.y = _scrubber.y - _settings.length;
				if ((_sliderBarBuffer != null) && (_sliderBarPlayedMask.y < _sliderBarBufferMask.y)) _sliderBarPlayedMask.y = _sliderBarBufferMask.y;
			}
		}
		
		/**
		 * Checks if disabled and then calls the parent locking the draggable area to the buffer level.
		 *
		 * @param custom_event e Event arguments.
		 */
		protected override function _handleMouseDown(e:MouseEvent):void {
			if (_disabled) return;
			
			_lockUpdate = true;
			_sliderRect.width = (_settings.direction == HORIZONTAL) ? (_sliderBar.width * _bufferLevel) : 0;
			_sliderRect.height = (_settings.direction == HORIZONTAL) ? 0 : (_sliderBar.height * _bufferLevel);
			super._handleMouseDown(e);
		}
		
		/**
		 * Checks if disabled and then calls the parent, also keeping the played mask in check.
		 *
		 * @param custom_event e Event arguments.
		 */
		protected override function _handleMouseMove(e:MouseEvent):void {
			if (_disabled) return;
			
			if (_settings.direction == HORIZONTAL) {
				_sliderBarPlayedMask.x = _scrubber.x - _settings.length;
			} else {
				_sliderBarPlayedMask.y = _scrubber.y - ((_settings.direction == VERTICAL_UP) ? 0 : _settings.length);
			}
		
			super._handleMouseMove(e);
		}
		
		/**
		 * Checks if the slider is disabled, then calls the parent.
		 *
		 * @param MouseEvent e Event arguments.
		 */
		protected override function _handleMouseUp(e:MouseEvent):void {
			if (_disabled) return;
			
			super._handleMouseUp(e);
			_lockUpdate = false;
		}
		
		/**
		 * Listener for when the image has failed loading.
		 *
		 * @param custom_event e Event arguments.
		 */
		private function _imageFailed(e:custom_event):void {
			if (e.params.id == _imageLoaderID) {
				// one of our images failed, kill everything, we dun died =[
				_destroyImageLoader();
				super._createUI();
			}
		}
		
		/**
		 * Listener for when an image has been loaded.
		 *
		 * @param custom_event e Event arguments.
		 */
		private function _imageLoaded(e:custom_event):void {
			if (e.params.id == _imageLoaderID) {
				_numberOfImagesLoaded++;
				
				if (_numberOfImagesLoaded == _numberOfImages) {
					_createUI();
					_destroyImageLoader();
				}
			}
		}
		
		/**
		 * Process all of the passed settings and create all of the default settings.
		 *
		 * @param Object settings
		 */
		protected override function _processSettings(settings:Object):void {
			super._processSettings(settings);
			
			var valid:Boolean = true;
			
			// scrubber
			if ((settings.scrubberImage != null) && (settings.scrubberImage != "")) {
				_numberOfImages++;
				_scrubber = new MovieClip();
				_scrubber.name = "scrubber";
				_imageLoader.load(settings.scrubberImage, _scrubber, _imageLoaderID);
			} else {
				valid = false;
			}
			
			// slider bar background
			if (valid && (settings.barBackgroundImage != null) && (settings.barBackgroundImage != "")) {
				_numberOfImages++;
				_sliderBar = new MovieClip();
				_sliderBar.name = "sliderBar";
				_imageLoader.load(settings.barBackgroundImage, _sliderBar, _imageLoaderID);
			} else {
				valid = false;
			}
			
			// slider bar buffer
			if (valid && (settings.barBufferImage != null) && (settings.barBufferImage != "")) {
				_numberOfImages++;
				_sliderBarBuffer = new MovieClip();
				_sliderBarBuffer.name = "sliderBarBuffer";
				_imageLoader.load(settings.barBufferImage, _sliderBarBuffer, _imageLoaderID);
			} else {
				_bufferLevel = 1;
			}
			
			// slider bar played
			if (valid && (settings.barPlayedImage != null) && (settings.barPlayedImage != "")) {
				_numberOfImages++;
				_sliderBarPlayed = new MovieClip();
				_sliderBarPlayed.name = "sliderBarPlayed";
				_imageLoader.load(settings.barPlayedImage, _sliderBarPlayed, _imageLoaderID);
			} else {
				valid = false;
			}
			
			
			if (!valid) {
				trace("[video_buffer_slider] Invalid settings.");
				_destroyImageLoader();
				super._createUI();
			}
		}
		
		/**
		 * Creates all of the image_loader listeners.
		 */
		private function _setupImageLoader():void {
			_imageLoader = new image_loader();
			_imageLoader.addEventListener(image_loader.IMAGE_LOADED,	_imageLoaded, false, 0, true);
			_imageLoader.addEventListener(image_loader.IO_ERROR,		_imageFailed, false, 0, true);
			_imageLoader.addEventListener(image_loader.SECURITY_ERROR,	_imageFailed, false, 0, true);
			_imageLoader.addEventListener(image_loader.TYPE_ERROR,		_imageFailed, false, 0, true);
		}
	}
}