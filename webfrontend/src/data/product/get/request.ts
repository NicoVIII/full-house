import { decode } from "../../../skir";
import { Product as SkirProduct } from "../../../skirout/product";
import { readApiErrorMessage } from "../api_helper";
import { Product, ProductId } from "../product";

// TODO: non-happy path: product doesn't exist
export async function fetchProduct(productId: string): Promise<Product> {
	const response = await fetch(`/api/v1/products/${productId}`);

	if (!response.ok) {
		const defaultMessage = `Product request failed with status ${String(response.status)}`;
		throw new Error(await readApiErrorMessage(response, defaultMessage));
	}

	const data = await decode(response, SkirProduct.serializer);
	return Product({
		id: ProductId(data.id),
		name: data.name,
		parent_product_id: data.parentProductId
			? ProductId(data.parentProductId)
			: undefined,
		child_product_ids: data.childProductIds.map(ProductId),
	});
}
