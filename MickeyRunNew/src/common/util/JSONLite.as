/*
Copyright (c) 2008, Adobe Systems Incorporated
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

* Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

* Neither the name of Adobe Systems Incorporated nor the names of its
contributors may be used to endorse or promote products derived from
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package common.util {

    //import com.pblabs.engine.debug.Logger;
    //import com.playdom.socialcity.ui.ModalManager;
//    import liddles.debug.Assert;

    import flash.utils.ByteArray;

    /**
     * This class provides encoding and decoding of the JSON format.
     *
     * Example usage:
     * <code>
     * 		// create a JSON string from an internal object
     * 		JSON.encode( myObject );
     *
     *		// read a JSON string into an internal object
     *		var myObject:Object = JSON.decode( jsonString );
     *	</code>
     */
    public class JSONLite {


        /**
         * Encodes a object into a JSON string.
         *
         * @param o The object to create a JSON string for
         * @return the JSON string representing o
         * @langversion ActionScript 3.0
         * @playerversion Flash 9.0
         * @tiptext
         */
//        public static function encode( o:Object ):String {
//
//            var encoder:JSONEncoder = new JSONEncoder( o );
//            return encoder.getString();
//
//        }

//        CONFIG::DEBUG{
//            public static var oldTotalTime:int = 0;
//            public static var newTotalTime:int = 0;
//        }

        private static var DOUBLECHECK:Boolean = false;
        private static var _errorFound:Boolean = false;

        /**
         * Decodes a JSON string into a native object.
         *
         * @param s The JSON string representing the object
         * @return A native object as specified by s
         * @throw JSONParseError
         * @langversion ActionScript 3.0
         * @playerversion Flash 9.0
         * @tiptext
         */
        public static function decode( s:String ):* {
            /*/ // Old System:
            var decoder:JSONDecoder = new JSONDecoder( s )
            return decoder.getValue();
            /*/ // New System:

            //s = '{"neighborName":"\\u30ae\\u30eb"}';
            //s = "[{\"player\":{\"id\":\"100000627082079\",\"level\":3,\"gridId\":1,\"cityName\":null,\"districts\":[{\"id\":1,\"gridId\":1,\"name\":\"\",\"population\":111}],\"population\":111,\"firstName\":\"Joseph\",\"lastName\":\"Wilbury\",\"picSquare\":\"http:\\\/\\\/profile.ak.fbcdn.net\\\/hprofile-ak-snc4\\\/hs341.snc4\\\/41373_100000627082079_1359_q.jpg\"},\"accepted\":true,\"created\":1287405381,\"playerId\":\"100001637366306\",\"contracts\":[{\"startTime\":1292056292,\"districtId\":1,\"reward\":null,\"corner\":32383,\"playerId\":\"100000627082079\",\"contractId\":2,\"endTime\":1292057492,\"harvestedByFriendId\":null},{\"startTime\":1292056302,\"districtId\":1,\"reward\":null,\"corner\":33667,\"playerId\":\"100000627082079\",\"contractId\":5,\"endTime\":1292056482,\"harvestedByFriendId\":null}],\"friendId\":\"100000627082079\"},{\"player\":{\"id\":\"100001569022702\",\"level\":16,\"gridId\":1,\"cityName\":null,\"districts\":[{\"id\":255,\"gridId\":19,\"name\":\"\",\"population\":0},{\"id\":1,\"gridId\":1,\"name\":\"\",\"population\":196},{\"id\":2,\"gridId\":1,\"name\":\"\",\"population\":0},{\"id\":3,\"gridId\":1,\"name\":\"\",\"population\":0},{\"id\":4,\"gridId\":1,\"name\":\"\",\"population\":0}],\"population\":196,\"firstName\":\"Bati\",\"lastName\":\"Wilbury\",\"picSquare\":\"http:\\\/\\\/profile.ak.fbcdn.net\\\/hprofile-ak-snc4\\\/hs443.snc4\\\/48909_100001569022702_9193_q.jpg\"},\"accepted\":true,\"created\":1291301582,\"playerId\":\"100001637366306\",\"contracts\":[],\"friendId\":\"100001569022702\"},{\"player\":{\"id\":\"100001573073693\",\"level\":1,\"gridId\":1,\"cityName\":null,\"districts\":[{\"id\":255,\"gridId\":19,\"name\":\"\",\"population\":200},{\"id\":1,\"gridId\":1,\"name\":\"\",\"population\":1}],\"population\":201,\"firstName\":\"\\u30ae\\u30eb\",\"lastName\":\"\\u30ae\\u30eb\",\"picSquare\":\"http:\\\/\\\/profile.ak.fbcdn.net\\\/hprofile-ak-snc4\\\/hs448.snc4\\\/49302_100001573073693_9121_q.jpg\"},\"accepted\":true,\"created\":1288877534,\"playerId\":\"100001637366306\",\"contracts\":[],\"friendId\":\"100001573073693\"}]"

//            CONFIG::DEBUG{
//                if (DOUBLECHECK){
//                    if (_errorFound)
//                        return null;
//
//                    var start:int;
//                    start = getTimer();
//                    try{
//                        var decoder:JsonDecoderAsync = new JsonDecoderAsync( s );
//                    }catch(e:*){
//                        CONFIG::DEBUG{Logger.error('JSON', 'decode', 'Adobe JSON parser barfed! '+s);}
//                        throw e;
//                    }
//                    var theirs:Object = decoder.getValue();
//                    oldTotalTime += getTimer() - start;
//
//                    start = getTimer();
//                }
//            }

            var ours:Object = parseJson(s);
            if (null === ours){
//                CONFIG::DEBUG{Logger.error('JSON', 'decode', "JSON parse error! : "+s);}
                throw new Error("JSON parser returned null.");
                return null;
            }

//            CONFIG::DEBUG{
//                if (DOUBLECHECK){
//                    newTotalTime += getTimer() - start;
//                    CONFIG::DEBUG{Logger.print('JSON', "old = "+oldTotalTime+", new = "+newTotalTime+", total savings = "+(oldTotalTime - newTotalTime)+"ms");}
//
//                    if (!compareObject(theirs, ours)){
//                        _errorFound = true;
//                        CONFIG::DEBUG{Logger.error('JSON', 'decode', "ERROR: New JSON parser output doesn't match old.\n"+s);}
//                        //!ModalManager.alert('JSON mismatch!', 'Please copy the console to the clipboard and send it to Patrick!\n'+s);
//                        Assert(false, 'JSON parser error');
//                        return theirs;
//                    }
//                }
//            }

            return ours;
            /**/
        }

        //--------------------------------------
        //  IN-HOUSE JSON PARSER
        //--------------------------------------
        /* Known deviations from JSON spec
        - Key strings *cannot* have special characters, ie. \\, \n, \u, etc.
        - Numeric values *cannot* be exponential, ie 1.0e100
        - Special character \\ in values may not be handled properly.
        */

        // This (private static consts) was tested to be slightly faster
        // than using const variables inside the parseJson function.
        private static const START:uint = 1;
        private static const KEY:uint = 2;
        private static const COLON:uint = 3;
        private static const VALUE:uint = 4;
        private static const END:uint = 5;
        private static const ARRAY:uint = 6;
        private static const ARRAY_END:uint = 7;

        // This should not be expected to mean anything to anyone outside this function.
        private static var _lastParsedCharacterCount:int = 0;

        // Needs to return object & number of characters used so it can be recursive.
        public static function parseJson(json:String):Object{
            var obj:Object = null;
            var state:uint = START;
            var index:int = 0;
            var key:String = null;
            var value:* = null;
            var length:int = json.length;
            var startIx:int = 0;
            var char:String;
            var tempStr:String;
            var tempInt:int;
            var arrayMode:Boolean = false;

            while (index < length){
                char = json.charAt(index);

                // Always skip whitespace.
                if (' ' == char || '\n' == char || '\r' == char || '\t' == char){
                    ++index;
                    continue;
                }

                switch (state){
                    case START:{
                        switch (char){
                            case '{':
                                obj = new Object();
                                state = KEY;
                                break;
                            case '[':
                                obj = new Array();
                                arrayMode = true;
                                state = VALUE;
                                break;
                            default:
//                                CONFIG::DEBUG{Logger.error("", 'parseJson', "JSON parse error @"+index+": expected '{'.");}
                                return null;
                        }
                        break;
                    }

                    case KEY:{
                        switch (char){
                            case '"':
                                // Find end of the string.
                                ++index;
                                startIx = index;
                                while (true){
                                    if (index > length){
//                                        CONFIG::DEBUG{Logger.error("", 'parseJson', "JSON parse error @"+index+": quoted string not closed.");}
                                        return null;
                                    }
                                    if ('"' === json.charAt(index) && json.charAt(index - 1) != '\\'){
                                        key = json.substring(startIx, index);
                                        break;
                                    }
                                    ++index;
                                }
                                //TODO : Convert tagged characters like /" to their real values.
                                // Not very high priority as currently all of our keys are JS identifiers,
                                // which only have letters, numbers, and underscores.
                                state = COLON;
                                break;
                            case '}':
                                if (arrayMode){
//                                    CONFIG::DEBUG{Logger.error("", 'parseJson', "JSON parse error @"+index+": unexpected '}' encountered in array.");}
                                    return null;
                                }
                                _lastParsedCharacterCount = index;
                                return obj;
                                break;
                            default:
//                                CONFIG::DEBUG{Logger.error("", 'parseJson', "JSON parse error @"+index+": expected key string.");}
                                return null;
                        }
                        break;
                    }

                    case COLON:{
                        switch(char){
                            case ':':
                                state = VALUE;
                                break;
                            default:
//                                CONFIG::DEBUG{Logger.error("", 'parseJson', "JSON parse error @"+index+": expected colon.");}
                                return null;
                        }
                        break;
                    }

                    case VALUE:{
                        switch (char){
                            case '"':
                                // Find end of the string.
                                ++index;
                                startIx = index;
                                while (true){
                                    if (index > length){
//                                        CONFIG::DEBUG{Logger.error("", 'parseJson', "JSON parse error @"+index+": quoted string not closed.");}
                                        return null;
                                    }
                                    if ('"' === json.charAt(index) && json.charAt(index - 1) != '\\'){
                                        value = json.substring(startIx, index);
                                        break;
                                    }
                                    ++index;
                                }

                                // Convert tagged characters like /" to their real values.
                                tempStr = value;
                                do{
                                    value = tempStr;
                                    tempStr = value.replace('\\"', '"');
                                }while(value != tempStr);

                                do{
                                    value = tempStr;
                                    tempStr = value.replace('\\/', '/');
                                }while(value != tempStr);

                                do{
                                    value = tempStr;
                                    tempStr = value.replace('\\b', '\b');
                                }while(value != tempStr);

                                do{
                                    value = tempStr;
                                    tempStr = value.replace('\\f', '\f');
                                }while(value != tempStr);

                                do{
                                    value = tempStr;
                                    tempStr = value.replace('\\n', '\n');
                                }while(value != tempStr);

                                do{
                                    value = tempStr;
                                    tempStr = value.replace('\\r', '\r');
                                }while(value != tempStr);

                                do{
                                    value = tempStr;
                                    tempStr = value.replace('\\t', '\t');
                                }while(value != tempStr);

                                tempInt = tempStr.search('\\\\u');
                                while (tempInt > -1){
                                    tempStr = 	tempStr.slice(0, tempInt) +
                                        String.fromCharCode(uint("0x" + tempStr.slice(tempInt+2, tempInt+2+4))) +
                                        tempStr.slice(tempInt+6);
                                    tempInt = tempStr.search('\\\\u')
                                }
                                value = tempStr;

                                break;

                            case 't':
                                if (json.substr(index, 4) === "true"){
                                    value = true;
                                    index += 3;
                                } else {
//                                    CONFIG::DEBUG{Logger.error('', 'parseJson', 'JSON parse error @'+index+': expected boolean true value malformed.');}
                                    return null;
                                }
                                break;

                            case 'f':
                                if (json.substr(index, 5) === 'false'){
                                    value = false;
                                    index += 4;
                                } else {
//                                    CONFIG::DEBUG{Logger.error('', 'parseJson', 'JSON parse error @'+index+': expected boolean false value malformed.');}
                                    return null;
                                }
                                break;

                            case 'n':
                                if (json.substr(index, 4) === 'null'){
                                    value = null;
                                    index += 3;
                                } else {
//                                    CONFIG::DEBUG{Logger.error('', 'parseJson', 'JSON parse error @'+index+': expected "null" value malformed.');}
                                    return null;
                                }
                                break;

                            case '{':
                                // Recurse
                                value = parseJson(json.substr(index));
                                if (null === value){
                                    return null;
                                }
                                index += _lastParsedCharacterCount;
                                break;

                            case '[':
                                // Array: recurse.
                                value = parseJson(json.substr(index));
                                if (null === value){
                                    return null;
                                }
                                index += _lastParsedCharacterCount;
                                break;

                            case ']':
                                if (!arrayMode){
//                                    CONFIG::DEBUG{Logger.error('', 'parseJson', 'JSON parse error @'+index+': Unexpected "]" encountered.');}
                                    return null;
                                }
                                _lastParsedCharacterCount = index;
                                return obj;
                                break;

                            case '-':
                            case '0':
                            case '1':
                            case '2':
                            case '3':
                            case '4':
                            case '5':
                            case '6':
                            case '7':
                            case '8':
                            case '9':
                                // Number.
                                // Scan forward until the first character that is not part of the number.
                                // This relies on the string->number conversion in flash for error checking.
                                startIx = index;
                                while (null === value){
                                    switch(json.charAt(index)){
                                        case ']':
                                        case '}':
                                        case ',':
                                            // cast to number.
                                            value = Number(json.substring(startIx, index));
                                            if (null === value){
//                                                CONFIG::DEBUG{Logger.error("", 'parseJson', "JSON parse error @"+index+": error interpreting numeric value.");}
                                                return null;
                                            }
                                            --index;
                                            break;
                                        default:
                                            ++index;
                                            break;
                                    }
                                }
                                break;

                            default:
//                                CONFIG::DEBUG{Logger.error('', 'parseJson', "JSON parse error @"+index+": unrecognized value.");}
                                return null;
                        }
                        if (arrayMode){
                            (obj as Array).push(value);
                        }else{
                            obj[key] = value;
                        }
                        key = null;
                        value = null;
                        state = arrayMode ? ARRAY_END : END;
                        break;
                    }

                    case ARRAY_END:{
                        switch (char){
                            case ',':
                                state = VALUE;
                                break;
                            case ']':
                                _lastParsedCharacterCount = index;
                                return obj;
                                break;
                            default:
//                                CONFIG::DEBUG{Logger.error('', 'parseJson', "JSON parse error @"+index+": expected ']' or ','.");}
                                return null;
                        }
                        break;
                    }

                    case END:{
                        switch (char){
                            case ',':
                                state = KEY;
                                break;
                            case '}':
                                _lastParsedCharacterCount = index;
                                return obj;
                                break;
                            default:
//                                CONFIG::DEBUG{Logger.error('', 'parseJson', "JSON parse error @"+index+": expected '}' or ','.");}
                                return null;
                        }
                        break;
                    }
                }

                ++index;
            } // End while.

//            CONFIG::DEBUG{Logger.error("", 'parseJson', 'JSON parse error @'+index+': String ended unexpectedly.');}
            return null;
        }

        public static function compareObject(obj1:Object,obj2:Object):Boolean
        {
            var buffer1:ByteArray = new ByteArray();
            buffer1.writeObject(obj1);
            var buffer2:ByteArray = new ByteArray();
            buffer2.writeObject(obj2);

            // compare the lengths
            var size:uint = buffer1.length;
            if (buffer1.length == buffer2.length) {
                buffer1.position = 0;
                buffer2.position = 0;

                // then the bits
                while (buffer1.position < size) {
                    var v1:int = buffer1.readByte();
                    if (v1 != buffer2.readByte()) {
                        return false;
                    }
                }
                return true;
            }
            return false;
        }

    }
}
