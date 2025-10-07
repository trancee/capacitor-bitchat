package com.getcapacitor.community.classes.results;

import com.getcapacitor.JSObject;
import com.getcapacitor.community.interfaces.Result;

public class EstablishResult implements Result {

    private final Boolean isEstablished;

    public EstablishResult(Boolean isEstablished) {
        this.isEstablished = isEstablished;
    }

    @Override
    public JSObject toJSObject() {
        JSObject result = new JSObject();

        if (isEstablished != null) result.put("isEstablished", isEstablished);

        return result;
    }
}
