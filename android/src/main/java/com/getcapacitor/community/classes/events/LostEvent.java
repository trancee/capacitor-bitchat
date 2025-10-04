package com.getcapacitor.community.classes.events;

import androidx.annotation.NonNull;

public class LostEvent extends PeerIDEvent {

    public LostEvent(@NonNull String peerID) {
        super(peerID);
    }
}
