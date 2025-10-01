package com.getcapacitor.community.classes.events;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.getcapacitor.JSObject;
import java.util.UUID;

public class MessageIDEvent {

    @Nullable
    UUID messageID;

    public MessageIDEvent(@Nullable UUID messageID) {
        this.messageID = messageID;
    }

    @NonNull
    public JSObject toJSObject() {
        JSObject result = new JSObject();

        if (messageID != null) result.put("messageID", messageID.toString());

        return result;
    }
}
