package classes {
	import classes.events.custom_event;
	import classes.file.image_loader;
	import classes.file.xml_loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	dynamic public class template extends MovieClip {
		// Global vars
		public static const OBJECT_ID:String = new String("template");				
		private var _imgLoader:image_loader = null;
		private var _xmlLoader:xml_loader = null;
		
		/**
		 * constructor: sets up the template movie
		 */
		public function template():void {
			stop();
			
			_setupImageLoader();
			_setupXMLLoader();
		}
		
		/**
		 * All of the images have been loaded, close the image loader object.
		 *
		 * @param Event e Event arguments.
		 */
		private function _allImagesComplete(e:Event):void {
			trace("[" + OBJECT_ID + "] All images have been downloaded.");
			_destroyImageLoader();
		}
		
		/**
		 * All of the xml files have been loaded, close the xml loader object.
		 *
		 * @param Event e Event arguments.
		 */
		private function _allXMLComplete(e:Event):void {
			trace("[" + OBJECT_ID + "] All XML files have been loaded.");
			_destroyXMLLoader();
		}
		
		/**
		 * Remove all listeners from the image loader and unset it.
		 */
		private function _destroyImageLoader():void {
			_imgLoader.removeEventListener(image_loader.IMAGE_LOADED,		_imageComplete,		false);
			_imgLoader.removeEventListener(Event.COMPLETE,					_allImagesComplete,	false);
			_imgLoader.removeEventListener(image_loader.IO_ERROR,			_imageLoadError,	false);
			_imgLoader.removeEventListener(image_loader.SECURITY_ERROR,		_imageLoadError,	false);
			_imgLoader.removeEventListener(image_loader.TYPE_ERROR,			_imageLoadError,	false);
			_imgLoader = null;
		}
		
		/**
		 * Remove all listeners from the xml loader and unset it.
		 */
		private function _destroyXMLLoader():void {
			_xmlLoader.removeEventListener(xml_loader.FILE_LOADED,			_xmlComplete,		false);
			_xmlLoader.removeEventListener(Event.COMPLETE,					_allXMLComplete,	false);
			_xmlLoader.removeEventListener(xml_loader.IO_ERROR,				_xmlLoadError,		false);
			_xmlLoader.removeEventListener(xml_loader.SECURITY_ERROR,		_xmlLoadError,		false);
			_xmlLoader.removeEventListener(xml_loader.TYPE_ERROR,			_xmlLoadError,		false);
			_xmlLoader = null;
		}
		
		/**
		 * A single image has been loaded.
		 *
		 * @param custom_event e Event arguments.
		 */
		private function _imageComplete(e:custom_event):void {
			trace("[" + OBJECT_ID + "] The image has been loaded.");
			
			if (e.params.id == OBJECT_ID) {
				
			}
		}
		
		/**
		 * An error has occurred on the current image loading.
		 *
		 * @param custom_event e Event arguments.
		 */
		private function _imageLoadError(e:custom_event):void {
			trace("[" + OBJECT_ID + "] There was an error loading the image file.");
		}
		
		/**
		 * Create the image loader and add all necessary listeners to it.
		 */
		private function _setupImageLoader():void {
			_imgLoader = new image_loader();
			_imgLoader.addEventListener(image_loader.IMAGE_LOADED,		_imageComplete,		false);
			_imgLoader.addEventListener(Event.COMPLETE,					_allImagesComplete,	false);
			_imgLoader.addEventListener(image_loader.IO_ERROR,			_imageLoadError,	false);
			_imgLoader.addEventListener(image_loader.SECURITY_ERROR,	_imageLoadError,	false);
			_imgLoader.addEventListener(image_loader.TYPE_ERROR,		_imageLoadError,	false);
		}
		
		/**
		 * Create the xml loader and add all necessary listeners to it.
		 */
		private function _setupXMLLoader():void {
			_xmlLoader = new xml_loader();
			_xmlLoader.addEventListener(xml_loader.FILE_LOADED,			_xmlComplete,		false);
			_xmlLoader.addEventListener(Event.COMPLETE,					_allXMLComplete,	false);
			_xmlLoader.addEventListener(xml_loader.IO_ERROR,			_xmlLoadError,		false);
			_xmlLoader.addEventListener(xml_loader.SECURITY_ERROR,		_xmlLoadError,		false);
			_xmlLoader.addEventListener(xml_loader.TYPE_ERROR,			_xmlLoadError,		false);
		}
		
		/**
		 * A xml file has been loaded.
		 *
		 * @param custom_event e Event arguments.
		 */
		private function _xmlComplete(e:custom_event):void {
			trace("[" + OBJECT_ID + "] An xml file has been loaded.");
			
			// grab a copy of the loaded XML data
			 var xml:XML = new XML(e.params.data);
			
			if (e.params.id == OBJECT_ID) {
				// process the XML
			}
		}

		/**
		 * An error has occurred on the current xml file.
		 *
		 * @param custom_event e Event arguments.
		 */
		private function _xmlLoadError(e:custom_event):void {
			trace("[" + OBJECT_ID + "] There was an error loading the XML file.");
		}
	}
}
