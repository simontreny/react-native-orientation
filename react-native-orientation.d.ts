// Type definitions for react-native-orientation 5.0
// Project: https://github.com/yamill/react-native-orientation
// Definitions by: Moshe Atlow <https://github.com/MoLow>
// Definitions: https://github.com/DefinitelyTyped/DefinitelyTyped

declare namespace Orientation {
    type Orientation = "LANDSCAPE" | "PORTRAIT" | "UNKNOWN";
    type DeviceOrientation = "PORTRAIT" | "PORTRAIT-UPSIDEDOWN" | "UNKNOWN" | "LANDSCAPE-LEFT" | "LANDSCAPE-RIGHT";
    type OrientationCallback = (orientation: Orientation) => void;
    type DeviceOrientationCallback = (orientation: DeviceOrientation) => void;

    export function addOrientationListener(callback: OrientationCallback): void;
    export function addDeviceOrientationListener(callback: DeviceOrientationCallback): void;
    export function removeListener(callback: OrientationCallback | DeviceOrientationCallback): void;

    export function getInitialOrientation(): Orientation;
    export function lockToPortrait(): void;
    export function lockToLandscape(): void;
    export function lockToLandscapeLeft(): void;
    export function lockToLandscapeRight(): void;
    export function unlockAllOrientations(): void;
    export function getOrientation(callback: OrientationCallback): void;
    export function getDeviceOrientation(callback: DeviceOrientationCallback): void;
}

export = Orientation;
