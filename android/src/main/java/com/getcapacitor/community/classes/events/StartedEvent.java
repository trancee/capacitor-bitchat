package com.getcapacitor.community.classes.events;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.getcapacitor.JSObject;

public class StartedEvent extends PeerIDEvent {

    @Nullable
    Boolean isStarted;

    public StartedEvent(@NonNull String peerID, @Nullable Boolean isStarted) {
        super(peerID);
        this.isStarted = isStarted;
    }

    @NonNull
    public JSObject toJSObject() {
        JSObject result = super.toJSObject();

        if (isStarted != null) result.put("isStarted", isStarted);

        return result;
    }
}
