import { ListProducts, ListProductsRequest } from "../../../skirout/product";
import { ListResponse, skirServiceClient } from "../../api_helper";
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
	const parsed = await skirServiceClient.invokeRemote(
		ListProducts,
		ListProductsRequest.create({ limit, offset }),
	);

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
