import { mutationOptions } from "@tanstack/solid-query";
import { MutationOptions } from "../../tanstack_helper";
import {
	CreateStockItemRequest,
	createStockItem,
	StockItemData,
} from "./request";

export const createStockItemMutationOptions = (
	options?: MutationOptions<StockItemData, CreateStockItemRequest>,
) =>
	mutationOptions({
		mutationKey: ["createStockItem"],
		mutationFn: createStockItem,
		...options,
	});
