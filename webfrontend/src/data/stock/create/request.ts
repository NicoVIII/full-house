import { readApiErrorMessage } from "../../product/api_helper";

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
	const response = await fetch("/api/v1/stock_items", {
		method: "POST",
		headers: {
			"content-type": "application/json",
		},
		body: JSON.stringify({ product_id }),
	});

	if (!response.ok) {
		const defaultMessage = `Create stock item request failed with status ${String(response.status)}`;
		throw new Error(await readApiErrorMessage(response, defaultMessage));
	}

	return (await response.json()) as StockItemData;
}
