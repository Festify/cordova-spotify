require('es6-promise/auto');
const Emitter = require('eventemitter3');

class EventEmitter extends Emitter {
    constructor() {
        super();

        this.hasBeenRegistered = false;
    }

    registerEvents() {
        return new Promise((resolve, reject) => {
            if (!this.hasBeenRegistered) {
                cordova.exec(event => {
                    if (!this.hasBeenRegistered) {
                        this.hasBeenRegistered = true;
                        resolve(this);
                    } else {
                        this.emit(event.name, ...(event.args || []));
                    }
                }, err => reject(err), 'SpotifyConnector', 'registerEventsListener', []);
            } else {
                reject(new Error("Already registered."));
            }
        });
    }
}

module.exports = EventEmitter;