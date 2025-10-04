package com.getcapacitor.community.classes.options;

import androidx.annotation.Nullable;
import com.getcapacitor.PluginCall;

public class SendOptions {

    @Nullable
    private String message;

    @Nullable
    private String peerID;

    public SendOptions(PluginCall call) {
        @Nullable
        String message = call.getString("message");
        this.setMessage(message);

        @Nullable
        String peerID = call.getString("peerID");
        this.setPeerID(peerID);
    }

    private void setMessage(@Nullable String message) {
        this.message = message;
    }

    private void setPeerID(@Nullable String peerID) {
        this.peerID = peerID;
    }

    @Nullable
    public String getMessage() {
        return message;
    }

    @Nullable
    public String getPeerID() {
        return peerID;
    }
}
