/**
 * Handles file upload/download operations based on POST events.
 *
 * Usage: {{{
 *    import classes.file.image_uploader;
 *    imageUploader = new image_uploader('http://www.site.com/upload_image.php', 'path=');
 *    imageUploader.browse();
 *    imageUploader.addEventListener(image_loader.FILE_UPLOADED, upload_complete);
 *    function upload_complete(e:custom_event):void {
 *    	trace("The file '"+e.params.timestamp+e.params.file+"' has been uploaded.");
 *    }
 * }}}
 */

package classes.file {
	import classes.events.custom_event;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
    import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	public class image_uploader extends Sprite {
		// Global vars.
		public static var FILE_UPLOADED:String		= new String("fileUploaded");
		public static var LOAD_ERROR:String			= new String("loadError");
		public static var ON_PROGRESS:String		= new String("onProgress");
		public static var ON_SELECT:String			= new String("onSelect");
		private var file_name:String				= new String();
		private var unique_stamp:String				= new String();
		private var upload_file:FileReference		= new FileReference();
		private var upload_url:URLRequest;
		
		/**
		 * constructor: sets up the file manager
		 */
		public function image_uploader(php_path:String, query_path:String='path='):void {
			unique_stamp = _unique_name();
			upload_url = new URLRequest(php_path + '?' + query_path + unique_stamp);
            
            upload_file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,	_upload_complete);
			upload_file.addEventListener(Event.SELECT,						_handleSelect);
            upload_file.addEventListener(HTTPStatusEvent.HTTP_STATUS,		_handleStatus);
            upload_file.addEventListener(IOErrorEvent.IO_ERROR,				_handleIOError);
            upload_file.addEventListener(ProgressEvent.PROGRESS,			_handleProgress);
            upload_file.addEventListener(SecurityErrorEvent.SECURITY_ERROR,	_handleSecurityError);
		}
		
		/**
		 * opens the "browse" dialog to find an image file to upload
		 */
		public function browse():void {
			upload_file.browse(new Array(new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg;*.jpeg;*.gif;*.png")));
		}
		
		/**
		 * an IO error has been caught...output/dispatch and event saying so
		 */
		private function _handleIOError(e:IOErrorEvent):void {
			trace("[image_uploader] Image uploader encountered an I/O error.");
			dispatchEvent(new custom_event(LOAD_ERROR, {error_info: "IO Error."}));
		}
		
		/**
		 * a file has been "selected" for upload, start uploading!
		 */
		private function _handleProgress(e:ProgressEvent):void {
            var file:FileReference = FileReference(e.target);
			dispatchEvent(new custom_event(ON_PROGRESS, {percent: _normalize(e.bytesLoaded / e.bytesTotal)}));
        }
		
		/**
		 * a Security error has been caught...output/dispatch an even saying so
		 */
		private function _handleSecurityError(e:SecurityErrorEvent):void {
			trace("[image_uploader] Image uploader encountered a security error.");
			dispatchEvent(new custom_event(LOAD_ERROR, {error_info: "Security Error."}));
		}
		
		/**
		 * a file has been "selected" for upload, start uploading!
		 */
		private function _handleSelect(e:Event):void {
			dispatchEvent(new custom_event(ON_SELECT));
            var file:FileReference	= FileReference(e.target);
			file_name				= file.name;
			file.upload(upload_url);
        }

		/**
		 * handles the status of the file, and if it ain't 200 throw a error!! (and if it's over 0 [local file])
		 */
		private function _handleStatus(e:HTTPStatusEvent):void {
			if (e.status == 0) {
				trace("[image_uploader] Image status unavailable (local file).");
			} else if (e.status != 200) {
				trace("[image_uploader] Image HTTP status failed (Status Code: " + e.status + ").");
				dispatchEvent(new custom_event(LOAD_ERROR, {error_info: "data load error (Status Code: " + e.status + ")."}));
			} else {
				trace("[image_uploader] Image HTTP status succeeded.");
			}
		}
		
		/**
		 * normalize the percentage into a "familiar"/usable number
		 */
		private function _normalize(value:Number):Number {
			value = (value > 1) ? 1 : ((value < 0) ? 0 : value);
			return Number(value.toFixed(3));
		}
		
		/**
		 * create a unique name by getting a current timestamp
		 */
		private function _unique_name():String {
			var d:Date = new Date();			
			return d.getMonth() + 1 + '' + d.getDate() + '' + d.getHours() + '' + d.getMinutes() + ''  + d.getMilliseconds();
		}
		
		/**
		 * the image has finished uploading! dispatch an event saying so, with a path to the file
		 */
        private function _upload_complete(e:DataEvent):void {
			dispatchEvent(new custom_event(FILE_UPLOADED, {file: file_name, timestamp: unique_stamp}));
        }
	}
}