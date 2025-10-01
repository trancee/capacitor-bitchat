package com.getcapacitor.community;

import static com.getcapacitor.community.BitchatHelper.makeUUID;

import android.content.Context;
import android.util.Base64;
import androidx.activity.ComponentActivity;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.bitchat.android.mesh.BluetoothMeshDelegate;
import com.bitchat.android.mesh.BluetoothMeshService;
import com.bitchat.android.model.BitchatMessage;
import com.bitchat.android.onboarding.BatteryOptimizationManager;
import com.bitchat.android.onboarding.PermissionManager;
import com.getcapacitor.community.classes.options.InitializeOptions;
import com.getcapacitor.community.classes.options.SendOptions;
import com.getcapacitor.community.classes.options.StartOptions;
import com.getcapacitor.community.classes.results.IsInitializedResult;
import com.getcapacitor.community.classes.results.IsStartedResult;
import com.getcapacitor.community.classes.results.SendResult;
import com.getcapacitor.community.interfaces.Callback;
import java.util.Collections;
import java.util.List;
import java.util.UUID;
import org.jetbrains.annotations.NotNull;

public class Bitchat {

    private final String MISSING_PERMISSIONS = "missing permissions";
    private final String BATTERY_OPTIMIZATION_DISABLED = "battery optimization disabled";
    private final String NOT_INITIALIZED = "not initialized";
    private final String NOT_STARTED = "not started";
    private final String MISSING_PAYLOAD = "missing payload";

    private boolean isInitialized = false;
    private boolean isStarted = false;

    @NonNull
    private final BitchatPlugin plugin;

    @NonNull
    private final BatteryOptimizationManager batteryOptimizationManager;

    @NonNull
    private final PermissionManager permissionManager;

    @NonNull
    private final BluetoothMeshService meshService;

    public Bitchat(@NonNull BitchatPlugin plugin) {
        this.plugin = plugin;

        ComponentActivity activity = plugin.getActivity();
        Context context = plugin.getContext();

        batteryOptimizationManager = new BatteryOptimizationManager(activity, context, () -> {
            System.out.println("Battery optimization disabled");
            return null;
        }, (message) -> {
            System.out.println("Battery optimization failed: " + message);
            return null;
        });

        // Initialize permission management
        permissionManager = new PermissionManager(context);
        // Initialize core mesh service first
        meshService = new BluetoothMeshService(context);
    }

    public void requestDisableBatteryOptimization() {
        if (permissionManager.isBatteryOptimizationSupported() && !permissionManager.isBatteryOptimizationDisabled()) {
            batteryOptimizationManager.requestDisableBatteryOptimization();
        }
    }
    /**
     * Initialize
     */

    public void initialize(@NonNull InitializeOptions options, @NonNull Callback callback) {
        if (!permissionManager.areAllPermissionsGranted()) {
            callback.error(new Exception(MISSING_PERMISSIONS));
            return;
        }

        meshService.setDelegate(
            new BluetoothMeshDelegate() {
                @Override
                public void didReceiveChannelLeave(@NotNull String channel, @NotNull String fromPeer) {
                    System.out.println("didReceiveChannelLeave: " + channel + ", " + fromPeer);
                }

                @Override
                public void didReceiveReadReceipt(@NotNull String messageID, @NotNull String recipientPeerID) {
                    System.out.println("didReceiveReadReceipt: " + messageID + ", " + recipientPeerID);
                }

                @Override
                public String getNickname() {
                    System.out.println("getNickname");
                    return "unknown";
                }

                @Override
                public void didReceiveMessage(@NotNull BitchatMessage message) {
                    String messageID = message.getId();
                    String content = message.getContent();
                    String peerID = message.getSenderPeerID();
                    byte[] data = Base64.decode(content, Base64.NO_WRAP);

                    plugin.onReceiveEvent(makeUUID(messageID), data, peerID);
                }

                @Override
                public String decryptChannelMessage(@NotNull byte[] encryptedContent, @NotNull String channel) {
                    System.out.println("decryptChannelMessage: " + encryptedContent + ", " + channel);
                    return "";
                }

                @Override
                public void didReceiveDeliveryAck(@NotNull String messageID, @NotNull String recipientPeerID) {
                    System.out.println("didReceiveDeliveryAck: " + messageID + ", " + recipientPeerID);
                }

                @Override
                public void didUpdatePeerList(@NotNull List<String> peers) {
                    System.out.println("didUpdatePeerList: " + peers);
                }

                @Override
                public boolean isFavorite(@NotNull String peerID) {
                    System.out.println("isFavorite: " + peerID);
                    return false;
                }

                @Override
                public void onStarted(@NotNull String peerID, boolean success) {
                    plugin.onStartedEvent(peerID);
                }

                @Override
                public void onStopped() {
                    plugin.onStoppedEvent();
                }

                @Override
                public void onDeviceConnected(@NotNull String peerID) {
                    plugin.onConnectedEvent(peerID);
                }

                @Override
                public void onDeviceDisconnected(@NotNull String peerID) {
                    plugin.onDisconnectedEvent(peerID);
                }

                @Override
                public void onRSSIUpdated(@NotNull String peerID, int rssi) {
                    plugin.onRSSIEvent(peerID, rssi);
                }
            }
        );

        isInitialized = true;

        callback.success();
    }

    public void isInitialized(@NonNull Callback callback) {
        IsInitializedResult result = new IsInitializedResult(isInitialized);
        callback.success(result);
    }

    public void start(@NonNull StartOptions options, @NonNull Callback callback) {
        if (!isInitialized) {
            callback.error(new Exception(NOT_INITIALIZED));
            return;
        }

        meshService.startServices();

        isStarted = true;

        callback.success();
    }

    public void isStarted(@NonNull Callback callback) {
        IsStartedResult result = new IsStartedResult(isStarted);
        callback.success(result);
    }

    public void stop(@NonNull Callback callback) {
        meshService.stopServices();

        isStarted = false;

        callback.success();
    }

    /**
     * Payload
     */

    public void send(@NonNull SendOptions options, @NonNull Callback callback) {
        if (!isInitialized) {
            callback.error(new Exception(NOT_INITIALIZED));
            return;
        }
        if (!isStarted) {
            callback.error(new Exception(NOT_STARTED));
            return;
        }

        @Nullable
        byte[] data = options.getData();
        @Nullable
        String content = options.getContent();

        if (data == null || content == null) {
            callback.error(new Exception(MISSING_PAYLOAD));
            return;
        }

        UUID messageID = UUID.randomUUID();

        @Nullable
        String peerID = options.getPeerID();

        if (peerID == null) {
            meshService.sendMessage(content, Collections.emptyList(), null);
        } else {
            meshService.sendPrivateMessage(content, peerID, "unknown", messageID.toString());
        }

        SendResult result = new SendResult(messageID);
        callback.success(result);
    }
}
