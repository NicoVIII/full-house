import { createSignal, onCleanup } from "solid-js";

type BarcodeDetectorResult = Readonly<{ rawValue?: string }>;

type BarcodeDetectorInstance = Readonly<{
	detect: (source: Readonly<HTMLVideoElement>) => Promise<BarcodeDetectorResult[]>;
}>;

type BarcodeDetectorConstructor = new (options?: { formats?: string[] }) => BarcodeDetectorInstance;

type BarcodeDetectorStatic = BarcodeDetectorConstructor &
	Readonly<{
		getSupportedFormats?: () => Promise<string[]>;
	}>;

type CameraSupportStatus = Readonly<{
	isSupported: boolean;
	message: string;
}>;

const REQUESTED_FORMATS = ["ean_13", "ean_8", "upc_a", "upc_e", "code_128", "qr_code"];

function resolveBarcodeDetectorCtor(): BarcodeDetectorStatic | undefined {
	return (
		globalThis as typeof globalThis & {
			BarcodeDetector?: BarcodeDetectorStatic;
		}
	).BarcodeDetector;
}

function getMissingApiError(detectorCtor: BarcodeDetectorStatic | undefined): string | undefined {
	if (!globalThis.isSecureContext) {
		return "Camera scanning requires a secure context (HTTPS or localhost).";
	}

	if (!("mediaDevices" in navigator) || typeof navigator.mediaDevices.getUserMedia !== "function") {
		return "Camera access is not available in this browser context.";
	}

	if (detectorCtor === undefined) {
		return "BarcodeDetector API is not available in this browser.";
	}

	return undefined;
}

function getCameraSupportStatus(): CameraSupportStatus {
	const detectorCtor = resolveBarcodeDetectorCtor();

	if (!globalThis.isSecureContext) {
		return {
			isSupported: false,
			message: "Camera scan needs HTTPS (or localhost).",
		};
	}

	if (!("mediaDevices" in navigator) || typeof navigator.mediaDevices.getUserMedia !== "function") {
		return {
			isSupported: false,
			message: "Camera API is not available in this browser context.",
		};
	}

	if (detectorCtor === undefined) {
		return {
			isSupported: false,
			message: "Barcode scanning API is missing in this browser.",
		};
	}

	return {
		isSupported: true,
		message: "Camera scan is available on this browser.",
	};
}

export function useCameraBarcodeScanner(onDetected: (value: string) => void) {
	const [cameraError, setCameraError] = createSignal<string>();
	const [isCameraActive, setIsCameraActive] = createSignal(false);
	const [cameraSupportStatus] = createSignal<CameraSupportStatus>(getCameraSupportStatus());
	const [videoRef, setVideoRef] = createSignal<HTMLVideoElement>();
	const [mediaStream, setMediaStream] = createSignal<MediaStream>();
	const [detectorInterval, setDetectorInterval] =
		createSignal<ReturnType<typeof globalThis.setInterval>>();

	const stopCamera = () => {
		const interval = detectorInterval();
		const stream = mediaStream();
		const video = videoRef();

		// eslint-disable-next-line functional/no-conditional-statements
		if (interval !== undefined) {
			globalThis.clearInterval(interval);
		}
		setDetectorInterval(undefined);

		// eslint-disable-next-line functional/no-conditional-statements
		if (stream !== undefined) {
			stream.getTracks().forEach((track) => {
				track.stop();
			});
		}
		setMediaStream(undefined);

		// eslint-disable-next-line functional/no-conditional-statements
		if (video !== undefined) {
			video.pause();
			// eslint-disable-next-line functional/immutable-data
			video.srcObject = new MediaStream();
		}

		setIsCameraActive(false);
	};

	onCleanup(() => {
		stopCamera();
	});

	const startCamera = async () => {
		if (isCameraActive()) {
			return;
		}

		const detectorCtor = resolveBarcodeDetectorCtor();
		const missingApiError = getMissingApiError(detectorCtor);
		if (missingApiError !== undefined) {
			setCameraError(missingApiError);
			return;
		}

		if (detectorCtor === undefined) {
			setCameraError("BarcodeDetector API is not available in this browser.");
			return;
		}

		const video = videoRef();
		if (video === undefined) {
			setCameraError("Camera preview is not ready.");
			return;
		}

		try {
			setCameraError(undefined);
			const stream = await navigator.mediaDevices.getUserMedia({
				video: { facingMode: { ideal: "environment" } },
			});
			setMediaStream(stream);
			// eslint-disable-next-line functional/immutable-data
			video.srcObject = stream;
			await video.play();

			const supportedFormats = await detectorCtor.getSupportedFormats?.();
			const usableFormats =
				supportedFormats === undefined
					? REQUESTED_FORMATS
					: REQUESTED_FORMATS.filter((format) => supportedFormats.includes(format));

			if (usableFormats.length === 0) {
				setCameraError("BarcodeDetector API is available, but no supported barcode formats match.");
				stopCamera();
				return;
			}

			const detector = new detectorCtor({ formats: usableFormats });

			setDetectorInterval(
				globalThis.setInterval(() => {
					void detector
						.detect(video)
						.then((results) => {
							const rawValue = results[0]?.rawValue;
							// eslint-disable-next-line functional/no-conditional-statements
							if (rawValue !== undefined) {
								onDetected(rawValue);
							}
						})
						.catch(() => {
							// Detector failures are transient; keep scanning.
						});
				}, 250),
			);

			setIsCameraActive(true);
		} catch (error) {
			setCameraError(error instanceof Error ? error.message : "Failed to access camera.");
			stopCamera();
		}
	};

	return {
		cameraError,
		cameraSupportStatus,
		isCameraActive,
		setVideoRef,
		startCamera,
		stopCamera,
	};
}
