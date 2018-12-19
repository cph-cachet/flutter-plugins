package de.kn.uni.smartact.movisenslibrary.utils;

import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;

import java.util.Date;

public class TimeFormatUtil {
    public final static DateTimeFormatter SIMPLE_DATE_FORMAT = DateTimeFormat.forPattern("yyyy-MM-dd HH:mm:ss");

        public static String getDateString() {
        return SIMPLE_DATE_FORMAT.print(new DateTime());
    }

    public static String getStringFromDate(DateTime date) {
        return SIMPLE_DATE_FORMAT.print(date);
    }

    public static Date getDateFromString(String string) {
        try {
            Date date = SIMPLE_DATE_FORMAT.parseDateTime(string).toDate();
            return date;
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            return new Date();
        }
    }
}
