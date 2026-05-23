import {
	CreateStockItem,
	CreateStockItemRequest as SkirCreateStockItemRequest,
} from "../../../skirout/stock";
import { skirServiceClient } from "../../api_helper";

export type CreateStockItemRequest = Readonly<{
	product_id: string;
}>;

export type StockItemData = Readonly<{
	id: string;
	product_id: string;
}>;

export async function createStockItem({
	product_id,
}: CreateStockItemRequest): Promise<StockItemData> {
	const data = await skirServiceClient.invokeRemote(
		CreateStockItem,
		SkirCreateStockItemRequest.create({ productId: product_id }),
	);

	return { id: data.id, product_id: data.productId };
}
