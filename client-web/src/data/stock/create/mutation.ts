import { mutationOptions } from "@tanstack/solid-query";

import { MutationOptions } from "../../tanstack_helper";
import { createStockItem, CreateStockItemRequest } from "./request";

export const createStockItemMutationOptions = (
	options?: MutationOptions<void, CreateStockItemRequest>,
) =>
	mutationOptions({
		mutationKey: ["createStockItem"],
		mutationFn: createStockItem,
		...options,
	});
