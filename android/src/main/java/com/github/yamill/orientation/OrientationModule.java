package com.github.yamill.orientation;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.util.Log;
import android.view.OrientationEventListener;

import com.facebook.common.logging.FLog;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.ReactConstants;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.util.HashMap;
import java.util.Map;

import javax.annotation.Nullable;

public class OrientationModule extends ReactContextBaseJavaModule implements LifecycleEventListener{
    BroadcastReceiver mBroadcastReceiver;
    OrientationEventListener mDeviceOrientationListener;
    String mDeviceOrientationStr = "UNKNOWN";

    public OrientationModule(final ReactApplicationContext reactContext) {
        super(reactContext);

        mBroadcastReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                Configuration newConfig = intent.getParcelableExtra("newConfig");
                FLog.d(ReactConstants.TAG, "Activity orientation: " + newConfig.orientation);

                WritableMap params = Arguments.createMap();
                params.putString("orientation", OrientationModule.this.getOrientationString(newConfig.orientation));
                reactContext
                    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit("orientationDidChange", params);
            }
        };

        mDeviceOrientationListener = new OrientationEventListener(getReactApplicationContext()) {
            @Override
            public void onOrientationChanged(int orientation) {
                String orientationStr = OrientationModule.this.getDeviceOrientationString(orientation);
                if (!orientationStr.equals(mDeviceOrientationStr)) {
                    FLog.d(ReactConstants.TAG, "Device orientation: " + orientationStr);
                    mDeviceOrientationStr = orientationStr;

                    WritableMap params = Arguments.createMap();
                    params.putString("orientation", mDeviceOrientationStr);
                    reactContext
                        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                        .emit("deviceOrientationDidChange", params);
                }
            }
        };

        reactContext.addLifecycleEventListener(this);
    }

    @Override
    public String getName() {
        return "Orientation";
    }

    @ReactMethod
    public void getOrientation(Callback callback) {
        int orientationInt = getReactApplicationContext().getResources().getConfiguration().orientation;
        String orientation = this.getOrientationString(orientationInt);
        callback.invoke(orientation);
    }

    @ReactMethod
    public void getDeviceOrientation(Callback callback) {
        callback.invoke(mDeviceOrientationStr);
    }

    @ReactMethod
    public void lockToPortrait() {
        Activity activity = getCurrentActivity();
        if (activity == null) {
            return;
        }
        activity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
    }

    @ReactMethod
    public void lockToLandscape() {
        Activity activity = getCurrentActivity();
        if (activity == null) {
            return;
        }
        activity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);
    }

    @ReactMethod
    public void lockToLandscapeLeft() {
        Activity activity = getCurrentActivity();
        if (activity == null) {
            return;
        }
        activity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
    }

    @ReactMethod
    public void lockToLandscapeRight() {
        Activity activity = getCurrentActivity();
        if (activity == null) {
            return;
        }
        activity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE);
    }

    @ReactMethod
    public void unlockAllOrientations() {
        Activity activity = getCurrentActivity();
        if (activity == null) {
            return;
        }
        activity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED);
    }

    @Override
    public @Nullable Map<String, Object> getConstants() {
        HashMap<String, Object> constants = new HashMap<String, Object>();

        int orientationInt = getReactApplicationContext().getResources().getConfiguration().orientation;
        String orientation = this.getOrientationString(orientationInt);
        constants.put("initialOrientation", orientation);

        return constants;
    }

    private String getOrientationString(int orientation) {
        if (orientation == Configuration.ORIENTATION_LANDSCAPE) {
            return "LANDSCAPE";
        } else if (orientation == Configuration.ORIENTATION_PORTRAIT) {
            return "PORTRAIT";
        } else {
            return "UNKNOWN";
        }
    }

    private String getDeviceOrientationString(int orientation) {
        if (orientation < 0) {
            return "UNKNOWN";
        } else if (orientation <= 45) {
            return "PORTRAIT";
        } else if (orientation <= 135) {
            return "LANDSCAPE-RIGHT";
        } else if (orientation <= 225) {
            return "PORTRAIT-UPSIDEDOWN";
        } else if (orientation <= 315) {
            return "LANDSCAPE-LEFT";
        } else {
            return "PORTRAIT";
        }
    }

    @Override
    public void onHostResume() {
        Activity activity = getCurrentActivity();
        if (activity == null) {
            FLog.e(ReactConstants.TAG, "no activity to register receiver");
            return;
        }

        activity.registerReceiver(mBroadcastReceiver, new IntentFilter("onConfigurationChanged"));

        mDeviceOrientationListener.enable();
    }

    @Override
    public void onHostPause() {
        Activity activity = getCurrentActivity();
        if (activity == null) return;

        try {
            activity.unregisterReceiver(mBroadcastReceiver);
        } catch (java.lang.IllegalArgumentException e) {
            FLog.e(ReactConstants.TAG, "receiver already unregistered", e);
        }

        mDeviceOrientationListener.disable();
    }

    @Override
    public void onHostDestroy() {
    }
}
