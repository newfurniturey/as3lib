/**
 * Take a fileName, byteArray, and parameters object as input and return ByteArray post data suitable for a UrlRequest as output
 *
 * Usage {{{
 *    var wrapper = new url_wrapper(image, filename); // 'image' is a byte array of the image, 'filename' is the name you want to give it
 *    wrapper.url = "http://www.site.com/upload.php";
 *    var ldr:URLLoader = new URLLoader();
 *    ldr.dataFormat = URLLoaderDataFormat.BINARY;
 *    ldr.load(wrapper.request);
 * }}}
 */

package classes.utils {
    import flash.net.URLRequest;
    import flash.net.URLRequestHeader;
    import flash.net.URLRequestMethod;
    import flash.utils.ByteArray;
    import flash.utils.Endian;

	public class url_wrapper {
		// Global vars
		private static var _boundaryStr:String	= new String();						// used to break up different parts of the http POST body
        private static var _request:URLRequest	= new URLRequest();					// global request object
		
		/**
		 * constructor: create post data to send in a URLRequest
		 */
		public function url_wrapper(byteArray:ByteArray, fileName:String, destination:String=null, parameters:Object=null) {
			var i:int;
			var bytes:String;

			var postData:ByteArray = new ByteArray();
			postData.endian = Endian.BIG_ENDIAN;

			// add Filename to parameters
			if(parameters == null) parameters = new Object();
			parameters.Filename = fileName;

			// add parameters to postData
			for (var name:String in parameters) {
				postData = _boundary(postData);
				postData = _lineBreak(postData);
				bytes = 'Content-Disposition: form-data; name="' + name + '"';
				for (i=0; i<bytes.length; i++) postData.writeByte(bytes.charCodeAt(i));
				postData = _lineBreak(postData);
				postData = _lineBreak(postData);
				postData.writeUTFBytes(parameters[name]);
				postData = _lineBreak(postData);
			}

            // add img destination directory to postData if provided
            if (destination) {    
    			postData = _boundary(postData);
    			postData = _lineBreak(postData);
    			bytes = 'Content-Disposition: form-data; name="dir"';
    			for (i=0; i<bytes.length; i++) postData.writeByte(bytes.charCodeAt(i));
    			postData = _lineBreak(postData);
    			postData = _lineBreak(postData);
    			postData.writeUTFBytes(destination);
    			postData = _lineBreak(postData);
		    }

			// add Filedata to postData
			postData = _boundary(postData);
			postData = _lineBreak(postData);
			bytes = 'Content-Disposition: form-data; name="Filedata"; filename="';
			for (i=0; i<bytes.length; i++) postData.writeByte(bytes.charCodeAt(i));
			postData.writeUTFBytes(fileName);
			postData = _quote(postData);
			postData = _lineBreak(postData);
			bytes = 'Content-Type: application/octet-stream';
			for (i=0; i<bytes.length; i++) postData.writeByte(bytes.charCodeAt(i));
			postData = _lineBreak(postData);
			postData = _lineBreak(postData);
			postData.writeBytes(byteArray, 0, byteArray.length);
			postData = _lineBreak(postData);

			// add upload file to postData
			postData = _lineBreak(postData);
			postData = _boundary(postData);
			postData = _lineBreak(postData);
			bytes = 'Content-Disposition: form-data; name="Upload"';
			for (i=0; i<bytes.length; i++) postData.writeByte(bytes.charCodeAt(i));
			postData = _lineBreak(postData);
			postData = _lineBreak(postData);
			bytes = 'Submit Query';
			for (i=0; i<bytes.length; i++) postData.writeByte(bytes.charCodeAt(i));
			postData = _lineBreak(postData);

			// closing boundary
			postData = _boundary(postData);
			postData = _doubleDash(postData);

			// finally set up the urlrequest object
            _request.data = postData;
            _request.contentType = 'multipart/form-data; boundary=' + _boundaryStr;
            _request.method = URLRequestMethod.POST;
            _request.requestHeaders.push(new URLRequestHeader('Cache-Control', 'no-cache'));
		}
		
		/**
		 * returns the actual URLRequest, doesn't allow setting
		 */
        public function get request():URLRequest {
            return _request;
        }
        public function get request(urlRequest:URLRequest):void {
            trace("[url_wrapper] We do not allow setting the URLRequest object.");
        }
		
		/**
		 * gets/sets the URL for the URLRequest
		 */
		public function get url():String {
            return _request.url;
        }
		public function set url(path:String):void {
            _request.url = path;
        }
		
		/**
		 * gets the boundary for the post
		 * note: must be passed as part of the contentType of the URLRequest
		 */
		private static function _getBoundary():String {
			if(_boundaryStr.length == 0) for (var i:int=0; i<0x20; i++) _boundaryStr += String.fromCharCode(int(97 + Math.random() * 25));
			return _boundaryStr;
		}
		
		/**
		 * add a boundary to the PostData with leading doubledash
		 */
		private static function _boundary(data:ByteArray):ByteArray {
			var l:int = _getBoundary().length;

			data = _doubleDash(data);
			for (var i:int = 0; i<l; i++) data.writeByte(_boundaryStr.charCodeAt(i));
			return data;
		}

		/**
		 * add a double dash
		 */
		private static function _doubleDash(data:ByteArray):ByteArray {
			data.writeShort(0x2d2d);
			return data;
		}
		
		/**
		 * add one linebreak
		 */
		private static function _lineBreak(data:ByteArray):ByteArray {
			data.writeShort(0x0d0a);
			return data;
		}

		/**
		 * add a quotation mark
		 */
		private static function _quote(data:ByteArray):ByteArray {
			data.writeByte(0x22);
			return data;
		}
	}
}