require('es6-promise/auto');
const Emitter = require('eventemitter3');
const exec = cordova.exec;

class EventEmitter extends Emitter {
    constructor() {
        super();

        this.hasBeenRegistered = false;
    }

    register() {
        return new Promise((resolve, reject) => {
            if (!this.hasBeenRegistered) {
                exec(event => {
                    if (!this.hasBeenRegistered) {
                        this.hasBeenRegistered = true;
                        resolve(this);
                    } else {
                        this.emit(event.name, ...event.args);
                    }
                }, err => reject(err), "registerEventsListener", []);
            } else {
                reject(new Error("Already registered."));
            }
        });
    }
}

module.exports = EventEmitter;