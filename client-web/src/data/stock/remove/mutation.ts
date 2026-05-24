import { mutationOptions } from "@tanstack/solid-query";

import { MutationOptions } from "../../tanstack_helper";
import { RemoveStockItemData, RemoveStockItemRequest, removeStockItem } from "./request";

export const removeStockItemMutationOptions = (
	options?: MutationOptions<RemoveStockItemData, RemoveStockItemRequest>,
) =>
	mutationOptions({
		mutationKey: ["removeStockItem"],
		mutationFn: removeStockItem,
		...options,
	});
