package com.getcapacitor.community.classes.events;

import androidx.annotation.NonNull;

public class ConnectedEvent extends PeerIDEvent {

    public ConnectedEvent(@NonNull String peerID) {
        super(peerID);
    }
}
