package com.example.apps;

import android.annotation.TargetApi;
import android.app.Activity;
import android.app.ActivityManager;
import android.app.usage.UsageStats;
import android.app.usage.UsageStatsManager;
import android.content.Context;
import android.os.Build;
import android.util.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.util.ArrayList;
import java.util.List;
import java.util.SortedMap;
import java.util.TreeMap;

/** AppsPlugin */
public class AppsPlugin implements MethodCallHandler {

  static ActivityManager am;
  static Context ctx;
  String packageName = "NONE";

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "apps");
    channel.setMethodCallHandler(new AppsPlugin());
    ctx = registrar.activeContext();
    am = (ActivityManager) ctx.getSystemService(Activity.ACTIVITY_SERVICE);
  }

  @TargetApi(Build.VERSION_CODES.CUPCAKE)
  @Override
  public void onMethodCall(MethodCall call, Result result) {
//    List<ActivityManager.RunningAppProcessInfo> tasks = am.();
//    String packages = "";
//    for (ActivityManager.RunningAppProcessInfo t : tasks) {
//      packages += t.processName + ", ";
//    }
//
//    //packageName = am.getRunningTasks(1).get(0).topActivity.getPackageName();

    if (call.method.equals("getForegroundApp")) {
      printForegroundTask();
      result.success("Hey");
    } else {
      result.notImplemented();
    }
  }

  @TargetApi(Build.VERSION_CODES.CUPCAKE)
  private void printForegroundTask() {
    String currentApp = "NULL";
    if(android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
      UsageStatsManager usm = (UsageStatsManager) ctx.getSystemService(Context.USAGE_STATS_SERVICE);
      long time = System.currentTimeMillis();
      List<UsageStats> appList = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY,  time - 1000*1000, time);
      if (appList != null && appList.size() > 0) {
        SortedMap<Long, UsageStats> mySortedMap = new TreeMap<Long, UsageStats>();
        for (UsageStats usageStats : appList) {
          mySortedMap.put(usageStats.getLastTimeUsed(), usageStats);
        }
        if (mySortedMap != null && !mySortedMap.isEmpty()) {
          currentApp = mySortedMap.get(mySortedMap.lastKey()).getPackageName();
        }
      }
    } else {
      ActivityManager am = (ActivityManager) ctx.getSystemService(Context.ACTIVITY_SERVICE);
      List<ActivityManager.RunningAppProcessInfo> tasks = am.getRunningAppProcesses();
      currentApp = tasks.get(0).processName;
    }

    Log.e("App plugin", "Current App in foreground is: " + currentApp);
  }
}
