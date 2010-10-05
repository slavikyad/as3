package com.zehfernando.utils {

	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 */
	public class StringUtils {

		public static function stripDoubleCRLF(__text:String): String {
			if (__text == null) return null;
			return __text.split("\r\n").join("\n");
		}

		public static function wrapSpanStyle(__text:String, __style:String = null): String {
			return (Boolean(__style) ? "<span class='" + __style + "'>" : "<span>")  + __text + "</span>";
		}
		
		public static function wrapCDATA(__text:String):String {
			return "<![CDATA[" + __text + "]]>";
		}
		
		public static function stripInvalidFileCharacters(__text:String): String {
			__text = __text.split(":").join("");
			return __text;
		}
		
		public static function makeStub(__text:String): String {
			// Transforms a title into a stub
			return __text.toLowerCase().replace(" ", "-").replace(/[^a-z0-9\-]/gi, "");
		}

		public static function parseBBCodeToHTML(__text:String): String {

			var rx:RegExp; // For when /gi does not work
		
			// \r\n
			__text = __text.replace(/\r\n/gi, "\n");
	
			// [size="n"]...[/size]
			// <font size="n">...</font>
			rx = /\[size=\u0022([0-9]*?)\u0022\]((.|\n|\r)*?)\[\/size\]?/i;
			while (rx.test(__text)) __text = __text.replace(rx, "<font size=\"$1\">$2</font>");
	
			// [color="c"]...[/color]
			// <font color="c">...</font>
			rx = /\[color=\u0022(#[0-9a-f]*?)\u0022\]((.|\n|\r)*?)\[\/color\]?/i;
			while (rx.test(__text)) __text = __text.replace(rx, "<font color=\"$1\">$2</font>");
	
			// [url="u"]...[/url]
			// <a href="u">...</a>
			rx = /\[url=\u0022(.*?)\u0022\]((.|\n|\r)*?)\[\/url\]?/i;
			while (rx.test(__text)) __text = __text.replace(rx, "<a href=\"$1\">$2</a>");
	
			// [b]...[/b]
			// <b>...</b>
			rx = /\[b\]((.|\n|\r)*?)\[\/b\]?/i;
			while (rx.test(__text)) __text = __text.replace(rx, "<b>$1</b>");
	
			// [i]...[/i]
			// <i>...</i>
			rx = /\[i\]((.|\n|\r)*?)\[\/i\]?/i;
			while (rx.test(__text)) __text = __text.replace(rx, "<i>$1</i>");
	
			return (__text);
		}
		
		public static function cropText(__text:String, __maximumLength:Number, __breakAnywhere:Boolean = false, __postText:String = ""):String {
			
			if (__text.length <= __maximumLength) return __text;
			
			// Crops a long text, to get excerpts
			if (__breakAnywhere) {
				// Break anywhere
				return __text.substr(0, Math.min(__maximumLength, __text.length)) + __postText;
			}
			
			// Break on words only
			var lastIndex:Number = 0;
			var prevIndex:Number = -1;
			while (lastIndex < __maximumLength && lastIndex > -1) {
				prevIndex = lastIndex;
				lastIndex = __text.indexOf(" ", lastIndex+1);
			}

			if (prevIndex == -1) {
				trace ("##### COULD NOT CROP ==> ", prevIndex, lastIndex, __text);
				prevIndex = __maximumLength;
			}

			return __text.substr(0, Math.max(0, prevIndex)) + __postText;
		}

		public static function getQuerystringParameterValue(__url:String, __parameterName:String): String {
			// Finds the value of a parameter given a querystring/url and the parameter name
			var qsRegex:RegExp = new RegExp("[?&]" + __parameterName + "(?:=([^&]*))?","i");
			var match:Object = qsRegex.exec(__url);
			
			if (Boolean(match)) return match[1];
			return null;
		}
		
		public static function replaceHTMLLinks(__text:String, __target:String = "_blank", __twitterSearchTemplate:String = "http://twitter.com/search?q=[[string]]", __twitterUserTemplate:String = "http://twitter.com/[[user]]"): String {
			
			// Create links for urls, hashtags and whatnot on the text
			var regexSearch:RegExp;
			var regexResult:Object;
			var str:String;
			
			var linkStart:Vector.<int> = new Vector.<int>();
			var linkLength:Vector.<int> = new Vector.<int>();
			var linkURL:Vector.<String> = new Vector.<String>();
			
			var i:int;
			
			// Links for hashtags
			//regexSearch = /\s#+\w*(\s|,|!|\.|\n)*?/gi;
			regexSearch = /\B#+\w*(\s|,|!|\.|\n)*?/gi;
			regexResult = regexSearch.exec(__text);
			while (regexResult != null) {
				str = regexResult[0];
				linkURL.push(__twitterSearchTemplate.split("[[string]]").join(escape(str)));
				linkStart.push(regexResult["index"]);
				linkLength.push(str.length);
				regexResult = regexSearch.exec(__text);
			}

			// Links for user names
			regexSearch = /@+\w*(\s|,|!|\.|\n)*?/gi;
			regexResult = regexSearch.exec(__text);
			while (regexResult != null) {
				str = regexResult[0];
				// Inserts in a sorted manner otherwise it won't work when looping
				for (i = 0; i <= linkStart.length; i++) {
					if (i == linkStart.length || regexResult["index"] < linkStart[i]) {
						linkURL.splice(i, 0, __twitterUserTemplate.split("[[user]]").join(str.substr(1)));
						linkStart.splice(i, 0, regexResult["index"]);
						linkLength.splice(i, 0, str.length);
						break;
					}
				}
				regexResult = regexSearch.exec(__text);
			}

			// Links for URLs
			regexSearch = /(http:\/\/+[\S]*)/gi;
			regexResult = regexSearch.exec(__text);
			while (regexResult != null) {
				str = regexResult[0];
				// Inserts in a sorted manner otherwise it won't work when looping
				for (i = 0; i <= linkStart.length; i++) {
					if (i == linkStart.length || regexResult["index"] < linkStart[i]) {
						linkURL.splice(i, 0, str);
						linkStart.splice(i, 0, regexResult["index"]);
						linkLength.splice(i, 0, str.length);
						break;
					}
				}
//				linkURL.push(str);
//				linkStart.push(regexResult["index"]);
//				linkLength.push(str.length);
				regexResult = regexSearch.exec(__text);
				//trace ("URL --> [" + str + "]");
			}
			
			// Finally, add the links as HTML links
			var newText:String = "";
			var lastPos:int = 0;
			i = 0;
			while (i < linkStart.length) {
				newText += __text.substr(lastPos, linkStart[i] - lastPos);
				newText += "<a href=\"" + linkURL[i] + "\" target=\""+__target+"\">";
				newText += __text.substr(linkStart[i], linkLength[i]);
				newText += "</a>";
				
				lastPos = linkStart[i] + linkLength[i];
				
				i++;
			}
			
			
			newText += __text.substr(lastPos);
			//trace ("--> " + newDescription);
			
			return newText;
		}
	}
}
