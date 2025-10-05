package com.getcapacitor.community.classes.options;

import androidx.annotation.Nullable;
import com.getcapacitor.PluginCall;

public class InitializeOptions {

    @Nullable
    private Long announceInterval;

    public InitializeOptions(PluginCall call) {
        @Nullable
        Long announceInterval = call.getLong("announceInterval");
        this.setAnnounceInterval(announceInterval);
    }

    private void setAnnounceInterval(@Nullable Long announceInterval) {
        this.announceInterval = announceInterval;
    }

    @Nullable
    public Long getAnnounceInterval() {
        return announceInterval;
    }
}
