import {
	CreateStockItem,
	CreateStockItemRequest as SkirCreateStockItemRequest,
} from "../../../skirout/stock_items/commands";
import { skirServiceClient } from "../../api_helper";

export type CreateStockItemRequest = Readonly<{
	product_id: string;
	best_before_date: string;
}>;

export async function createStockItem({
	product_id,
	best_before_date,
}: CreateStockItemRequest): Promise<void> {
	await skirServiceClient.invokeRemote(
		CreateStockItem,
		SkirCreateStockItemRequest.create({
			productId: product_id,
			bestBeforeDate: best_before_date,
		}),
	);
}
