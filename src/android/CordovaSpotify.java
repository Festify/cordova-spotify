package rocks.festify;

import android.util.Log;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Date;
import java.util.concurrent.TimeUnit;
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
    private static final int LOGIN_REQUEST_CODE = 8139;
    private static final String TAG = "CordovaSpotify";

    private String currentAccessToken = null;
    private String currentClientId = null;
    private SpotifyPlayer player = null;

    private ConnectionEventsHandler connectionEventsHandler = new ConnectionEventsHandler();
    private PlayerEventsHandler playerEventsHandler = new PlayerEventsHandler();

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext)
            throws JSONException {
        if ("getPosition".equals(action)) {
            this.getPosition(callbackContext);
            return true;
        } else if ("play".equals(action)) {
            String trackUri = args.getString(0);
            String accessToken = args.getString(1);
            String clientId = args.getString(2);
            int fromPosition = args.getInt(3);
            this.play(callbackContext, trackUri, accessToken, clientId, fromPosition);
            return true;
        } else if ("pause".equals(action)) {
            this.pause(callbackContext);
            return true;
        } else if ("registerEventsListener".equals(action)) {
            this.registerEventsListener(callbackContext);
            return true;
        } else if ("resume".equals(action)) {
            this.resume(callbackContext);
            return true;
        } else if ("seekTo".equals(action)) {
            int position = args.getInt(0);
            this.seekTo(callbackContext, position);
            return true;
        } else {
            return false;
        }
    }

    /*
     * API Functions
     */

    private void getPosition(final CallbackContext callbackContext) {
        SpotifyPlayer player = this.player;
        PluginResult res = null;
        if (player != null) {
            PlaybackState state = player.getPlaybackState();

            if (state == null) {
                callbackContext.error("Received null from SpotifyPlayer.getPlaybackState()!");
                return;
            }

            res = new PluginResult(PluginResult.Status.OK, (float)state.positionMs);
        } else {
            res = new PluginResult(PluginResult.Status.OK, 0.0f);
        }

        callbackContext.sendPluginResult(res);
    }

    private void play(
            final CallbackContext callbackContext, 
            final String trackUri, 
            final String accessToken, 
            final String clientId, 
            final int fromPosition) {
        SpotifyPlayer player = this.player;

        if (player == null || 
            !accessToken.equals(currentAccessToken) || 
            !clientId.equals(currentClientId)) {
            Config playerConfig = new Config(
                this.cordova.getActivity().getApplicationContext(),
                accessToken,
                clientId
            );

            Spotify.getPlayer(playerConfig, this.cordova.getActivity(), new SpotifyPlayer.InitializationObserver() {
                @Override
                public void onInitialized(SpotifyPlayer spotifyPlayer) {
                    CordovaSpotify.this.currentAccessToken = accessToken;
                    CordovaSpotify.this.currentClientId = clientId;
                    CordovaSpotify.this.player = spotifyPlayer;

                    spotifyPlayer.addConnectionStateCallback(CordovaSpotify.this.connectionEventsHandler);
                    spotifyPlayer.addNotificationCallback(CordovaSpotify.this.playerEventsHandler);

                    CordovaSpotify.this.connectionEventsHandler.onLoggedIn(new Runnable() {
                        @Override
                        public void run() {
                            CordovaSpotify.this.play(
                                callbackContext, 
                                trackUri, 
                                accessToken, 
                                clientId, 
                                fromPosition
                            );
                        }
                    });
                }

                @Override
                public void onError(Throwable throwable) {
                    callbackContext.error("Could not initialize player: " + throwable.toString());
                }
            });

            return;
        }

        player.playUri(new Player.OperationCallback() {
            @Override
            public void onSuccess() {
                callbackContext.success();
            }

            @Override
            public void onError(Error error) {
                callbackContext.error("Playing of track failed: " + error.toString());
            }
        }, trackUri, 0, fromPosition);
    }

    private void pause(final CallbackContext callbackContext) {
        SpotifyPlayer player = this.player;
        if (player == null) {
            callbackContext.success();
            return;
        }

        PlaybackState state = player.getPlaybackState();
        if (!state.isPlaying) {
            callbackContext.success();
            return;
        }

        player.pause(new Player.OperationCallback() {
            @Override
            public void onSuccess() {
                callbackContext.success();
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

    private void resume(final CallbackContext callbackContext) {
        SpotifyPlayer player = this.player;
        if (player == null) {
            callbackContext.success();
            return;
        }

        // resume
        player.resume(new Player.OperationCallback() {
            @Override
            public void onSuccess() {
                callbackContext.success();
            }

            @Override
            public void onError(Error error) {
                callbackContext.error("Resume failed: " + error.toString());
            }
        });
    }

    private void seekTo(final CallbackContext callbackContext, int pos) {
        SpotifyPlayer player = this.player;
        if (player == null) {
            callbackContext.success();
            return;
        }

        player.seekToPosition(new Player.OperationCallback() {
            @Override
            public void onSuccess() {
                callbackContext.success();
            }

            @Override
            public void onError(Error error) {
                callbackContext.error("Seek failed: " + error.toString());
            }
        }, pos);
    }

    /*
     * CALLBACKS
     */

    @Override
    public void onDestroy() {
        SpotifyPlayer player = this.player;
        this.player = null;
        if (player != null) {
            try {
                Spotify.awaitDestroyPlayer(this.cordova.getActivity(), 5, TimeUnit.SECONDS);
            } catch (InterruptedException e) {
                Log.wtf(TAG, "Interrupted while destroying Spotify player.", e);
            }
        }
    }
}