package dk.cachet.app_usage;

import android.app.usage.UsageStats;
import android.app.usage.UsageStatsManager;
import android.content.Context;
import android.util.Log;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by User on 3/2/15.
 */
public class Stats {
    private static final String TAG = Stats.class.getSimpleName();

    /** Check if permission for usage statistics is required,
     * by fetching usage statistics since the beginning of time
     */
    @SuppressWarnings("ResourceType")
    public static boolean checkIfStatsAreAvailable(Context context) {
        UsageStatsManager usm = (UsageStatsManager) context.getSystemService("usagestats");
        long now  = Calendar.getInstance().getTimeInMillis();

        // Check if any usage stats are available from the beginning of time until now
        List<UsageStats> stats = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, 0, now);

        // Return whether or not stats are available
        return stats.size() > 0;
    }

    /** Produces a map for each installed app package name,
     * with the corresponding time in foreground in seconds for that application.
     */
    @SuppressWarnings("ResourceType")
    public static HashMap<String, Double> getUsageMap(Context context, long start, long end) {
        UsageStatsManager manager = (UsageStatsManager) context.getSystemService("usagestats");
        Map<String, UsageStats> usageStatsMap = manager.queryAndAggregateUsageStats(start, end);
        HashMap<String, Double> usageMap = new HashMap<>();

        for (String packageName : usageStatsMap.keySet()) {
            UsageStats us = usageStatsMap.get(packageName);
            try {
                long timeMs = us.getTotalTimeInForeground();
                Double timeSeconds = new Double(timeMs / 1000);
                usageMap.put(packageName, timeSeconds);
            } catch (Exception e) {
                Log.d(TAG, "Getting timeInForeground resulted in an exception");
            }
        }
        return usageMap;
    }
}
