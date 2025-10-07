package com.getcapacitor.community.classes.options;

import androidx.annotation.Nullable;
import com.getcapacitor.PluginCall;

public class IsEstablishOptions {

    @Nullable
    private String peerID;

    public IsEstablishOptions(PluginCall call) {
        @Nullable
        String peerID = call.getString("peerID");
        this.setPeerID(peerID);
    }

    private void setPeerID(@Nullable String peerID) {
        this.peerID = peerID;
    }

    @Nullable
    public String getPeerID() {
        return peerID;
    }
}
