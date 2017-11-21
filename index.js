var Orientation = require('react-native').NativeModules.Orientation;
var DeviceEventEmitter = require('react-native').DeviceEventEmitter;

var listeners = {};
var interfaceOrientationDidChangeEvent = 'interfaceOrientationDidChange';
var deviceOrientationDidChangeEvent = 'deviceOrientationDidChange';

var id = 0;
var META = '__listener_id';

function getKey(listener) {
  if (!listener.hasOwnProperty(META)) {
    if (!Object.isExtensible(listener)) {
      return 'F';
    }

    Object.defineProperty(listener, META, {
      value: 'L' + ++id,
    });
  }

  return listener[META];
};

module.exports = {
  getInterfaceOrientation(cb) {
    Orientation.getInterfaceOrientation((orientation) =>{
      cb(orientation);
    });
  },

  getDeviceOrientation(cb) {
    Orientation.getDeviceOrientation((orientation) =>{
      cb(orientation)
    });
  },

  lockToPortrait() {
    Orientation.lockToPortrait();
  },

  lockToLandscape() {
    Orientation.lockToLandscape();
  },

  lockToLandscapeRight() {
    Orientation.lockToLandscapeRight();
  },

  lockToLandscapeLeft() {
    Orientation.lockToLandscapeLeft();
  },

  unlockAllOrientations() {
    Orientation.unlockAllOrientations();
  },

  addInterfaceOrientationListener(cb) {
    var key = getKey(cb);
    listeners[key] = DeviceEventEmitter.addListener(interfaceOrientationDidChangeEvent,
      (body) => {
        cb(body.orientation);
      });
  },

  addDeviceOrientationListener(cb) {
    var key = getKey(cb);
    listeners[key] = DeviceEventEmitter.addListener(deviceOrientationDidChangeEvent,
      (body) => {
        cb(body.orientation);
      });
  },

  removeListener(cb) {
    var key = getKey(cb);

    if (!listeners[key]) {
      return;
    }

    listeners[key].remove();
    listeners[key] = null;
  },

  getInitialInterfaceOrientation() {
    return Orientation.initialInterfaceOrientation;
  },

  getInitialDeviceOrientation() {
    return Orientation.initialDeviceOrientation;
  },

  isPortrait(orientation) {
    return orientation === "PORTRAIT" || orientation == "PORTRAIT-UPSIDEDOWN"
  },

  isLandscape(orientation) {
    return orientation === "LANDSCAPE-LEFT" || orientation == "LANDSCAPE-RIGHT"
  }
}
