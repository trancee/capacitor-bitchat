package com.getcapacitor.community.classes.events;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.getcapacitor.JSObject;

public class PeerIDChangedEvent extends PeerIDEvent {

    @Nullable
    private final String oldPeerID;

    @NonNull
    private final String message;

    public PeerIDChangedEvent(@NonNull String peerID, @Nullable String oldPeerID, @NonNull String message) {
        super(peerID);
        this.oldPeerID = oldPeerID;
        this.message = message;
    }

    @NonNull
    public JSObject toJSObject() {
        JSObject result = super.toJSObject();

        if (oldPeerID != null) {
            result.put("oldPeerID", oldPeerID);
        }

        result.put("message", message);

        return result;
    }
}
