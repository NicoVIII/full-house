import { mutationOptions } from "@tanstack/solid-query";

import { MutationOptions } from "../../tanstack_helper";
import { tanstackMutationKeys } from "../../tanstack_keys";
import { invalidateProductListQuery } from "../list/query";
import { createProduct, Request } from "./request";

export const createProductMutationOptions = (options?: MutationOptions<void, Request>) =>
	mutationOptions({
		mutationKey: tanstackMutationKeys.product.create(),
		mutationFn: createProduct,
		...options,
		onSuccess: async (result, _variables, _on_result, context) => {
			await invalidateProductListQuery(context.client);
			await options?.onSuccess?.(result, _variables, _on_result, context);
		},
	});
