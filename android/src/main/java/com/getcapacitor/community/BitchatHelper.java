package com.getcapacitor.community;

import androidx.annotation.Nullable;
import com.getcapacitor.JSObject;
import java.util.UUID;

public class BitchatHelper {

    @Nullable
    public static Boolean makeBoolean(@Nullable String value) {
        if (value == null || value.isEmpty()) return null;

        try {
            return Boolean.parseBoolean(value);
        } catch (Exception ignored) {
            return null;
        }
    }

    @Nullable
    public static UUID makeUUID(@Nullable String value) {
        if (value == null || value.isEmpty()) return null;

        try {
            if (value.length() == 32) {
                value =
                    value.substring(0, 8) +
                    "-" +
                    value.substring(8, 12) +
                    "-" +
                    value.substring(12, 16) +
                    "-" +
                    value.substring(16, 20) +
                    "-" +
                    value.substring(20);
            }
            return UUID.fromString(value);
        } catch (Exception ignored) {
            return null;
        }
    }

    @Nullable
    public static JSObject makeEvent(@Nullable JSObject event) {
        return event != null ? new JSObject().put("event", event) : null;
    }
}
