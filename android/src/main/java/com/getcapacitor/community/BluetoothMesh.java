package com.getcapacitor.community;

import static com.getcapacitor.community.BluetoothMeshHelper.makeUUID;

import android.content.Context;
import android.util.Base64;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.bitchat.android.mesh.BluetoothMeshDelegate;
import com.bitchat.android.mesh.BluetoothMeshService;
import com.bitchat.android.model.BitchatMessage;
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

public class BluetoothMesh {

    private final String MISSING_PAYLOAD = "missing payload";

    private boolean isInitialized = false;
    private boolean isStarted = false;

    @NonNull
    private final BluetoothMeshPlugin plugin;

    @NonNull
    private final PermissionManager permissionManager;

    @NonNull
    private final BluetoothMeshService meshService;

    public BluetoothMesh(@NonNull BluetoothMeshPlugin plugin) {
        this.plugin = plugin;

        Context context = plugin.getContext();

        // Initialize permission management
        permissionManager = new PermissionManager(context);
        // Initialize core mesh service first
        meshService = new BluetoothMeshService(context);
    }

    /**
     * Initialize
     */

    public void initialize(@NonNull InitializeOptions options, @NonNull Callback callback) {
        // @Nullable
        // Boolean verboseLogging = options.getVerboseLogging() != null ? options.getVerboseLogging() : config.getVerboseLogging();

        if (!permissionManager.areAllPermissionsGranted()) {
            callback.error(new Exception("missing permissions"));
            return;
        }

        //        if (permissionManager.isBatteryOptimizationSupported() && !permissionManager.isBatteryOptimizationDisabled()) {
        //            callback.error(new Exception("battery optimization disabled"));
        //            return;
        //        }

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
                    return "";
                }

                @Override
                public void didReceiveMessage(@NotNull BitchatMessage message) {
                    System.out.println("didReceiveMessage: " + message);

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
                    System.out.println("onDeviceConnected: " + peerID);

                    plugin.onConnectedEvent(peerID);
                }

                @Override
                public void onDeviceDisconnected(@NotNull String peerID) {
                    System.out.println("onDeviceDisconnected: " + peerID);

                    plugin.onDisconnectedEvent(peerID);
                }

                @Override
                public void onRSSIUpdated(@NotNull String peerID, int rssi) {
                    System.out.println("onRSSIUpdated: " + peerID + ", " + rssi);

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
            callback.error(new Exception("not initialized"));
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
            callback.error(new Exception("not initialized"));
            return;
        }
        if (!isStarted) {
            callback.error(new Exception("not started"));
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
