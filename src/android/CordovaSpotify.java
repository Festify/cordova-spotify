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
import java.util.Objects;
import java.util.concurrent.TimeUnit;
import java.text.SimpleDateFormat;

import android.app.Activity;
import android.content.Intent;

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
    private static final String TAG = "CDVSpotify";

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
                JSONObject descr = this.makeError(
                    "unknown", 
                    "Received null from SpotifyPlayer.getPlaybackState()!"
                );
                callbackContext.error(descr);
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

        if (player == null) {
            Log.d(TAG, "Player is null, initing.");
            this.initAndPlay(
                callbackContext, 
                trackUri, 
                accessToken, 
                clientId, 
                fromPosition
            );
            return;
        } else if (!Objects.equals(accessToken, currentAccessToken)) {
            Log.d(TAG, "Access token changed, reiniting.");
            this.logout(new Runnable() {
                @Override
                public void run() {
                    CordovaSpotify.this.loginAndPlay(
                        callbackContext,
                        trackUri,
                        accessToken,
                        fromPosition
                    );
                }
            });
            return;
        } else if (!Objects.equals(clientId, currentClientId)) {
            JSONObject descr = this.makeError(
                "not_implemented", 
                "Changing the client ID is not yet supported"
            );
            callbackContext.error(descr);
            return;
        }

        this.doPlay(callbackContext, trackUri, fromPosition);
    }

    private void initAndPlay(
            final CallbackContext callbackContext,
            final String trackUri, 
            final String accessToken, 
            final String clientId, 
            final int fromPosition) {
        Config playerConfig = new Config(
            this.cordova.getActivity().getApplicationContext(),
            null,
            clientId
        );

        Log.d(TAG, "Initializing player");
        Spotify.getPlayer(playerConfig, this.cordova.getActivity(), new SpotifyPlayer.InitializationObserver() {
            @Override
            public void onInitialized(SpotifyPlayer spotifyPlayer) {
                Log.d(TAG, "Player Initialized, logging in");

                CordovaSpotify.this.currentClientId = clientId;
                CordovaSpotify.this.player = spotifyPlayer;
                
                CordovaSpotify.this.loginAndPlay(callbackContext, trackUri, accessToken, fromPosition);
            }

            @Override
            public void onError(Throwable throwable) {
                Log.d(TAG, "Init failure");

                JSONObject descr = CordovaSpotify.this.makeError(
                    "player_init_failed", 
                    throwable.getMessage()
                );
                callbackContext.error(descr);
            }
        });
    }

    private void loginAndPlay(
            final CallbackContext callbackContext,
            final String trackUri, 
            final String accessToken, 
            final int fromPosition) {
        final SpotifyPlayer player = this.player;
        if (player == null) {
            Log.wtf(TAG, "SpotifyPlayer instance was null in loginAndPlay.");

            JSONObject descr = this.makeError(
                "unknown",
                "Received null as SpotifyPlayer in login method."
            );
            callbackContext.error(descr);
            return;
        }

        player.addConnectionStateCallback(this.connectionEventsHandler);
        player.addNotificationCallback(this.playerEventsHandler);

        this.connectionEventsHandler.onLoggedIn(new Player.OperationCallback() {
            @Override
            public void onSuccess() {
                Log.d(TAG, "Login success.");

                CordovaSpotify.this.currentAccessToken = accessToken;

                CordovaSpotify.this.doPlay(
                    callbackContext, 
                    trackUri, 
                    fromPosition
                );
            }

            @Override
            public void onError(Error error) {
                Log.d(TAG, "Login failure");

                JSONObject descr = CordovaSpotify.this.makeError(
                    "login_failed", 
                    error.toString()
                );
                callbackContext.error(descr);
            }
        });

        player.login(accessToken);
    }

    private void doPlay(
            final CallbackContext callbackContext, 
            final String trackUri, 
            final int fromPosition) {
        final SpotifyPlayer player = this.player;
        if (player == null) {
            Log.wtf(TAG, "SpotifyPlayer instance was null in doPlay.");

            JSONObject descr = this.makeError(
                "unknown",
                "Received null as SpotifyPlayer in play method."
            );
            callbackContext.error(descr);
            return;
        }

        player.playUri(new Player.OperationCallback() {
            @Override
            public void onSuccess() {
                callbackContext.success();
            }

            @Override
            public void onError(Error error) {
                JSONObject descr = CordovaSpotify.this.makeError(
                    "playback_failed", 
                    error.toString()
                );
                callbackContext.error(descr);
            }
        }, trackUri, 0, fromPosition);
    }

    private void logout(final Runnable callback) {
        final SpotifyPlayer player = this.player;
        if (player == null) {
            callback.run();
            return;
        }

        Log.d(TAG, "Logging out");
        this.connectionEventsHandler.onLoggedOut(new Runnable() {
            @Override
            public void run() {
                Log.d(TAG, "Logout successful");

                player.removeConnectionStateCallback(CordovaSpotify.this.connectionEventsHandler);
                player.removeNotificationCallback(CordovaSpotify.this.playerEventsHandler);

                callback.run();
            }
        });

        player.logout();
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
                JSONObject descr = CordovaSpotify.this.makeError(
                    "pause_failed", 
                    error.toString()
                );
                callbackContext.error(descr);
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
                JSONObject descr = CordovaSpotify.this.makeError(
                    "resume_failed", 
                    error.toString()
                );
                callbackContext.error(descr);
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
                JSONObject descr = CordovaSpotify.this.makeError(
                    "seek_failed", 
                    error.toString()
                );
                callbackContext.error(descr);
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

    /*
     * PRIVATES
     */

    private JSONObject makeError(String type, String msg) {
        try {
            final JSONObject obj = new JSONObject();
            obj.put("type", type);
            obj.put("msg", msg);
            return obj;
        } catch (JSONException e) {
            Log.wtf(TAG, "Got a JSONException during error creation.", e);
            return null;
        }
    }
}