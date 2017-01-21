package rocks.festify;

import android.util.Log;

import com.spotify.sdk.android.player.ConnectionStateCallback;
import com.spotify.sdk.android.player.Error;

import rocks.festify.Emitter;

class ConnectionEventsHandler extends Emitter
        implements ConnectionStateCallback {
    private static final String TAG = "ConnectionEventsHandler";

    @Override
    public void onConnectionMessage(String message) {
        this.emit("connectionmessage", message);
    }

    @Override
    public void onLoggedIn() {
        this.emit("loggedin");
    }

    @Override
    public void onLoggedOut() {
        this.emit("loggedout");
    }

    @Override
    public void onLoginFailed(Error error) {
        this.emit("loginfailed", error);
    }

    @Override
    public void onTemporaryError() {
        this.emit("temporaryerror");
    }
}