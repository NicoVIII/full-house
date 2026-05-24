import { mutationOptions } from "@tanstack/solid-query";

import { MutationOptions } from "../../tanstack_helper";
import { deleteStockItem, DeleteStockItemRequest } from "./request";

export const removeStockItemMutationOptions = (
	options?: MutationOptions<void, DeleteStockItemRequest>,
) =>
	mutationOptions({
		mutationKey: ["removeStockItem"],
		mutationFn: deleteStockItem,
		...options,
	});
