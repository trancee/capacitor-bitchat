package com.getcapacitor.community.classes.events;

import androidx.annotation.NonNull;
import com.getcapacitor.JSObject;

public class PeerIDEvent {

    @NonNull
    String peerID;

    public PeerIDEvent(@NonNull String peerID) {
        this.peerID = peerID;
    }

    @NonNull
    public JSObject toJSObject() {
        JSObject result = new JSObject();

        result.put("peerID", peerID);

        return result;
    }
}
