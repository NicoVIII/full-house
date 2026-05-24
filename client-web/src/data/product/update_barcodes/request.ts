import { UpdateProduct, UpdateProductRequest } from "../../../skirout/products/commands";
import { skirServiceClient } from "../../api_helper";
import { ProductId } from "../product";

export type UpdateProductBarcodesRequestPayload = Readonly<{
	id: ProductId;
	add_barcodes: string[];
	remove_barcodes: string[];
}>;

export async function updateProductBarcodes({
	id,
	add_barcodes,
	remove_barcodes,
}: UpdateProductBarcodesRequestPayload): Promise<void> {
	await skirServiceClient.invokeRemote(
		UpdateProduct,
		UpdateProductRequest.create({
			id,
			addBarcodes: add_barcodes,
			removeBarcodes: remove_barcodes,
		}),
	);
}
