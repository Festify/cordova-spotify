import exec from './lib/exec-promise.js';
import Emitter from 'eventemitter3';

let emitter;
let emitterRegistered = false;

export function play(trackUri, {token, clientId}, position) {
    if (!trackUri) {
        throw new ReferenceError("trackUri parameter is null");
    }
    if (!token) {
        throw new ReferenceError("token parameter is null");
    }
    if (!clientId) {
        throw new ReferenceError("clientId parameter is null");
    }
    if (position < 0) {
        throw new RangeError("position parameter is < 0");
    }

    return exec('play', [trackUri, token, clientId, position || 0]);
}

export function getPosition() {
    return exec('getPosition');
}

export function pause() {
    return exec('pause');
}

export function resume() {
    return exec('resume');
}

export function seekTo(positionMs) {
    if (positionMs < 0) {
        throw new RangeError("positionMs parameter is < 0");
    }

    return exec('seekTo', [positionMs]);
}

export function getEventEmitter() {
    if (emitter) {
        return Promise.resolve(emitter);
    }

    emitter = new Emitter();

    return new Promise((res, rej) => {
        // Delay callbacks from native code because the Spotify SDKs
        // cannot cope with synchronous invocation from inside of an event
        // handler function.
        const resolve = v => setTimeout(() => res(v));
        const reject = e => setTimeout(() => rej(e));

        cordova.exec(event => {
            // First callback invocation confirms the emitter's registration
            // with the native code. The subsequent ones are actual events.
            if (!emitterRegistered) {
                emitterRegistered = true;
                resolve(this);
            } else {
                setTimeout(() => emitter.emit(event.name, ...(event.args || [])));
            }
        }, err => reject(err), 'SpotifyConnector', 'registerEventsListener', []);
    });
}