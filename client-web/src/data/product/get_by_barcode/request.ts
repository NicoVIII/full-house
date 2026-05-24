import { GetProductByBarcode, GetProductByBarcodeRequest } from "../../../skirout/products/queries";
import { skirServiceClient } from "../../api_helper";
import { Product, ProductId } from "../product";

export async function fetchProductByBarcode(barcode: string): Promise<Product> {
	const data = await skirServiceClient.invokeRemote(
		GetProductByBarcode,
		GetProductByBarcodeRequest.create({ barcode }),
	);

	return Product({
		id: ProductId(data.id),
		name: data.name,
		parent_product_id: data.parentProductId ? ProductId(data.parentProductId) : undefined,
		child_product_ids: data.childProductIds.map(ProductId),
		barcodes: [...data.barcodes],
	});
}
