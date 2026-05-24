import { CreateProduct, CreateProductRequest } from "../../../skirout/products/commands";
import { skirServiceClient } from "../../api_helper";

export type Request = Readonly<{
	id: string;
	name: string;
	parent_product_id?: string | undefined;
	barcodes?: string[];
}>;

export async function createProduct({
	id,
	name,
	parent_product_id,
	barcodes,
}: Request): Promise<void> {
	await skirServiceClient.invokeRemote(
		CreateProduct,
		CreateProductRequest.create({
			id,
			name,
			// oxlint-disable-next-line unicorn/no-null
			parentProductId: parent_product_id ?? null,
			barcodes: barcodes ?? [],
		}),
	);
}
