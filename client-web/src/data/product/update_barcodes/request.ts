import { UpdateProductBarcodes, UpdateProductBarcodesRequest } from "../../../skirout/product";
import { skirServiceClient } from "../../api_helper";
import { Product, ProductId } from "../product";

export type UpdateProductBarcodesRequestPayload = Readonly<{
	id: string;
	add_barcodes: string[];
	remove_barcodes: string[];
}>;

export async function updateProductBarcodes({
	id,
	add_barcodes,
	remove_barcodes,
}: UpdateProductBarcodesRequestPayload): Promise<Product> {
	const data = await skirServiceClient.invokeRemote(
		UpdateProductBarcodes,
		UpdateProductBarcodesRequest.create({
			id,
			addBarcodes: add_barcodes,
			removeBarcodes: remove_barcodes,
		}),
	);

	return Product({
		id: ProductId(data.id),
		name: data.name,
		parent_product_id: data.parentProductId ? ProductId(data.parentProductId) : undefined,
		child_product_ids: data.childProductIds.map(ProductId),
		barcodes: [...data.barcodes],
	});
}
