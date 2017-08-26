package rocks.festify;

import java.util.ArrayList;

import android.util.Log;

import com.spotify.sdk.android.player.ConnectionStateCallback;
import com.spotify.sdk.android.player.Error;
import com.spotify.sdk.android.player.Player;

import rocks.festify.Emitter;

class ConnectionEventsHandler extends Emitter
        implements ConnectionStateCallback {
    private static final String TAG = "ConnectionEventsHandler";

    private Player.OperationCallback loginCallback = null;
    private Runnable logoutCallback = null;

    @Override
    public void onConnectionMessage(String message) {
        this.emit("connectionmessage", message);
    }

    @Override
    public void onLoggedIn() {
        if (this.loginCallback != null) {
            this.loginCallback.onSuccess();
            this.loginCallback = null;
        }

        this.emit("loggedin");
    }

    public void onLoggedIn(Player.OperationCallback runnable) {
        this.loginCallback = runnable;
    }

    @Override
    public void onLoggedOut() {
        if (this.logoutCallback != null) {
            this.logoutCallback.run();
            this.logoutCallback = null;
        }

        this.emit("loggedout");
    }

    public void onLoggedOut(Runnable runnable) {
        this.logoutCallback = runnable;
    }

    @Override
    public void onLoginFailed(Error error) {
        if (this.loginCallback != null) {
            this.loginCallback.onError(error);
            this.loginCallback = null;
        }

        this.emit("loginfailed", error);
    }

    @Override
    public void onTemporaryError() {
        this.emit("temporaryerror");
    }
}