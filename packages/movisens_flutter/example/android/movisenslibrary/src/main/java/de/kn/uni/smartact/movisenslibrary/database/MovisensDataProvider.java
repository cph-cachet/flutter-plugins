package de.kn.uni.smartact.movisenslibrary.database;

import android.content.ContentProvider;
import android.content.ContentProviderOperation;
import android.content.ContentProviderResult;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.OperationApplicationException;
import android.content.UriMatcher;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteQueryBuilder;
import android.net.Uri;
import android.text.TextUtils;
import android.util.Log;

import java.util.ArrayList;

import de.kn.uni.smartact.movisenslibrary.BuildConfig;

import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.LoggingData.LOGGINGDATA_DIR_TYPE;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.LoggingData.TBL_LOGGINGDATA;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.MOVISENSDATA_URI;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.TrackingData.*;
import static de.kn.uni.smartact.movisenslibrary.database.MovisensData.SensorData.*;


public class MovisensDataProvider extends ContentProvider {

    // helper constants for use with the UriMatcher
    private static final int TRACKINGDATA_LIST = 1;
    private static final int TRACKINGDATA_TIMESTAMP = 2;
    private static final int SENSORDATA_LIST = 5;
    private static final int LOGGINGDATA_LIST = 9;

    private MovisensDatabaseHelper mDatabaseHelper = null;
    private final ThreadLocal<Boolean> mIsInBatchMode = new ThreadLocal<Boolean>();

    // prepare the UriMatcher
    public static final UriMatcher URI_MATCHER;
    static {
        URI_MATCHER = new UriMatcher(UriMatcher.NO_MATCH);
        URI_MATCHER.addURI(MovisensData.AUTHORITY, TBL_TRACKINDATA, TRACKINGDATA_LIST);
        URI_MATCHER.addURI(MovisensData.AUTHORITY, TBL_TRACKINDATA + "/*", TRACKINGDATA_TIMESTAMP);
        URI_MATCHER.addURI(MovisensData.AUTHORITY, TBL_SENSORDATA, SENSORDATA_LIST);
        URI_MATCHER.addURI(MovisensData.AUTHORITY, TBL_LOGGINGDATA, LOGGINGDATA_LIST);
    }

    @Override
    public boolean onCreate() {
        mDatabaseHelper = new MovisensDatabaseHelper(getContext());
        return true;
    }

    @Override
    public int delete(Uri uri, String selection, String[] selectionArgs) {
        SQLiteDatabase db = mDatabaseHelper.getWritableDatabase();

        int delCount = 0;
        switch (URI_MATCHER.match(uri)) {
            case TRACKINGDATA_LIST:
                delCount = db.delete(TBL_TRACKINDATA, selection, selectionArgs);
                break;
            case TRACKINGDATA_TIMESTAMP:
                String timestamp = uri.getLastPathSegment();
                String where_tracking = COL_TIMESTAMP + " = " + timestamp;
                if (!TextUtils.isEmpty(selection)) {
                    where_tracking += " AND " + selection;
                }
                delCount = db.delete(TBL_TRACKINDATA, where_tracking, selectionArgs);
                break;
            case SENSORDATA_LIST:
                delCount = db.delete(TBL_SENSORDATA, selection, selectionArgs);
                break;
            default:
                throw new IllegalArgumentException("Unsupported URI: " + uri);
        }
        // notify all listeners of changes:
        if (delCount > 0 && !isInBatchMode()) {
            getContext().getContentResolver().notifyChange(uri, null);
        }
        return delCount;
    }

    @Override
    public String getType(Uri uri) {
        switch (URI_MATCHER.match(uri)) {
            case TRACKINGDATA_LIST:
                return TRACKINGDATA_DIR_TYPE;
            case TRACKINGDATA_TIMESTAMP:
                return TRACKINGDATA_ITEM_TYPE;
            case SENSORDATA_LIST:
                return SENSORDATA_DIR_TYPE;
            case LOGGINGDATA_LIST:
                return LOGGINGDATA_DIR_TYPE;
            default:
                throw new IllegalArgumentException("Unsupported URI: " + uri);
        }
    }

    @Override
    public Uri insert(Uri uri, ContentValues values) {
        SQLiteDatabase db = mDatabaseHelper.getWritableDatabase();
        long id = -1;

        switch (URI_MATCHER.match(uri)){
            case TRACKINGDATA_LIST:
                values.put(COL_PROCESSED, "false");
                id = db.insertWithOnConflict(TBL_TRACKINDATA, null, values, SQLiteDatabase.CONFLICT_IGNORE);

                if (values.containsKey(COL_TIMESTAMP)){
                    if (id == -1) {
                        if (values.containsKey(COL_UPDATED))
                            values.remove(COL_UPDATED);

                        db.update(TBL_TRACKINDATA, values, COL_TIMESTAMP+"=?", new String[] {values.get(COL_TIMESTAMP).toString()});
                    }
                }

                // notify all listeners of changes:
                if (!isInBatchMode()) {
                    getContext().getContentResolver().notifyChange(uri, null);
                }

                return getUriForId(id, uri);
            case SENSORDATA_LIST:
                int updateCount = db.update(TBL_SENSORDATA, values, null, null);

                if (updateCount == 0) {
                    id = db.insert(TBL_SENSORDATA, null, values);
                }

                // notify all listeners of changes:
                if (!isInBatchMode()) {
                    getContext().getContentResolver().notifyChange(uri, null);
                }

                return getUriForId(id, uri);
            case LOGGINGDATA_LIST:
                id = db.insert(TBL_LOGGINGDATA, null, values);

                // notify all listeners of changes:
                if (!isInBatchMode()) {
                    getContext().getContentResolver().notifyChange(uri, null);
                }

                return getUriForId(id, uri);
            default:
                throw new IllegalArgumentException("Unsupported URI for insertion: " + uri);
        }
    }

    private Uri getUriForId(long id, Uri uri) {
        Uri itemUri = ContentUris.withAppendedId(uri, id);
        if (!isInBatchMode()) {
            // notify all listeners of changes and return itemUri:
            getContext().getContentResolver().notifyChange(itemUri, null);
        }
        return itemUri;
    }

    @Override
    public Cursor query(Uri uri, String[] projection, String selection, String[] selectionArgs, String sortOrder) {
        SQLiteDatabase db = mDatabaseHelper.getReadableDatabase();

        SQLiteQueryBuilder builder = new SQLiteQueryBuilder();
        boolean useAuthorityUri = false;

        switch (URI_MATCHER.match(uri)) {
            case TRACKINGDATA_LIST:
                builder.setTables(TBL_TRACKINDATA);
                if (TextUtils.isEmpty(sortOrder)) {
                    sortOrder = TRACKINGDATA_SORT_ORDER_DEFAULT;
                }
                break;
            case TRACKINGDATA_TIMESTAMP:
                builder.setTables(TBL_TRACKINDATA);
                String timestamp = uri.getLastPathSegment();
                // limit query to one row at most:
                builder.appendWhere(COL_TIMESTAMP + " = " + timestamp);
                break;
            case SENSORDATA_LIST:
                builder.setTables(TBL_SENSORDATA);
                if (TextUtils.isEmpty(sortOrder)) {
                    sortOrder = SENSORDATA_SORT_ORDER_DEFAULT;
                }
                break;
            default:
                throw new IllegalArgumentException("Unsupported URI: " + uri);
        }

        // if you like you can log the query
        logQuery(builder,  projection, selection, sortOrder);

        Cursor cursor = builder.query(db, projection, selection, selectionArgs, null, null, sortOrder);

        // if we want to be notified of any changes:
        if (useAuthorityUri) {
            cursor.setNotificationUri(getContext().getContentResolver(), MOVISENSDATA_URI);
        } else {
            cursor.setNotificationUri(getContext().getContentResolver(), uri);
        }
        return cursor;
    }

    private void logQuery(SQLiteQueryBuilder builder, String[] projection, String selection, String sortOrder) {
        if (BuildConfig.DEBUG) {
            Log.v("movisenslibrary", "query: " + builder.buildQuery(projection, selection, null, null, sortOrder, null));
        }
    }

    @Override
    public int update(Uri uri, ContentValues values, String selection, String[] selectionArgs) {

        SQLiteDatabase db = mDatabaseHelper.getWritableDatabase();
        int updateCount = 0;
        switch (URI_MATCHER.match(uri)) {
            case TRACKINGDATA_LIST:
                updateCount = db.update(TBL_TRACKINDATA, values, selection, selectionArgs);
                break;
            case TRACKINGDATA_TIMESTAMP:
                String timestamp_tracking = uri.getLastPathSegment();
                String where_tracking = COL_TIMESTAMP + " = " + timestamp_tracking;
                if (!TextUtils.isEmpty(selection)) {
                    where_tracking += " AND " + selection;
                }
                updateCount = db.update(TBL_TRACKINDATA, values, where_tracking, selectionArgs);
                break;
            case SENSORDATA_LIST:
                updateCount = db.update(TBL_SENSORDATA, values, null, null);

                if (updateCount == 0) {
                    db.insert(TBL_SENSORDATA, null, values);
                    updateCount = 1;
                }

                break;
            default:
                // no support for updating photos!
                throw new IllegalArgumentException("Unsupported URI: " + uri);
        }
        // notify all listeners of changes:
        if (updateCount > 0 && !isInBatchMode()) {
            getContext().getContentResolver().notifyChange(uri, null);
        }
        return updateCount;
    }

    @Override
    public ContentProviderResult[] applyBatch(ArrayList<ContentProviderOperation> operations) throws OperationApplicationException {
        SQLiteDatabase db = mDatabaseHelper.getWritableDatabase();
        mIsInBatchMode.set(true);
        // the next line works because SQLiteDatabase
        // uses a thread local SQLiteSession object for
        // all manipulations
        db.beginTransaction();
        try {
            final ContentProviderResult[] retResult = super.applyBatch(operations);
            db.setTransactionSuccessful();
            getContext().getContentResolver().notifyChange(MOVISENSDATA_URI, null);
            return retResult;
        }
        finally {
            mIsInBatchMode.remove();
            db.endTransaction();
        }
    }

    private boolean isInBatchMode() {
        return mIsInBatchMode.get() != null && mIsInBatchMode.get();
    }
}
