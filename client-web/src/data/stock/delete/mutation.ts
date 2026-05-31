import { mutationOptions } from "@tanstack/solid-query";

import { MutationOptions } from "../../tanstack_helper";
import { tanstackMutationKeys } from "../../tanstack_keys";
import { deleteStockItem, DeleteStockItemRequest } from "./request";

export const removeStockItemMutationOptions = (
	options?: MutationOptions<void, DeleteStockItemRequest>,
) =>
	mutationOptions({
		mutationKey: tanstackMutationKeys.stock.remove(),
		mutationFn: deleteStockItem,
		...options,
	});
