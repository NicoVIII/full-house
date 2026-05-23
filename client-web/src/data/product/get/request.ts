import { GetProduct, GetProductRequest } from "../../../skirout/product";
import { skirServiceClient } from "../../api_helper";
import { Product, ProductId } from "../product";

// TODO: non-happy path: product doesn't exist
export async function fetchProduct(productId: string): Promise<Product> {
	const data = await skirServiceClient.invokeRemote(
		GetProduct,
		GetProductRequest.create({ id: productId }),
	);

	return Product({
		id: ProductId(data.id),
		name: data.name,
		parent_product_id: data.parentProductId
			? ProductId(data.parentProductId)
			: undefined,
		child_product_ids: data.childProductIds.map(ProductId),
	});
}
