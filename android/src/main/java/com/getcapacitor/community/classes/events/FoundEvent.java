package com.getcapacitor.community.classes.events;

import androidx.annotation.NonNull;
import com.getcapacitor.JSObject;

public class FoundEvent extends PeerIDEvent {

    @NonNull
    private final String message;

    public FoundEvent(@NonNull String peerID, @NonNull String message) {
        super(peerID);
        this.message = message;
    }

    @NonNull
    public JSObject toJSObject() {
        JSObject result = super.toJSObject();

        result.put("message", message);

        return result;
    }
}
