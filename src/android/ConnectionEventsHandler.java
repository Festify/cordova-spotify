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

    private final ArrayList<Player.OperationCallback> loginCallbacks = new ArrayList<Player.OperationCallback>();
    private final ArrayList<Runnable> logoutCallbacks = new ArrayList<Runnable>();

    @Override
    public void onConnectionMessage(String message) {
        this.emit("connectionmessage", message);
    }

    @Override
    public void onLoggedIn() {
        for (Player.OperationCallback item : this.loginCallbacks) {
            if (item != null) {
                item.onSuccess();
            }
        }
        loginCallbacks.clear();

        this.emit("loggedin");
    }

    public void onLoggedIn(Player.OperationCallback runnable) {
        this.loginCallbacks.add(runnable);
    }

    @Override
    public void onLoggedOut() {
        for (Runnable item : this.logoutCallbacks) {
            if (item != null) {
                item.run();
            }
        }
        logoutCallbacks.clear();

        this.emit("loggedout");
    }

    public void onLoggedOut(Runnable runnable) {
        this.logoutCallbacks.add(runnable);
    }

    @Override
    public void onLoginFailed(Error error) {
        for (Player.OperationCallback item : this.loginCallbacks) {
            if (item != null) {
                item.onError(error);
            }
        }
        loginCallbacks.clear();

        this.emit("loginfailed", error);
    }

    @Override
    public void onTemporaryError() {
        this.emit("temporaryerror");
    }
}