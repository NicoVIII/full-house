import {
	DeleteStockItem,
	DeleteStockItemRequest as SkirDeleteStockItemRequest,
} from "../../../skirout/stock_items/commands";
import { skirServiceClient } from "../../api_helper";

export type DeleteStockItemRequest = Readonly<{
	product_id: string;
	best_before_date: string;
}>;

export async function deleteStockItem({
	product_id,
	best_before_date,
}: DeleteStockItemRequest): Promise<void> {
	await skirServiceClient.invokeRemote(
		DeleteStockItem,
		SkirDeleteStockItemRequest.create({
			productId: product_id,
			bestBeforeDate: best_before_date,
		}),
	);
}
