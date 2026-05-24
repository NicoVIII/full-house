import { mutationOptions, useMutation } from "@tanstack/solid-query";
import { createSignal } from "solid-js";

import { fetchProductByBarcode } from "../../data/product/get_by_barcode/request";
import type { Product } from "../../data/product/product";

export function useBarcodeLookup() {
	const [barcodeInput, setBarcodeInput] = createSignal("");
	const [scanError, setScanError] = createSignal<string>();
	const [resolvedProduct, setResolvedProduct] = createSignal<Product>();
	const [lastScannedValue, setLastScannedValue] = createSignal("");
	const [lastScannedAt, setLastScannedAt] = createSignal(0);

	const lookupProductMutation = useMutation(() =>
		mutationOptions({
			mutationKey: ["lookupProductByBarcode"],
			mutationFn: fetchProductByBarcode,
			onSuccess: (product) => {
				setResolvedProduct(product);
				setScanError(undefined);
			},
			onError: (error: Readonly<Error>) => {
				setResolvedProduct(undefined);
				setScanError(error.message);
			},
		}),
	);

	const lookupBarcode = (rawBarcode: string) => {
		const barcode = rawBarcode.trim();

		if (barcode === "") {
			setScanError("Barcode must not be empty.");
			return;
		}

		const now = Date.now();
		if (lastScannedValue() === barcode && now - lastScannedAt() < 500) {
			return;
		}

		setLastScannedValue(barcode);
		setLastScannedAt(now);
		setBarcodeInput(barcode);
		lookupProductMutation.mutate(barcode);
	};

	const handleScanSubmit = () => {
		lookupBarcode(barcodeInput());
	};

	return {
		barcodeInput,
		setBarcodeInput,
		scanError,
		setScanError,
		resolvedProduct,
		lookupBarcode,
		handleScanSubmit,
		lookupIsPending: () => lookupProductMutation.isPending,
	};
}
