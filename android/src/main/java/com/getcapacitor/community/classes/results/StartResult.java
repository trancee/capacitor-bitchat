package com.getcapacitor.community.classes.results;

import com.getcapacitor.JSObject;
import com.getcapacitor.community.interfaces.Result;

public class StartResult implements Result {

    private final String peerID;

    public StartResult(String peerID) {
        this.peerID = peerID;
    }

    @Override
    public JSObject toJSObject() {
        JSObject result = new JSObject();

        if (peerID != null) result.put("peerID", peerID);

        return result;
    }
}
