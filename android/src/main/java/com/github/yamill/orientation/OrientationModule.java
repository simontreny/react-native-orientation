package com.github.yamill.orientation;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.view.OrientationEventListener;
import android.view.Surface;
import android.view.WindowManager;

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
                int rotation = intent.getIntExtra("rotation", 0);
                FLog.d(ReactConstants.TAG, "Activity orientation: " + newConfig.orientation + ", " + rotation);

                WritableMap params = Arguments.createMap();
                params.putString("orientation", OrientationModule.this.getOrientationString(newConfig.orientation, rotation));
                reactContext
                    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit("interfaceOrientationDidChange", params);
            }
        };

        mDeviceOrientationListener = new OrientationEventListener(getReactApplicationContext()) {
            @Override
            public void onOrientationChanged(int orientation) {
                if (!OrientationModule.this.isDeviceOrientationUnchanged(orientation)) {
                    mDeviceOrientationStr = OrientationModule.this.getDeviceOrientationString(orientation);
                    FLog.d(ReactConstants.TAG, "Device orientation: " + mDeviceOrientationStr);

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
    public void getInterfaceOrientation(Callback callback) {
        callback.invoke(this.getInterfaceOrientationString());
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

        String orientation = this.getInterfaceOrientationString();
        constants.put("initialInterfaceOrientation", orientation);
        constants.put("initialDeviceOrientation", orientation);

        return constants;
    }

    private String getInterfaceOrientationString() {
        int orientation = getReactApplicationContext().getResources().getConfiguration().orientation;
        WindowManager windowManager = (WindowManager) getReactApplicationContext().getSystemService(Context.WINDOW_SERVICE);
        int rotation = windowManager.getDefaultDisplay().getRotation();
        return getOrientationString(orientation, rotation);
    }

    private String getOrientationString(int orientation, int rotation) {
        if (orientation == Configuration.ORIENTATION_LANDSCAPE) {
            return (rotation == Surface.ROTATION_90) ? "LANDSCAPE-LEFT" : "LANDSCAPE-RIGHT";
        } else if (orientation == Configuration.ORIENTATION_PORTRAIT) {
            return (rotation == Surface.ROTATION_0) ? "PORTRAIT" : "PORTRAIT-UPSIDEDOWN";
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

    private boolean isDeviceOrientationUnchanged(int orientation) {
        if (orientation < 0) {
            return mDeviceOrientationStr.equals("UNKNOWN");
        }

        if (mDeviceOrientationStr.equals("PORTRAIT")) {
            return orientation <= 60 || orientation >= 300;
        } else if (mDeviceOrientationStr.equals("PORTRAIT-UPSIDEDOWN")) {
            return orientation >= 120 && orientation <= 240;
        } else if (mDeviceOrientationStr.equals("LANDSCAPE-LEFT")) {
            return orientation >= 210 && orientation <= 330;
        } else if (mDeviceOrientationStr.equals("LANDSCAPE-RIGHT")) {
            return orientation >= 30 && orientation <= 150;
        } else { // "UNKNOWN"
            return orientation < 0;
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
