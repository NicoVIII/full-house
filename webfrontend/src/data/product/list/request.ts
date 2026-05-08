import { ListResponse, readApiErrorMessage } from "../api_helper";
import { Product, ProductId } from "../product";

type ProductData = Readonly<{
	id: string;
	name: string;
	parent_product_id: string | null;
	child_product_ids: string[];
}>;

type ProductListResponse = Readonly<{
	data: ProductData[];
	total: number;
	offset: number;
	limit: number;
}>;

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

	const response = await fetch(`/api/v1/products?${searchParams.toString()}`);

	if (!response.ok) {
		const defaultMessage = `Products request failed with status ${String(response.status)}`;
		throw new Error(await readApiErrorMessage(response, defaultMessage));
	}

	const parsedResponse = (await response.json()) as ProductListResponse;
	const data = parsedResponse.data;
	return {
		...parsedResponse,
		data: data.map((product) =>
			Product({
				id: ProductId(product.id),
				name: product.name,
				parent_product_id: product.parent_product_id
					? ProductId(product.parent_product_id)
					: undefined,
				child_product_ids: product.child_product_ids.map(ProductId),
			}),
		),
	};
}
