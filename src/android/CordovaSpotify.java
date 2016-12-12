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
import com.spotify.sdk.android.player.PlaybackState;
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
            JSONArray scopes = args.getJSONArray(2);
            this.authenticate(callbackContext, clientId, urlScheme, scopes);
            return true;
        } else if(action.equals("initSession")) {
            String accessToken = args.getString(0);
            this.initSession(callbackContext, accessToken);
            return true;
        } else if(action.equals("play")) {
            if(!args.isNull(0)) {
                String trackUri = args.getString(0);
                this.play(callbackContext, trackUri);
            } else {
                this.play(callbackContext);
            }
            return true;
        } else if(action.equals("pause")) {
            this.pause(callbackContext);
            return true;
        } else {
            return false;
        }
    }

    /*
     * API Functions
     */

    private void authenticate(CallbackContext callbackContext, String clientId, String urlScheme, JSONArray jsonScopes) {
        AuthenticationRequest.Builder builder = new AuthenticationRequest.Builder(
            clientId,
            AuthenticationResponse.Type.CODE,
            urlScheme + "://callback"
        );
        String[] scopes = new String[jsonScopes.length()];
        for(int i=0; i < jsonScopes.length(); i++) {
            try {
                scopes[i] = jsonScopes.getString(i);
            } catch(JSONException e) {
                callbackContext.error("scopes array could not be parsed");
                return;
            }
        }
        builder.setScopes(scopes);
        AuthenticationRequest request = builder.build();

        this.loginState = new LoginState(callbackContext, clientId);
        this.clientId = clientId;

        cordova.setActivityResultCallback(this);
        AuthenticationClient.openLoginActivity(this.cordova.getActivity(), LOGIN_REQUEST_CODE, request);
    }

    private void initSession(final CallbackContext callbackContext, String accessToken) {
        if(this.clientId == null || this.clientId.length() < 1) {
            callbackContext.error("Invalid clientId. Call authenticate first!");
            return;
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

    private void play(final CallbackContext callbackContext, String trackUri) {
        SpotifyPlayer player = this.player;

        if(player == null) {
            callbackContext.error("Invalid player. Please call initSession first!");
            return;
        }

        if(trackUri != null && trackUri.length() > 0) {
            player.playUri(new Player.OperationCallback() {
                @Override
                public void onSuccess() {
                    callbackContext.success("Success");
                }

                @Override
                public void onError(Error error) {
                    callbackContext.error("Playing of track failed: " + error.toString());
                }
            }, trackUri, 0, 0);
        } else {
            // resume
            this.play(callbackContext);
        }
    }

    private void play(final CallbackContext callbackContext) {
        SpotifyPlayer player = this.player;

        if(player == null) {
            callbackContext.error("Invalid player. Please call initSession first!");
            return;
        }

        // resume
        player.resume(new Player.OperationCallback() {
            @Override
            public void onSuccess() {
                callbackContext.success("Success");
            }

            @Override
            public void onError(Error error) {
                callbackContext.error("Resume failed: " + error.toString());
            }
        });
    }

    private void pause(final CallbackContext callbackContext) {
        SpotifyPlayer player = this.player;

        PlaybackState state = player.getPlaybackState();
        if(!state.isPlaying) {
            callbackContext.success("Not playing");
            return;
        }

        player.pause(new Player.OperationCallback() {
            @Override
            public void onSuccess() {
                callbackContext.success("Success");
            }

            @Override
            public void onError(Error error) {
                callbackContext.error("Pausing failed: " + error.toString());
            }
        });
    }

    /*
     * CALLBACKS
     */

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