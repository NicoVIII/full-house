import { mutationOptions } from "@tanstack/solid-query";

import { MutationOptions } from "../../tanstack_helper";
import { tanstackMutationKeys } from "../../tanstack_keys";
import { invalidateProductByIdQuery } from "../get/query";
import { invalidateProductListQuery } from "../list/query";
import { type UpdateProductBarcodesRequestPayload, updateProductBarcodes } from "./request";

export const updateProductBarcodesMutationOptions = (
	options?: MutationOptions<void, UpdateProductBarcodesRequestPayload>,
) =>
	mutationOptions({
		mutationKey: tanstackMutationKeys.product.updateBarcodes(),
		mutationFn: updateProductBarcodes,
		...options,
		onSuccess: async (result, variables, onMutateResult, context) => {
			await invalidateProductByIdQuery(context.client, variables.id);
			await invalidateProductListQuery(context.client);
			await options?.onSuccess?.(result, variables, onMutateResult, context);
		},
	});
