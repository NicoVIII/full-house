import { mutationOptions } from "@tanstack/solid-query";
import { MutationOptions } from "../../tanstack_helper";
import { productQueryOptions } from "../get/query";
import { productListQueryOptions } from "../list/query";
import { ProductId } from "../product";
import { deleteProduct } from "./request";

export const deleteProductMutationOptions = (
	id: ProductId,
	options?: MutationOptions<void, void>,
) =>
	mutationOptions({
		mutationKey: ["deleteProduct", id],
		mutationFn: () => deleteProduct(id),
		...options,
		onSettled: async (data, error, variables, onMutateResult, context) => {
			await context.client.invalidateQueries(productQueryOptions(id));
			await context.client.invalidateQueries(productListQueryOptions());
			options?.onSettled?.(data, error, variables, onMutateResult, context);
		},
	});
