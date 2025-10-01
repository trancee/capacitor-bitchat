package com.getcapacitor.community;

import android.Manifest;
import android.annotation.SuppressLint;
import android.os.Build;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.PermissionState;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.annotation.Permission;
import com.getcapacitor.annotation.PermissionCallback;
import com.getcapacitor.community.classes.events.ConnectedEvent;
import com.getcapacitor.community.classes.events.DisconnectedEvent;
import com.getcapacitor.community.classes.events.RSSIEvent;
import com.getcapacitor.community.classes.events.ReceiveEvent;
import com.getcapacitor.community.classes.events.SendEvent;
import com.getcapacitor.community.classes.events.StartedEvent;
import com.getcapacitor.community.classes.events.StoppedEvent;
import com.getcapacitor.community.classes.options.InitializeOptions;
import com.getcapacitor.community.classes.options.SendOptions;
import com.getcapacitor.community.classes.options.StartOptions;
import com.getcapacitor.community.interfaces.Callback;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.json.JSONException;

@CapacitorPlugin(
    name = "Bitchat",
    permissions = {
        @Permission(
            strings = {
                // Required to be able to discover and pair nearby Bluetooth devices.
                Manifest.permission.BLUETOOTH_SCAN,
                // Required to be able to advertise to nearby Bluetooth devices.
                Manifest.permission.BLUETOOTH_ADVERTISE,
                // Required to be able to connect to paired Bluetooth devices.
                Manifest.permission.BLUETOOTH_CONNECT
            },
            alias = "bluetooth"
        ),
        @Permission(
            strings = {
                // Allows an app to access approximate location.
                Manifest.permission.ACCESS_COARSE_LOCATION,
                // Allows an app to access precise location.
                Manifest.permission.ACCESS_FINE_LOCATION
            },
            alias = "location"
        ),
        @Permission(
            strings = {
                // Allows an app to ignore battery optimizations.
                Manifest.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
            },
            alias = "battery"
        )
    }
)
public class BitchatPlugin extends Plugin {

    // Initialization Listeners

    static final String STARTED_EVENT = "onStarted";
    static final String STOPPED_EVENT = "onStopped";

    // Connectivity Listeners

    static final String CONNECTED_EVENT = "onConnected";
    static final String DISCONNECTED_EVENT = "onDisconnected";

    // Transmission Listeners

    static final String SEND_EVENT = "onSend";
    static final String RECEIVE_EVENT = "onReceive";

    static final String RSSI_EVENT = "onRSSI";

    private Bitchat implementation;

    @Override
    public void load() {
        super.load();

        implementation = new Bitchat(this);
    }

    /**
     * Initialize
     */

    @PluginMethod
    public void initialize(PluginCall call) {
        Callback callback = new Callback(call) {};

        try {
            InitializeOptions options = new InitializeOptions(call);

            implementation.initialize(options, callback);
        } catch (Exception exception) {
            callback.error(exception);
        }
    }

    @PluginMethod
    public void isInitialized(PluginCall call) {
        Callback callback = new Callback(call) {};

        try {
            implementation.isInitialized(callback);
        } catch (Exception exception) {
            callback.error(exception);
        }
    }

    @PluginMethod
    public void start(PluginCall call) {
        Callback callback = new Callback(call) {};

        try {
            StartOptions options = new StartOptions(call);

            implementation.start(options, callback);
        } catch (Exception exception) {
            callback.error(exception);
        }
    }

    @PluginMethod
    public void isStarted(PluginCall call) {
        Callback callback = new Callback(call) {};

        try {
            implementation.isStarted(callback);
        } catch (Exception exception) {
            callback.error(exception);
        }
    }

    @PluginMethod
    public void stop(PluginCall call) {
        Callback callback = new Callback(call) {};

        try {
            implementation.stop(callback);
        } catch (Exception exception) {
            callback.error(exception);
        }
    }

    /**
     * Payload
     */

    @PluginMethod
    public void send(PluginCall call) {
        Callback callback = new Callback(call) {};

        try {
            SendOptions options = new SendOptions(call);

            implementation.send(options, callback);
        } catch (Exception exception) {
            callback.error(exception);
        }
    }

    /**
     * Permissions
     */

    @Override
    @PluginMethod
    public void checkPermissions(PluginCall call) {
        Map<String, PermissionState> permissionsResult = getPermissionStates();

        if (permissionsResult.isEmpty()) {
            call.resolve();
        } else {
            List<String> aliases = getAliases();

            JSObject result = new JSObject();

            for (Map.Entry<String, PermissionState> entry : permissionsResult.entrySet()) {
                if (aliases.contains(entry.getKey())) {
                    if (entry.getKey().equals("battery")) {
                        boolean isIgnoring = implementation.isBatteryOptimizationDisabled();
                        result.put(entry.getKey(), isIgnoring ? "granted" : "prompt");
                        continue;
                    }
                    result.put(entry.getKey(), entry.getValue());
                }
            }

            call.resolve(result);
        }
    }

    @SuppressLint("ObsoleteSdkInt")
    private List<String> getAliases() {
        List<String> aliases = new ArrayList<>();

        // SDK >= 31
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            aliases.add("bluetooth");
        }

        // SDK >= 23 && SDK <= 28
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && Build.VERSION.SDK_INT <= Build.VERSION_CODES.P) {
            aliases.add("location");
        }
        // SDK >= 29 && SDK <= 30
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && Build.VERSION.SDK_INT <= Build.VERSION_CODES.R) {
            aliases.add("location");
        }
        // SDK >= 31
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            aliases.add("location");
        }

        // SDK >= 23
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            aliases.add("battery");
        }

        return aliases;
    }

    @PermissionCallback
    private void permissionsCallback(PluginCall call) {
        this.checkPermissions(call);
    }

    @Override
    @PluginMethod
    @SuppressLint("ObsoleteSdkInt")
    public void requestPermissions(PluginCall call) {
        List<String> aliases = new ArrayList<>();

        JSArray permissions = call.getArray("permissions");

        if (permissions != null) {
            try {
                List<String> permissionsList = permissions.toList();
                for (String permission : permissionsList) {
                    switch (permission) {
                        case "bluetooth":
                            // SDK >= 31
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                                aliases.add("bluetooth");
                            }
                            break;
                        case "location":
                            // SDK >= 23 && SDK <= 28
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && Build.VERSION.SDK_INT <= Build.VERSION_CODES.P) {
                                aliases.add("location");
                            }
                            // SDK >= 29 && SDK <= 30
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && Build.VERSION.SDK_INT <= Build.VERSION_CODES.R) {
                                aliases.add("location");
                            }
                            // SDK >= 31
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                                aliases.add("location");
                            }
                            break;
                        case "battery":
                            // SDK >= 23
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                aliases.add("battery");

                                implementation.requestDisableBatteryOptimization();
                            }
                            break;
                    }
                }
            } catch (JSONException ignored) {
                aliases = getAliases();
            }
        } else {
            aliases = getAliases();
        }

        requestPermissionForAliases(aliases.toArray(new String[0]), call, "permissionsCallback");
    }

    /**
     * Initialization Listeners
     */

    protected void onStartedEvent(String peerID) {
        StartedEvent event = new StartedEvent(peerID);

        notifyListeners(STARTED_EVENT, event.toJSObject());
    }

    protected void onStoppedEvent() {
        StoppedEvent event = new StoppedEvent();

        notifyListeners(STOPPED_EVENT, event.toJSObject());
    }

    /**
     * Connectivity Listeners
     */

    protected void onConnectedEvent(String peerID) {
        ConnectedEvent event = new ConnectedEvent(peerID);

        notifyListeners(CONNECTED_EVENT, event.toJSObject());
    }

    protected void onDisconnectedEvent(String peerID) {
        DisconnectedEvent event = new DisconnectedEvent(peerID);

        notifyListeners(DISCONNECTED_EVENT, event.toJSObject());
    }

    /**
     * Transmission Listeners
     */

    protected void onSendEvent(UUID messageID) {
        SendEvent event = new SendEvent(messageID);

        notifyListeners(SEND_EVENT, event.toJSObject());
    }

    protected void onReceiveEvent(UUID messageID, byte[] data, String peerID) {
        ReceiveEvent event = new ReceiveEvent(messageID, data, peerID);

        notifyListeners(RECEIVE_EVENT, event.toJSObject());
    }

    protected void onRSSIEvent(String peerID, int rssi) {
        RSSIEvent event = new RSSIEvent(peerID, rssi);

        notifyListeners(RSSI_EVENT, event.toJSObject());
    }
}
