package com.getcapacitor.community.classes.options;

import android.util.Base64;
import androidx.annotation.Nullable;
import com.getcapacitor.PluginCall;

public class SendOptions {

    @Nullable
    private byte[] message;

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
        this.message = (message == null || message.isEmpty()) ? null : Base64.decode(message, Base64.NO_WRAP);
    }

    private void setPeerID(@Nullable String peerID) {
        this.peerID = peerID;
    }

    @Nullable
    public byte[] getMessage() {
        return message;
    }

    @Nullable
    public String getPeerID() {
        return peerID;
    }
}
