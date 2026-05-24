import { queryOptions } from "@tanstack/solid-query";

import { QueryOptions } from "../../tanstack_helper";
import { Product } from "../product";
import { fetchProductByBarcode } from "./request";

function getProductByBarcodeQueryKey(barcode: string) {
	return ["productByBarcode", barcode] as const;
}

export const productByBarcodeQueryOptions = (
	barcode: string,
	options?: QueryOptions<Product, readonly ["productByBarcode", string]>,
) =>
	queryOptions({
		queryKey: getProductByBarcodeQueryKey(barcode),
		queryFn: () => fetchProductByBarcode(barcode),
		staleTime: 1000 * 60,
		...options,
	});
