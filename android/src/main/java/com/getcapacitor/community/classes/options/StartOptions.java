package com.getcapacitor.community.classes.options;

import androidx.annotation.Nullable;
import com.getcapacitor.PluginCall;

public class StartOptions {

    @Nullable
    private String message;

    public StartOptions(PluginCall call) {
        @Nullable
        String message = call.getString("message");
        this.setMessage(message);
    }

    private void setMessage(@Nullable String message) {
        this.message = message;
    }

    @Nullable
    public String getMessage() {
        return message;
    }
}
