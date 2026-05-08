import { readApiErrorMessage } from "../api_helper";
import { Product, ProductId } from "../product";

type ProductResponse = Readonly<{
	id: string;
	name: string;
	parent_product_id: string | null;
	child_product_ids: string[];
}>;

// TODO: non-happy path: product doesn't exist
export async function fetchProduct(productId: string): Promise<Product> {
	const response = await fetch(`/api/v1/products/${productId}`);

	if (!response.ok) {
		const defaultMessage = `Product request failed with status ${String(response.status)}`;
		throw new Error(await readApiErrorMessage(response, defaultMessage));
	}

	const data = (await response.json()) as ProductResponse;
	return Product({
		id: ProductId(data.id),
		name: data.name,
		parent_product_id: data.parent_product_id
			? ProductId(data.parent_product_id)
			: undefined,
		child_product_ids: data.child_product_ids.map(ProductId),
	});
}
