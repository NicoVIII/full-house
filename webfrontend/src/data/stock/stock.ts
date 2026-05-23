import { ListStockItems, ListStockItemsRequest } from "../../skirout/stock";
import { skirServiceClient } from "../api_helper";

export type StockSummary = Readonly<{
	product_id: string;
	product_name: string;
	quantity: number;
}>;

export type StockListResponse = Readonly<{
	data: StockSummary[];
	total: number;
	offset: number;
	limit: number;
}>;

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
			quantity: s.quantity,
		})),
		total: parsed.total,
		offset: parsed.offset,
		limit: parsed.limit,
	};
}
