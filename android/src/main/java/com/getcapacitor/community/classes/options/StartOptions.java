package com.getcapacitor.community.classes.options;

import android.util.Base64;
import androidx.annotation.Nullable;
import com.getcapacitor.PluginCall;

public class StartOptions {

    @Nullable
    private byte[] data;

    public StartOptions(PluginCall call) {
        @Nullable
        String data = call.getString("data");
        this.setData(data);
    }

    private void setData(@Nullable String data) {
        this.data = (data == null || data.isEmpty()) ? null : Base64.decode(data, Base64.NO_WRAP);
    }

    @Nullable
    public byte[] getData() {
        return data;
    }
}
