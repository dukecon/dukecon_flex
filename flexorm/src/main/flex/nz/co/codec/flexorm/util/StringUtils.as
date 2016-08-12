package nz.co.codec.flexorm.util
{
    import mx.utils.StringUtil;

    public class StringUtils
    {
    	public static function stringsEqualCaseIgnored(s1: String, s2: String): Boolean {
    		if (s1 == null || s2 == null) {
    			return false;
    		}
    		return (s1.toLowerCase() == s2.toLowerCase());
    	}

        public static function underscore(name:String):String
        {
            var retval:String = "";
            for (var i:int = 0; i < name.length; i++)
            {
                if (i > 0 && isUpperCase(name, i))
                {
                    retval += "_" + name.charAt(i).toLowerCase();
                }
                else if (i > 0 && isNumber(name, i))
                {
                    retval += "_" + name.charAt(i);
                }
                else
                {
                    retval += name.charAt(i);
                }
            }
            return retval;
        }

        public static function convertCamelCaseToSpaced(name:String):String
        {
            var retval:String = "";
            for (var i:int = 0; i < name.length; i++)
            {
                if (i > 0 && isUpperCase(name, i))
                {
                    retval += " " + name.charAt(i).toLowerCase();
                }
                else if (i > 0 && isNumber(name, i))
                {
                    retval += " " + name.charAt(i);
                }
                else
                {
                    retval += name.charAt(i);
                }
            }
            return retval;
        }

        public static function camelCase(name:String):String
        {
            var retval:String = "";
            for (var i:int = 0; i < name.length; i++)
            {
                if (i > 0 && name.charAt(i) == "_")
                {
                    retval += name.charAt(++i).toUpperCase();
                }
                else
                {
                    retval += name.charAt(i);
                }
            }
            return retval;
        }

        public static function startLowerCase(str:String):String
        {
            return str.substr(0,1).toLowerCase() + str.substr(1);
        }

        public static function isLowerCase(str:String, pos:int = 0):Boolean
        {
            if (pos >= str.length) return false;
            var char:int = str.charCodeAt(pos);
            return (char > 96 && char < 123);
        }

        public static function isUpperCase(str:String, pos:int = 0):Boolean
        {
            if (pos >= str.length) return false;
            var char:int = str.charCodeAt(pos);
            return (char > 64 && char < 91);
        }

        public static function isNumber(str:String, pos:int = 0):Boolean
        {
            if (pos >= str.length) return false;
            var char:int = str.charCodeAt(pos);
            return (char > 47 && char < 58);
        }

        public static function parseBoolean(str:String, defaultValue:Boolean):Boolean
        {
            if (str == null)
                return defaultValue;

            switch (StringUtil.trim(str))
            {
                case "":
                    return defaultValue;
                    break;
                case "true":
                    return true;
                    break;
                case "false":
                    return false;
                    break;
                default:
                    throw new Error("Cannot parse Boolean from '" + str + "'");
            }
        }

        public static function endsWith(str:String, match:String):Boolean
        {
            if (str == null)
                return false;

            return (match == str.substring(str.length - match.length));
            // return (str.lastIndexOf(match) == (str.length - match.length));
            // does return false positives if str.length - match.length = -1
        }

        /**
         * Formats a date that can be recognized by SQLite using function strftime('%J','" + toSqlDate(myDate) + "')
         */
        public static function toSqlDate(dateVal:Date):String
        {
            return dateVal == null ? null : dateVal.fullYear + "-" + formatNumberWithLeadingZeros(dateVal.month + 1, 2) // month is zero-based
                                        + "-" + formatNumberWithLeadingZeros(dateVal.date, 2) + " " + formatNumberWithLeadingZeros(dateVal.hours, 2) +
                                        ":" + formatNumberWithLeadingZeros(dateVal.minutes, 2) + ":" + formatNumberWithLeadingZeros(dateVal.seconds
                                                                                                                                    , 2);
        }

        /**
         * returns a string containing the number formatted with leading zeros
         */
        public static function formatNumberWithLeadingZeros(numberToConvert:Number, targetLength:Number):String
        {
            var retVal:String = "";
            var numberAsString:String = numberToConvert.toString();
            var stringLength:Number = numberAsString.length;

            for (var i:int = 0; i < (targetLength - stringLength); i++)
            {
                retVal += "0";
            }
            return retVal + numberAsString;
        }

    }
}