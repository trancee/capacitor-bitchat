package com.getcapacitor.community.classes.options;

import androidx.annotation.Nullable;
import com.getcapacitor.PluginCall;

public class IsEstablishedOptions {

    @Nullable
    private String peerID;

    public IsEstablishedOptions(PluginCall call) {
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
