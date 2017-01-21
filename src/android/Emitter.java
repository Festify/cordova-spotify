package rocks.festify;

import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.apache.cordova.PluginResult.Status;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public abstract class Emitter {
    private static final String TAG = "Emitter";

    private CallbackContext ctx = null;

    public Emitter() { }

    public void setCallback(final CallbackContext ctx) {
        this.ctx = ctx;
    }

    protected void emit(final String eventName) {
        this.emit(eventName, new JSONArray());
    }

    protected void emit(final String eventName, final Object data) {
        String str = (data != null) ? data.toString() : "";
        this.emit(eventName, new JSONArray().put(str));
    }

    protected void emit(final String eventName, final JSONArray data) {
        if (eventName == null || eventName.length() < 1) {
            throw new IllegalArgumentException("eventName is null or empty!");
        }

        final CallbackContext ctx = this.ctx;
        if (ctx == null) {
            Log.d(
                TAG,
                "Emit '" + eventName + "' triggered, but CallbackContext was null."
            );
            return;
        }

        try {
            final JSONObject arg = new JSONObject()
                .put("name", eventName)
                .put("args", data);
            final PluginResult res = new PluginResult(PluginResult.Status.OK, arg);
            res.setKeepCallback(true);

            this.ctx.sendPluginResult(res);
        } catch (JSONException ex) {
            Log.e(
                TAG,
                "An error occured while encoding the JSON for raising event '" + eventName + "'.",
                ex
            );
        }
    }
}