import { ListStockItems, ListStockItemsRequest } from "../../../skirout/stock";
import { skirServiceClient } from "../../api_helper";
import { StockListResponse } from "../stock";

type FetchStockParams = Readonly<{
	offset: number;
	limit: number;
}>;

export async function fetchStock({
	offset,
	limit,
}: FetchStockParams): Promise<StockListResponse> {
	const parsed = await skirServiceClient.invokeRemote(
		ListStockItems,
		ListStockItemsRequest.create({ limit, offset }),
	);

	return {
		data: parsed.data.map((s) => ({
			product_id: s.productId,
			product_name: s.productName,
			best_before_date: s.bestBeforeDate,
			quantity: s.quantity,
		})),
		total: parsed.total,
		offset: parsed.offset,
		limit: parsed.limit,
	};
}
