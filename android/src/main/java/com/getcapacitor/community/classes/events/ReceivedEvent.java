package com.getcapacitor.community.classes.events;

import android.util.Base64;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.getcapacitor.JSObject;
import java.util.UUID;

public class ReceivedEvent extends MessageIDEvent {

    @NonNull
    private final byte[] message;

    @Nullable
    private final String peerID;

    @Nullable
    private final Boolean isPrivate;

    @Nullable
    private final Boolean isRelay;

    public ReceivedEvent(
        @Nullable UUID messageID,
        @NonNull byte[] message,
        @Nullable String peerID,
        @Nullable Boolean isPrivate,
        @Nullable Boolean isRelay
    ) {
        super(messageID);
        this.message = message;
        this.peerID = peerID;

        this.isPrivate = isPrivate;
        this.isRelay = isRelay;
    }

    @NonNull
    public JSObject toJSObject() {
        JSObject result = super.toJSObject();

        if (message.length > 0) {
            result.put("message", Base64.encodeToString(message, Base64.NO_WRAP));
        }

        if (peerID != null) {
            result.put("peerID", peerID);
        }

        if (isPrivate != null) {
            result.put("isPrivate", isPrivate);
        }

        if (isRelay != null) {
            result.put("isRelay", isRelay);
        }

        return result;
    }
}
