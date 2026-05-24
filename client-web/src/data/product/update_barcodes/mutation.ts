import { mutationOptions } from "@tanstack/solid-query";

import { MutationOptions } from "../../tanstack_helper";
import { productQueryOptions, setProductQueryData } from "../get/query";
import { productListQueryOptions } from "../list/query";
import { Product } from "../product";
import { type UpdateProductBarcodesRequestPayload, updateProductBarcodes } from "./request";

export const updateProductBarcodesMutationOptions = (
	options?: MutationOptions<Product, UpdateProductBarcodesRequestPayload>,
) =>
	mutationOptions({
		mutationKey: ["updateProductBarcodes"],
		mutationFn: updateProductBarcodes,
		...options,
		onSuccess: async (result, variables, onMutateResult, context) => {
			setProductQueryData(context.client, result);
			await context.client.invalidateQueries(productQueryOptions(result.id));
			await context.client.invalidateQueries(productListQueryOptions());
			await options?.onSuccess?.(result, variables, onMutateResult, context);
		},
	});
