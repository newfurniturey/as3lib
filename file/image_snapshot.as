/**
 * Takes a snapshot of the given MovieClip and POSTs it to the given page.
 *
 * Usage: {{{
 *    var snapshot:image_snapshot = new image_snapshot(myObject, "snapshot.jpg", "save_snapshot.php");
 * }}}
 */

package classes.file {
	import classes.adobe.image.JPGEncoder;
	import classes.events.custom_event;
	import classes.utils.url_wrapper;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	
	public class image_snapshot extends Sprite {
		// Global vars.
		public static var LOAD_ERROR:String			= new String("loadError");
		public static var UPLOAD_COMPLETE:String	= new String("uploadComplete");
		
		/**
		 * constructor: sets up the snapshot
		 */
		public function image_snapshot(obj:DisplayObject, file_name:String, post_to:String):void {
			var tmp_image:BitmapData = new BitmapData(obj.width, obj.height, true, 0xffffff);
			tmp_image.draw(obj, new Matrix(), null, null, null, false);
			
			var snapshot:ByteArray = new JPGEncoder().encode(tmp_image);
			var wrapper:url_wrapper	= new url_wrapper(snapshot, file_name);
			wrapper.url = post_to;
			
            var upload_file:URLLoader = new URLLoader();
			upload_file.dataFormat = URLLoaderDataFormat.BINARY;
			upload_file.addEventListener(Event.COMPLETE,					_uploadComplete);
            upload_file.addEventListener(IOErrorEvent.IO_ERROR,				_handleIOError);
			upload_file.addEventListener(SecurityErrorEvent.SECURITY_ERROR,	_handleSecurityError);
			upload_file.load(wrapper.request);
		}
		
		/**
		 * an IO error has been caught...output/dispatch and event saying so
		 */
		private function _handleIOError(e:IOErrorEvent):void {
			trace("[image_snapshot] Image snapshot uploader encountered an I/O error.");
			dispatchEvent(new custom_event(LOAD_ERROR, {error_info: "IO Error."}));
		}
		
		/**
		 * a Security error has been caught...output/dispatch an even saying so
		 */
		private function _handleSecurityError(e:SecurityErrorEvent):void {
			trace("[image_snapshot] Image snapshot uploader encountered a security error.");
			dispatchEvent(new custom_event(LOAD_ERROR, {error_info: "Security Error."}));
		}
		
		/**
		 * the image has finished uploading! dispatch an event saying so, with a path to the file
		 */
        private function _uploadComplete(e:Event):void {
			dispatchEvent(new custom_event(UPLOAD_COMPLETE));
        }
	}
}