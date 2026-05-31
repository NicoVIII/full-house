import { mutationOptions } from "@tanstack/solid-query";

import { MutationOptions } from "../../tanstack_helper";
import { tanstackMutationKeys } from "../../tanstack_keys";
import { productQueryOptions } from "../get/query";
import { productListQueryOptions } from "../list/query";
import { type UpdateProductBarcodesRequestPayload, updateProductBarcodes } from "./request";

export const updateProductBarcodesMutationOptions = (
	options?: MutationOptions<void, UpdateProductBarcodesRequestPayload>,
) =>
	mutationOptions({
		mutationKey: tanstackMutationKeys.product.updateBarcodes(),
		mutationFn: updateProductBarcodes,
		...options,
		onSuccess: async (result, variables, onMutateResult, context) => {
			await context.client.invalidateQueries(productQueryOptions(variables.id));
			await context.client.invalidateQueries(productListQueryOptions());
			await options?.onSuccess?.(result, variables, onMutateResult, context);
		},
	});
