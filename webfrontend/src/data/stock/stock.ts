import { decode } from "../../skir";
import { StockListResponse as SkirStockListResponse } from "../../skirout/stock";

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
	const searchParams = new URLSearchParams({
		offset: String(offset),
		limit: String(limit),
	});
	const response = await fetch(
		`/api/v1/stock_items?${searchParams.toString()}`,
	);

	if (!response.ok) {
		throw new Error(
			`Stock request failed with status ${String(response.status)}`,
		);
	}

	const parsed = await decode(response, SkirStockListResponse.serializer);
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
