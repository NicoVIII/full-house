import { CreateProduct, CreateProductRequest } from "../../../skirout/product";
import { skirServiceClient } from "../api_helper";
import { Product, ProductId } from "../product";

export type Request = Readonly<{
	name: string;
	parent_product_id?: string | undefined;
}>;

export async function createProduct({
	name,
	parent_product_id,
}: Request): Promise<Product> {
	const product = await skirServiceClient.invokeRemote(
		CreateProduct,
		CreateProductRequest.create({
			name,
			parentProductId: parent_product_id ?? null,
		}),
	);

	return Product({
		id: ProductId(product.id),
		name: product.name,
		parent_product_id: product.parentProductId
			? ProductId(product.parentProductId)
			: undefined,
		child_product_ids: product.childProductIds.map(ProductId),
	});
}
