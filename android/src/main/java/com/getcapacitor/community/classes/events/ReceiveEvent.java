package com.getcapacitor.community.classes.events;

import android.util.Base64;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.getcapacitor.JSObject;
import java.util.UUID;

public class ReceiveEvent extends MessageIDEvent {

    @Nullable
    private final byte[] data;

    @Nullable
    private final String peerID;

    public ReceiveEvent(@NonNull UUID messageID, @Nullable byte[] data, @Nullable String peerID) {
        super(messageID);
        this.data = data;
        this.peerID = peerID;
    }

    @NonNull
    public JSObject toJSObject() {
        JSObject result = super.toJSObject();

        if (data != null && data.length > 0) {
            result.put("data", Base64.encodeToString(data, Base64.NO_WRAP));
        }

        if (peerID != null) {
            result.put("peerID", peerID);
        }

        return result;
    }
}
