package com.getcapacitor.community.classes.events;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.getcapacitor.JSObject;
import java.util.UUID;

public class ReceivedEvent extends MessageIDEvent {

    @NonNull
    private final String message;

    @Nullable
    private final String peerID;

    @Nullable
    private final Boolean isPrivate;

    @Nullable
    private final Boolean isRelay;

    public ReceivedEvent(
        @Nullable UUID messageID,
        @NonNull String message,
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

        result.put("message", message);

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
