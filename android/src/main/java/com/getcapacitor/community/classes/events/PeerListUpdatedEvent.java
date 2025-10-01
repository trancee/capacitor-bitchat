package com.getcapacitor.community.classes.events;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import java.util.List;

public class PeerListUpdatedEvent {

    @NonNull
    List<String> peers;

    public PeerListUpdatedEvent(@NonNull List<String> peers) {
        this.peers = peers;
    }

    @Nullable
    public JSObject toJSObject() {
        JSObject result = new JSObject();

        JSArray jsPeers = new JSArray();

        for (String peer : peers) {
            jsPeers.put(peer);
        }

        result.put("peers", jsPeers);

        return result;
    }
}
