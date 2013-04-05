/**
 * Provides string functions mimicking other languages' string functions for ease-of-use!
 */

package classes.utils {
	import flash.text.TextField;
	
	public class string {		
		/**
		 * constructor: sets up the string utility (nuffin for now =[)
		 */
		public function string() { }
		
		/**
		 * PHP's str_replace
		 * takes the given string and replaces any "search" item(s) with the specified "replace" item(s)
		 */
		public function str_replace(search:Object, replace:Object, subject:String):String {
			// check if the "search" text is an array, if so validate it
			if (search is Array) {
				var i:int;
				if (replace is Array) {
					// the replace text is also an array, make sure it's the same length as the search array,
					// if not, add empty strings for each "missing" one
					if (replace.length < search.length) {
						for (i=replace.length; i<search.length; i++) {
							replace[i] = "";
						}
					}
				} else if (replace is String) {
					// if the replace Object is a string, make an array the same length as
					// the search object and fill each key with the replace string
					var replaceStr:String = String(replace);
					replace = new Array();
					for(i=0; i<search.length; i++) {
						replace[i] = replaceStr;
					}
				}
				
				// do the replacement!
				for(i=0; i<search.length; i++) {
					subject = subject.split(search[i]).join(replace[i]);
				}
				
				return subject;
			} else if (search is String) {
				// search is a string, check if replace is too
				if(!(replace is String)) {
					replace = replace.toString();
				}
			} else {
				// force both search/replace to be a string
				search	= search.toString();
				replace	= replace.toString();
			}
			
			// do the replacement!
			return subject.split(search).join(replace);
		}
		
		/**
		 * this will mimick a function used in many languages that will trim whitespace from the beginning/end of strings
		 */
		public function trim(string:String):String {
			return (string == null) ? '' : string.replace(/^\s+|\s+$/g, '');
		}
	}
}