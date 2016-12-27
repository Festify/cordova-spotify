require('es6-promise/auto');
const Emitter = require('eventemitter3');
const exec = cordova.exec;

class EventEmitter extends Emitter {
    constructor() {
        super();

        this.hasBeenRegistered = false;
    }

    register() {
        const p = new Promise();
        if (!this.hasBeenRegistered) {
            exec(event => {
                if (!this.hasBeenRegistered) {
                    this.hasBeenRegistered = true;
                    p.resolve(this);
                } else {
                    this.emit(event.name, ...event.args);
                }
            }, err => p.reject(err), "registerEventsListener", []);
        } else {
            p.reject(new Error("Already registered."));
        }
        return p;
    }
}

module.exports = EventEmitter;