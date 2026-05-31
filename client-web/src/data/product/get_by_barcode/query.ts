import { queryOptions } from "@tanstack/solid-query";

import { QueryOptions } from "../../tanstack_helper";
import { tanstackQueryKeys } from "../../tanstack_keys";
import { Product } from "../product";
import { fetchProductByBarcode } from "./request";

export const productByBarcodeQueryOptions = (
	barcode: string,
	options?: QueryOptions<Product, ReturnType<typeof tanstackQueryKeys.product.byBarcode>>,
) =>
	queryOptions({
		queryKey: tanstackQueryKeys.product.byBarcode(barcode),
		queryFn: () => fetchProductByBarcode(barcode),
		staleTime: 1000 * 60,
		...options,
	});
