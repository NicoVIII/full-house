import { buildHeader, encode } from "../../../skir";
import {
	CreateStockItemRequest as SkirCreateStockItemRequest,
	StockItem as SkirStockItem,
} from "../../../skirout/stock";
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
	const body = encode(
		SkirCreateStockItemRequest.serializer,
		SkirCreateStockItemRequest.create({ productId: product_id }),
	);

	const response = await fetch("/api/v1/stock_items", {
		method: "POST",
		headers: buildHeader(),
		body,
	});

	if (!response.ok) {
		const defaultMessage = `Create stock item request failed with status ${String(response.status)}`;
		throw new Error(await readApiErrorMessage(response, defaultMessage));
	}

	const data = SkirStockItem.serializer.fromJsonCode(await response.text());
	return { id: data.id, product_id: data.productId };
}
