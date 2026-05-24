import { DeleteProduct, DeleteProductRequest } from "../../../skirout/products/commands";
import { skirServiceClient } from "../../api_helper";
import { ProductId } from "../product";

export async function deleteProduct(productId: ProductId): Promise<void> {
	await skirServiceClient.invokeRemote(
		DeleteProduct,
		DeleteProductRequest.create({ id: productId }),
	);
}
