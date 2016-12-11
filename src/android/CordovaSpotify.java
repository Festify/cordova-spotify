package rocks.festify;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Date;
import java.text.SimpleDateFormat;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;

import com.spotify.sdk.android.authentication.AuthenticationClient;
import com.spotify.sdk.android.authentication.AuthenticationRequest;
import com.spotify.sdk.android.authentication.AuthenticationResponse;
import com.spotify.sdk.android.player.Config;
import com.spotify.sdk.android.player.ConnectionStateCallback;
import com.spotify.sdk.android.player.Error;
import com.spotify.sdk.android.player.Player;
import com.spotify.sdk.android.player.PlayerEvent;
import com.spotify.sdk.android.player.Spotify;
import com.spotify.sdk.android.player.SpotifyPlayer;

import rocks.festify.LoginState;

public class CordovaSpotify extends CordovaPlugin
        implements ConnectionStateCallback, SpotifyPlayer.NotificationCallback {

    private static final int LOGIN_REQUEST_CODE = 1337;

    private LoginState loginState = null;
    private String clientId = "";
    private SpotifyPlayer player = null;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("authenticate")) {
            String urlScheme = args.getString(0);
            String clientId = args.getString(1);
            this.authenticate(callbackContext, clientId, urlScheme);
            return true;
        } else if(action.equals("initSession")) {
            String accessToken = args.getString(0);
            this.initSession(callbackContext, accessToken);
        }
        return false;
    }

    private void authenticate(CallbackContext callbackContext, String clientId, String urlScheme) {
        this.loginState = new LoginState(callbackContext, clientId);
        this.clientId = clientId;

        AuthenticationRequest.Builder builder = new AuthenticationRequest.Builder(
            clientId,
            AuthenticationResponse.Type.CODE,
            urlScheme + "://callback"
        );
        builder.setScopes(new String[]{"user-read-private", "streaming"});
        AuthenticationRequest request = builder.build();

        cordova.setActivityResultCallback(this);
        AuthenticationClient.openLoginActivity(this.cordova.getActivity(), LOGIN_REQUEST_CODE, request);
    }

    private void initSession(final CallbackContext callbackContext, String accessToken) {
        if(this.clientId == null || this.clientId.length() < 1) {
            callbackContext.error("Invalid clientId. Call authenticate first!");
        }

        Config playerConfig = new Config(
            this.cordova.getActivity().getApplicationContext(),
            accessToken,
            this.clientId
        );

        Spotify.getPlayer(
            playerConfig,
            this.cordova.getActivity(),
            new SpotifyPlayer.InitializationObserver() {
                @Override
                public void onInitialized(SpotifyPlayer spotifyPlayer) {
                    CordovaSpotify.this.player = spotifyPlayer;
                    spotifyPlayer.addConnectionStateCallback(CordovaSpotify.this);
                    spotifyPlayer.addNotificationCallback(CordovaSpotify.this);

                    callbackContext.success("Success");
                }

                @Override
                public void onError(Throwable throwable) {
                    callbackContext.error("Could not initialize player");
                }
            }
        );
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);

        // Check if result comes from the correct activity
        if (requestCode == LOGIN_REQUEST_CODE) {
            this.onLoginResult(resultCode, intent);
        }
    }

    private void onLoginResult(int resultCode, Intent intent) {
        final LoginState state = this.loginState;
        if(!LoginState.isValid(state)) {
            return;
        }
        this.loginState = null;

        final AuthenticationResponse response = AuthenticationClient.getResponse(resultCode, intent);
        if (response.getType() != AuthenticationResponse.Type.CODE) {
            state.getLoginCallbackContext().error("Wrong response type: " + response.getType().toString());
        } else {
            HashMap<String, String> responseMap = new HashMap();
            responseMap.put("code", response.getCode());
            state.getLoginCallbackContext().success(new JSONObject(responseMap));
        }
    }

    @Override
    public void onPlaybackEvent(PlayerEvent playerEvent) {
        Log.d("MainActivity", "Playback event received: " + playerEvent.name());
        switch (playerEvent) {
            // Handle event type as necessary
            default:
                break;
        }
    }

    @Override
    public void onPlaybackError(Error error) {
        Log.d("MainActivity", "Playback error received: " + error.name());
        switch (error) {
            // Handle error type as necessary
            default:
                break;
        }
    }

    @Override
    public void onLoggedIn() {
        Log.d("MainActivity", "User logged in");
    }

    @Override
    public void onLoggedOut() {
        Log.d("MainActivity", "User logged out");
    }

    @Override
    public void onLoginFailed(Error error) {
        Log.d("MainActivity", "Login failed");
    }

    @Override
    public void onTemporaryError() {
        Log.d("MainActivity", "Temporary error occurred");
    }

    @Override
    public void onConnectionMessage(String message) {
        Log.d("MainActivity", "Received connection message: " + message);
    }
}