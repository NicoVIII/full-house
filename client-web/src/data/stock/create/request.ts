import {
	CreateStockItem,
	CreateStockItemRequest as SkirCreateStockItemRequest,
} from "../../../skirout/stock";
import { skirServiceClient } from "../../api_helper";

export type CreateStockItemRequest = Readonly<{
	product_id: string;
	best_before_date: string;
}>;

export type StockItemData = Readonly<{
	id: string;
	product_id: string;
	best_before_date: string;
}>;

export async function createStockItem({
	product_id,
	best_before_date,
}: CreateStockItemRequest): Promise<StockItemData> {
	const data = await skirServiceClient.invokeRemote(
		CreateStockItem,
		SkirCreateStockItemRequest.create({
			productId: product_id,
			bestBeforeDate: best_before_date,
		}),
	);

	return {
		id: data.id,
		product_id: data.productId,
		best_before_date: data.bestBeforeDate,
	};
}
