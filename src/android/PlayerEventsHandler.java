package rocks.festify;

import android.util.Log;

import com.spotify.sdk.android.player.Error;
import com.spotify.sdk.android.player.PlayerEvent;
import com.spotify.sdk.android.player.SpotifyPlayer;

import rocks.festify.Emitter;

class PlayerEventsHandler extends Emitter
        implements SpotifyPlayer.NotificationCallback {
    private static final String TAG = "PlayerEventsHandler";

    @Override
    public void onPlaybackEvent(PlayerEvent playerEvent) {
        // Strip off enum prefix for platform consistency
        String eventName;
        switch (playerEvent) {
            case UNKNOWN:
                eventName = "Unknown";
                break;
            case kSpPlaybackEventAudioFlush:
                eventName = "AudioFlush";
                break;
            default:
                // Strip off kSpPlaybackNotify
                eventName = playerEvent.toString().substring(17);
                break;
        }

        this.emit("playbackevent", eventName);
    }

    @Override
    public void onPlaybackError(Error error) {
        String errorName;
        switch (error) {
            case kSpErrorOk:
                return;
            case UNKNOWN:
                errorName = "Unknown";
                break;
            case kSpAlreadyPrefetching:
            case kSpPrefetchDownloadFailed:
            case kSpStorageReadError:
            case kSpStorageWriteError:
                // Strip off kSp
                errorName = error.toString().substring(3);
                break;
            default:
                // Strip off kSpError
                errorName = error.toString().substring(8);
                break;
        }

        this.emit("playbackerror", errorName);
    }
}