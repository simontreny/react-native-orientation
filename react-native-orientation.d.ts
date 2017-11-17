// Type definitions for react-native-orientation 5.0
// Project: https://github.com/yamill/react-native-orientation
// Definitions by: Moshe Atlow <https://github.com/MoLow>
// Definitions: https://github.com/DefinitelyTyped/DefinitelyTyped

declare namespace Orientation {
    type Orientation = "PORTRAIT" | "PORTRAIT-UPSIDEDOWN" | "LANDSCAPE-LEFT" | "LANDSCAPE-RIGHT" | "UNKNOWN";
    type OrientationCallback = (orientation: Orientation) => void;

    export function addOrientationListener(callback: OrientationCallback): void;
    export function addDeviceOrientationListener(callback: OrientationCallback): void;
    export function removeListener(callback: OrientationCallback): void;

    export function getInitialOrientation(): Orientation;
    export function lockToPortrait(): void;
    export function lockToLandscape(): void;
    export function lockToLandscapeLeft(): void;
    export function lockToLandscapeRight(): void;
    export function unlockAllOrientations(): void;
    export function getOrientation(callback: OrientationCallback): void;
    export function getDeviceOrientation(callback: OrientationCallback): void;

    export function isPortrait(orientation: Orientation): boolean;
    export function isLandscape(orientation: Orientation): boolean;
}

export = Orientation;
