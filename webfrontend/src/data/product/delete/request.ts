import { readApiErrorMessage } from "../api_helper";
import { ProductId } from "../product";

export async function deleteProduct(productId: ProductId): Promise<void> {
	const response = await fetch(`/api/v1/products/${productId}`, {
		method: "DELETE",
	});

	if (!response.ok) {
		const defaultMessage = `Delete product request failed with status ${String(response.status)}`;
		throw new Error(await readApiErrorMessage(response, defaultMessage));
	}
}
