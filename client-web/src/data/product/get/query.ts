import { QueryClient, queryOptions } from "@tanstack/solid-query";
import { QueryOptions } from "../../tanstack_helper";
import { Product, ProductId } from "../product";
import { fetchProduct } from "./request";

function getProductQueryKey(id: ProductId) {
	return ["product", id] as const;
}

export const setProductQueryData = (client: QueryClient, product: Product) => {
	client.setQueryData(getProductQueryKey(product.id), product);
};

export const productQueryOptions = (
	id: ProductId,
	options?: QueryOptions<Product, readonly ["product", ProductId]>,
) =>
	queryOptions({
		queryKey: getProductQueryKey(id),
		queryFn: () => fetchProduct(id),
		staleTime: 1000 * 60 * 60,
		...options,
	});
