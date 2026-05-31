import { mutationOptions } from "@tanstack/solid-query";

import { MutationOptions } from "../../tanstack_helper";
import { tanstackMutationKeys } from "../../tanstack_keys";
import { createStockItem, CreateStockItemRequest } from "./request";

export const createStockItemMutationOptions = (
	options?: MutationOptions<void, CreateStockItemRequest>,
) =>
	mutationOptions({
		mutationKey: tanstackMutationKeys.stock.create(),
		mutationFn: createStockItem,
		...options,
	});
