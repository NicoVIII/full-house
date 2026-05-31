import { mutationOptions } from "@tanstack/solid-query";

import { MutationOptions } from "../../tanstack_helper";
import { tanstackMutationKeys } from "../../tanstack_keys";
import { invalidateProductByIdQuery } from "../get/query";
import { invalidateProductListQuery } from "../list/query";
import { ProductId } from "../product";
import { deleteProduct } from "./request";

export const deleteProductMutationOptions = (
	id: ProductId,
	options?: MutationOptions<void, void>,
) =>
	mutationOptions({
		mutationKey: tanstackMutationKeys.product.delete(id),
		mutationFn: () => deleteProduct(id),
		...options,
		onSettled: async (data, error, variables, onMutateResult, context) => {
			await invalidateProductByIdQuery(context.client, id);
			await invalidateProductListQuery(context.client);
			options?.onSettled?.(data, error, variables, onMutateResult, context);
		},
	});
