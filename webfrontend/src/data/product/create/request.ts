import { buildHeader, decode, encode } from "../../../skir";
import {
	CreateProductRequest,
	Product as SkirProduct,
} from "../../../skirout/product";
import { readApiErrorMessage } from "../api_helper";
import { Product, ProductId } from "../product";

export type Request = Readonly<{
	name: string;
	parent_product_id?: string | undefined;
}>;

export async function createProduct({
	name,
	parent_product_id,
}: Request): Promise<Product> {
	const body = encode(
		CreateProductRequest.serializer,
		CreateProductRequest.create({
			name,
			parentProductId: parent_product_id ?? null,
		}),
	);

	const response = await fetch("/api/v1/products", {
		method: "POST",
		headers: buildHeader(),
		body,
	});

	if (!response.ok) {
		const defaultMessage = `Create product request failed with status ${String(response.status)}`;
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
