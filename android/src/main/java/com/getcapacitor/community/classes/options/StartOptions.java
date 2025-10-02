package com.getcapacitor.community.classes.options;

import android.util.Base64;
import androidx.annotation.Nullable;
import com.getcapacitor.PluginCall;

public class StartOptions {

    @Nullable
    private byte[] message;

    public StartOptions(PluginCall call) {
        @Nullable
        String message = call.getString("message");
        this.setMessage(message);
    }

    private void setMessage(@Nullable String message) {
        this.message = (message == null || message.isEmpty()) ? null : Base64.decode(message, Base64.NO_WRAP);
    }

    @Nullable
    public byte[] getMessage() {
        return message;
    }
}
