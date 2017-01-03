package rocks.festify;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Date;
import java.text.SimpleDateFormat;

import android.app.Activity;
import android.content.Intent;

import com.spotify.sdk.android.authentication.AuthenticationClient;
import com.spotify.sdk.android.authentication.AuthenticationRequest;
import com.spotify.sdk.android.authentication.AuthenticationResponse;
import com.spotify.sdk.android.player.Config;
import com.spotify.sdk.android.player.ConnectionStateCallback;
import com.spotify.sdk.android.player.Error;
import com.spotify.sdk.android.player.Player;
import com.spotify.sdk.android.player.PlaybackState;
import com.spotify.sdk.android.player.Spotify;
import com.spotify.sdk.android.player.SpotifyPlayer;

import rocks.festify.ConnectionEventsHandler;
import rocks.festify.PlayerEventsHandler;

public class CordovaSpotify extends CordovaPlugin {
    private static final int LOGIN_REQUEST_CODE = 1337;

    private String clientId = null;
    private LoginState loginState = null;
    private SpotifyPlayer player = null;

    private ConnectionEventsHandler connectionEventsHandler = new ConnectionEventsHandler();
    private PlayerEventsHandler playerEventsHandler = new PlayerEventsHandler();

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext)
            throws JSONException {
        if ("authenticate".equals(action)) {
            String urlScheme = args.getString(0);
            String clientId = args.getString(1);
            JSONArray scopes = args.getJSONArray(2);
            this.authenticate(callbackContext, clientId, urlScheme, scopes);
            return true;
        } else if ("initSession".equals(action)) {
            String accessToken = args.getString(0);
            this.initSession(callbackContext, accessToken);
            return true;
        } else if ("play".equals(action)) {
            if (!args.isNull(0)) {
                String trackUri = args.getString(0);
                this.play(callbackContext, trackUri);
            } else {
                this.play(callbackContext);
            }
            return true;
        } else if ("pause".equals(action)) {
            this.pause(callbackContext);
            return true;
        } else if ("registerEventsListener".equals(action)) {
            this.registerEventsListener(callbackContext);
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
        for (int i = 0; i < jsonScopes.length(); i++) {
            try {
                scopes[i] = jsonScopes.getString(i);
            } catch (JSONException e) {
                callbackContext.error("OAuth scopes array could not be parsed.");
                return;
            }
        }
        builder.setScopes(scopes);

        this.loginState = new LoginState(callbackContext, clientId);
        this.clientId = clientId;

        cordova.setActivityResultCallback(this);
        AuthenticationClient.openLoginActivity(this.cordova.getActivity(), LOGIN_REQUEST_CODE, builder.build());
    }

    private void initSession(final CallbackContext callbackContext, String accessToken) {
        String clientId = this.clientId;
        if (clientId == null || clientId.length() < 1) {
            callbackContext.error("Invalid clientId. Call authenticate first!");
            return;
        }

        Config playerConfig = new Config(
            this.cordova.getActivity().getApplicationContext(),
            accessToken,
            clientId
        );

        Spotify.getPlayer(playerConfig, this.cordova.getActivity(), new SpotifyPlayer.InitializationObserver() {
            @Override
            public void onInitialized(SpotifyPlayer spotifyPlayer) {
                CordovaSpotify.this.player = spotifyPlayer;
                spotifyPlayer.addConnectionStateCallback(CordovaSpotify.this.connectionEventsHandler);
                spotifyPlayer.addNotificationCallback(CordovaSpotify.this.playerEventsHandler);

                callbackContext.success("Success");
            }

            @Override
            public void onError(Throwable throwable) {
                callbackContext.error("Could not initialize player: " + throwable.toString());
            }
        });
    }

    private void play(final CallbackContext callbackContext) {
        SpotifyPlayer player = this.player;
        if (player == null) {
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

    private void play(final CallbackContext callbackContext, String trackUri) {
        SpotifyPlayer player = this.player;
        if (player == null) {
            callbackContext.error("Invalid player. Please call initSession first!");
            return;
        }

        if (trackUri != null && trackUri.length() > 0) {
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

    private void pause(final CallbackContext callbackContext) {
        SpotifyPlayer player = this.player;
        if (player == null) {
            callbackContext.error("Invalid player. Please call initSession first!");
            return;
        }

        PlaybackState state = player.getPlaybackState();
        if (!state.isPlaying) {
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

    private void registerEventsListener(final CallbackContext callbackContext) {
        this.connectionEventsHandler.setCallback(callbackContext);
        this.playerEventsHandler.setCallback(callbackContext);

        final PluginResult res = new PluginResult(PluginResult.Status.OK);
        res.setKeepCallback(true);
        callbackContext.sendPluginResult(res);
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
        if (!LoginState.isValid(state)) {
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
}

class LoginState {
    private CallbackContext loginCallbackContext = null;
    private String clientId = "";

    public LoginState(CallbackContext loginCallbackContext, String clientId) {
        this.loginCallbackContext = loginCallbackContext;
        this.clientId = clientId;
    }

    public CallbackContext getLoginCallbackContext() {
        return loginCallbackContext;
    }

    public String getClientId() {
        return clientId;
    }

    public static boolean isValid(LoginState state) {
        return state != null &&
               state.loginCallbackContext != null &&
               (state.clientId != null && state.clientId.length() > 0);
    }
}
