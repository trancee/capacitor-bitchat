package com.getcapacitor.community.classes.events;

import androidx.annotation.NonNull;

public class FoundEvent extends PeerIDEvent {

    public FoundEvent(@NonNull String peerID) {
        super(peerID);
    }
}
