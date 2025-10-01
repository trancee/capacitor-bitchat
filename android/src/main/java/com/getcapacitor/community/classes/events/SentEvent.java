package com.getcapacitor.community.classes.events;

import android.util.Base64;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.getcapacitor.JSObject;
import java.util.UUID;

public class SentEvent extends MessageIDEvent {

    @Nullable
    String peerID;

    public SentEvent(@NonNull UUID messageID, @Nullable String peerID) {
        super(messageID);
        this.peerID = peerID;
    }

    @NonNull
    public JSObject toJSObject() {
        JSObject result = super.toJSObject();

        if (peerID != null) {
            result.put("peerID", peerID);
        }

        return result;
    }
}
