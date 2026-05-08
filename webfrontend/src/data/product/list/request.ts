import { buildHeader, decode } from "../../../skir";
import { ProductListResponse as SkirProductListResponse } from "../../../skirout/product";
import { ListResponse, readApiErrorMessage } from "../api_helper";
import { Product, ProductId } from "../product";

type FetchProductsParams = Readonly<{
	offset: number;
	limit: number;
	parent_product_id?: string | null;
}>;

export async function fetchProducts({
	limit,
	offset,
}: FetchProductsParams): Promise<ListResponse<Product>> {
	const searchParams = new URLSearchParams({
		limit: String(limit),
		offset: String(offset),
	});

	const response = await fetch(`/api/v1/products?${searchParams.toString()}`, {
		headers: buildHeader(),
	});

	if (!response.ok) {
		const defaultMessage = `Products request failed with status ${String(response.status)}`;
		throw new Error(await readApiErrorMessage(response, defaultMessage));
	}

	const parsed = await decode(response, SkirProductListResponse.serializer);
	return {
		data: parsed.data.map((p) =>
			Product({
				id: ProductId(p.id),
				name: p.name,
				parent_product_id: p.parentProductId
					? ProductId(p.parentProductId)
					: undefined,
				child_product_ids: p.childProductIds.map(ProductId),
			}),
		),
		total: parsed.total,
		offset: parsed.offset,
		limit: parsed.limit,
	};
}
