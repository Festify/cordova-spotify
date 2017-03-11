const Emitter = require('eventemitter3');
const Promise = require('es6-promise');

class EventEmitter extends Emitter {
    constructor() {
        super();

        this.hasBeenRegistered = false;
    }

    registerEvents() {
        return new Promise((res, rej) => {
            // Delay callbacks from native code because the Spotify SDKs
            // cannot cope with synchronous invocation from inside of an event
            // handler function.
            const resolve = v => setTimeout(() => res(v));
            const reject = e => setTimeout(() => rej(e));

            if (!this.hasBeenRegistered) {
                cordova.exec(event => {
                    if (!this.hasBeenRegistered) {
                        this.hasBeenRegistered = true;
                        resolve(this);
                    } else {
                        setTimeout(() => this.emit(event.name, ...(event.args || [])));
                    }
                }, err => reject(err), 'SpotifyConnector', 'registerEventsListener', []);
            } else {
                reject(new Error("Already registered."));
            }
        });
    }
}

module.exports = EventEmitter;
