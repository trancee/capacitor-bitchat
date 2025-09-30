package com.getcapacitor.community.classes.events;

import androidx.annotation.NonNull;

public class DisconnectedEvent extends PeerIDEvent {

    public DisconnectedEvent(@NonNull String peerID) {
        super(peerID);
    }
}
