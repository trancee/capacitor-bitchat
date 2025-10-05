package com.getcapacitor.community;

import androidx.annotation.Nullable;

public class BitchatConfig {

    @Nullable
    Long announceInterval;

    public BitchatConfig(@Nullable Long announceInterval) {
        this.setAnnounceInterval(announceInterval);
    }

    public void setAnnounceInterval(@Nullable Long announceInterval) {
        this.announceInterval = announceInterval;
    }

    @Nullable
    public Long getAnnounceInterval() {
        return announceInterval;
    }
}
