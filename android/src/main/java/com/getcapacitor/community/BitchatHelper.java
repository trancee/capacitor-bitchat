package com.getcapacitor.community;

import android.annotation.SuppressLint;
import android.content.Context;
import android.provider.Settings.Secure;
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
            // 2d42ba2c3608376cba3d2d0121517410
            if (value.length() == 32) {
                // 2d42ba2c-3608-376c-ba3d-2d0121517410
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

    //    @Nullable
    //    public static UUID getDeviceID(Context context) {
    //        // https://developer.android.com/identity/user-data-ids
    //        @SuppressLint("HardwareIds")
    //        String androidID = Secure.getString(context.getContentResolver(), Secure.ANDROID_ID).trim().toLowerCase();
    //
    //        if (androidID.isEmpty() || "9774d56d682e549c".equals(androidID)) {
    //            return null;
    //        }
    //
    //        return UUID.nameUUIDFromBytes(androidID.getBytes());
    //    }
}
