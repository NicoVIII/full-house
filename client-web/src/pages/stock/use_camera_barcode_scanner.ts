import { createSignal, onCleanup } from "solid-js";

type BarcodeDetectorResult = Readonly<{ rawValue?: string }>;

type BarcodeDetectorInstance = Readonly<{
	detect: (source: Readonly<HTMLVideoElement>) => Promise<BarcodeDetectorResult[]>;
}>;

type BarcodeDetectorConstructor = new (options?: { formats?: string[] }) => BarcodeDetectorInstance;

export function useCameraBarcodeScanner(onDetected: (value: string) => void) {
	const [cameraError, setCameraError] = createSignal<string>();
	const [isCameraActive, setIsCameraActive] = createSignal(false);
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

		const detectorCtor = (
			globalThis as typeof globalThis & {
				BarcodeDetector?: BarcodeDetectorConstructor;
			}
		).BarcodeDetector;

		if (detectorCtor === undefined) {
			setCameraError("Camera scanning is not supported in this browser. Use manual barcode input.");
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

			const detector = new detectorCtor({
				formats: ["ean_13", "ean_8", "upc_a", "upc_e", "code_128", "qr_code"],
			});

			setDetectorInterval(
				globalThis.setInterval(() => {
					const activeVideo = videoRef();
					if (activeVideo === undefined) {
						return;
					}

					void detector
						.detect(activeVideo)
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
		isCameraActive,
		setVideoRef,
		startCamera,
		stopCamera,
	};
}
