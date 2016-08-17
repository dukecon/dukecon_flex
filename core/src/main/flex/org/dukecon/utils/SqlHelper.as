/**
 * Created by christoferdutz on 16.08.16.
 */
package org.dukecon.utils {
import mx.formatters.DateFormatter;

public class SqlHelper {

    public static function convertSqlDateToFlexDate(input:Object):Date {
        if (input == null) {
            return null;
        }

        // Views return a Number or String instead of a Date (which cannot be cast to Date type)
        if (input is Date) {
            return input as Date;
        }

        if (input is Number) {
            // JD 2440587.500000 is CE 1970 January 01 00:00:00.0 UT  Thursday
            const julianOffset:Number = 2440587.5;
            return new Date((Number(input) - julianOffset) * 24 * 60 * 60 * 1000);
        }

        if (input is String) {
            // format is probably "YYYY-MM-DD HH:MM:SS"
            return DateFormatter.parseDateString(String(input));
        }

        return null;
    }

}
}
