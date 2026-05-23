import {
	RemoveStockItem,
	RemoveStockItemRequest as SkirRemoveStockItemRequest,
} from "../../../skirout/stock";
import { skirServiceClient } from "../../api_helper";

export type RemoveStockItemRequest = Readonly<{
	product_id: string;
	best_before_date: string;
}>;

export type RemoveStockItemData = Readonly<{
	product_id: string;
	best_before_date: string;
	quantity: number;
}>;

export async function removeStockItem({
	product_id,
	best_before_date,
}: RemoveStockItemRequest): Promise<RemoveStockItemData> {
	const data = await skirServiceClient.invokeRemote(
		RemoveStockItem,
		SkirRemoveStockItemRequest.create({
			productId: product_id,
			bestBeforeDate: best_before_date,
		}),
	);

	return {
		product_id: data.productId,
		best_before_date: data.bestBeforeDate,
		quantity: data.quantity,
	};
}
