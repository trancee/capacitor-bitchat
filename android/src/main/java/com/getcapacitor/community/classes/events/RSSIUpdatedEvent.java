package com.getcapacitor.community.classes.events;

import androidx.annotation.NonNull;
import com.getcapacitor.JSObject;

public class RSSIUpdatedEvent extends PeerIDEvent {

    int rssi;

    public RSSIUpdatedEvent(@NonNull String peerID, int rssi) {
        super(peerID);
        this.rssi = rssi;
    }

    @NonNull
    public JSObject toJSObject() {
        JSObject result = super.toJSObject();

        result.put("rssi", rssi);

        return result;
    }
}
