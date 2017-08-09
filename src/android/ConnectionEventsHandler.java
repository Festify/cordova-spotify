package rocks.festify;

import java.util.ArrayList;

import android.util.Log;

import com.spotify.sdk.android.player.ConnectionStateCallback;
import com.spotify.sdk.android.player.Error;

import rocks.festify.Emitter;

class ConnectionEventsHandler extends Emitter
        implements ConnectionStateCallback {
    private static final String TAG = "ConnectionEventsHandler";

    private ArrayList<Runnable> loginCallbacks = new ArrayList<Runnable>();

    @Override
    public void onConnectionMessage(String message) {
        this.emit("connectionmessage", message);
    }

    @Override
    public void onLoggedIn() {
        for (Runnable item : this.loginCallbacks) {
            if (item != null) {
                item.run();
            }
        }
        this.loginCallbacks.clear();

        this.emit("loggedin");
    }

    public void onLoggedIn(Runnable runnable) {
        this.loginCallbacks.add(runnable);
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