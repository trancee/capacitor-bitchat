package com.getcapacitor.community.classes.options;

import android.util.Base64;
import androidx.annotation.Nullable;
import com.getcapacitor.PluginCall;

public class SendOptions {

    @Nullable
    private byte[] data;

    @Nullable
    private String content;

    @Nullable
    private String peerID;

    public SendOptions(PluginCall call) {
        @Nullable
        String data = call.getString("data");
        this.setData(data);

        @Nullable
        String peerID = call.getString("peerID");
        this.setPeerID(peerID);
    }

    private void setData(@Nullable String data) {
        this.content = data;
        this.data = (data == null || data.isEmpty()) ? null : Base64.decode(data, Base64.NO_WRAP);
    }

    private void setPeerID(@Nullable String peerID) {
        this.peerID = peerID;
    }

    @Nullable
    public byte[] getData() {
        return data;
    }

    @Nullable
    public String getContent() {
        return content;
    }

    @Nullable
    public String getPeerID() {
        return peerID;
    }
}
