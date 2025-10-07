package com.getcapacitor.community.classes.events;

import androidx.annotation.NonNull;

public class EstablishedEvent extends PeerIDEvent {

    public EstablishedEvent(@NonNull String peerID) {
        super(peerID);
    }
}
