import { createEffect, createMemo, createSignal } from "solid-js";

import { useBarcodeLookup } from "./use_barcode_lookup";
import { useCameraBarcodeScanner } from "./use_camera_barcode_scanner";
import { useStockInventoryActions } from "./use_stock_inventory_actions";

export type ScanMode = "add" | "remove";

export function useBarcodeStockWorkflow() {
	const [mode, setMode] = createSignal<ScanMode>("add");
	const [bestBeforeDate, setBestBeforeDate] = createSignal("");
	const [selectedBatchDate, setSelectedBatchDate] = createSignal("");
	const lookup = useBarcodeLookup();
	const camera = useCameraBarcodeScanner(lookup.lookupBarcode);
	const stockActions = useStockInventoryActions();

	const visibleBatchesForResolvedProduct = createMemo(() =>
		stockActions.visibleBatchesForProduct(lookup.resolvedProduct()?.id),
	);

	createEffect(() => {
		const firstBatch = visibleBatchesForResolvedProduct()[0];
		setSelectedBatchDate(firstBatch?.best_before_date ?? "");
	});

	const handleAddStockForResolvedProduct = () => {
		const product = lookup.resolvedProduct();
		if (product === undefined) {
			return;
		}

		stockActions.addStock(
			{
				productId: product.id,
				bestBeforeDate: bestBeforeDate(),
			},
			(message) => {
				lookup.setScanError(message);
			},
			() => {
				setBestBeforeDate("");
				lookup.setScanError(undefined);
			},
		);
	};

	const handleRemoveStockForResolvedProduct = () => {
		const product = lookup.resolvedProduct();
		if (product === undefined) {
			return;
		}

		if (selectedBatchDate() === "") {
			lookup.setScanError("Choose a best-before-date batch to remove from.");
			return;
		}

		lookup.setScanError(undefined);
		stockActions.removeStock(
			{
				productId: product.id,
				bestBeforeDate: selectedBatchDate(),
			},
			(message) => {
				lookup.setScanError(message);
			},
		);
	};

	return {
		mode,
		setMode,
		barcodeInput: lookup.barcodeInput,
		setBarcodeInput: lookup.setBarcodeInput,
		scanError: lookup.scanError,
		cameraError: camera.cameraError,
		resolvedProduct: lookup.resolvedProduct,
		bestBeforeDate,
		setBestBeforeDate,
		selectedBatchDate,
		setSelectedBatchDate,
		isCameraActive: camera.isCameraActive,
		setVideoRef: camera.setVideoRef,
		startCamera: camera.startCamera,
		stopCamera: camera.stopCamera,
		visibleBatchesForResolvedProduct,
		handleScanSubmit: lookup.handleScanSubmit,
		handleAddStockForResolvedProduct,
		handleRemoveStockForResolvedProduct,
		lookupIsPending: lookup.lookupIsPending,
		createIsPending: stockActions.createIsPending,
		removeIsPending: stockActions.removeIsPending,
		stockQuery: stockActions.stockQuery,
		stock: stockActions.stock,
		total: stockActions.total,
		removeError: stockActions.removeError,
		removingKey: stockActions.removingKey,
		handleRemoveOne: stockActions.removeOne,
	};
}
