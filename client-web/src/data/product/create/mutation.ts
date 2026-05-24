import { mutationOptions } from "@tanstack/solid-query";

import { MutationOptions } from "../../tanstack_helper";
import { productListQueryOptions } from "../list/query";
import { Product } from "../product";
import { createProduct, Request } from "./request";

export const createProductMutationOptions = (options?: MutationOptions<Product, Request>) =>
	mutationOptions({
		mutationKey: ["createProduct"],
		mutationFn: createProduct,
		...options,
		onSuccess: async (result, _variables, _on_result, context) => {
			await context.client.invalidateQueries(productListQueryOptions());
			await options?.onSuccess?.(result, _variables, _on_result, context);
		},
	});
