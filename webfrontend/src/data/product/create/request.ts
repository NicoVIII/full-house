import { readApiErrorMessage } from "../api_helper";
import { Product, ProductId } from "../product";

export type ProductData = Readonly<{
	id: string;
	name: string;
	parent_product_id: string | null;
	child_product_ids: string[];
}>;

export type CreateProductRequest = Readonly<{
	name: string;
	parent_product_id?: string | undefined;
}>;

export async function createProduct({
	name,
	parent_product_id,
}: CreateProductRequest): Promise<Product> {
	const response = await fetch("/api/v1/products", {
		method: "POST",
		headers: {
			"content-type": "application/json",
		},
		body: JSON.stringify({
			name,
			parent_product_id: parent_product_id ?? null,
		}),
	});

	if (!response.ok) {
		const defaultMessage = `Create product request failed with status ${String(response.status)}`;
		throw new Error(await readApiErrorMessage(response, defaultMessage));
	}

	const data = (await response.json()) as ProductData;
	return Product({
		id: ProductId(data.id),
		name: data.name,
		parent_product_id: data.parent_product_id
			? ProductId(data.parent_product_id)
			: undefined,
		child_product_ids: data.child_product_ids.map(ProductId),
	});
}
