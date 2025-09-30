package com.getcapacitor.community.classes.events;

import androidx.annotation.NonNull;

public class StartedEvent extends PeerIDEvent {

    public StartedEvent(@NonNull String peerID) {
        super(peerID);
    }
}
