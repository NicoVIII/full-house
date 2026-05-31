import { QueryClient, queryOptions } from "@tanstack/solid-query";

import { QueryOptions } from "../../tanstack_helper";
import { tanstackQueryKeys } from "../../tanstack_keys";
import { Product, ProductId } from "../product";
import { fetchProduct } from "./request";

export const setProductQueryData = (client: QueryClient, product: Product) => {
	client.setQueryData(tanstackQueryKeys.product.byId(product.id), product);
};

export const invalidateProductByIdQuery = (client: QueryClient, id: ProductId) =>
	client.invalidateQueries({ queryKey: tanstackQueryKeys.product.byId(id) });

export const productQueryOptions = (
	id: ProductId,
	options?: QueryOptions<Product, ReturnType<typeof tanstackQueryKeys.product.byId>>,
) =>
	queryOptions({
		queryKey: tanstackQueryKeys.product.byId(id),
		queryFn: () => fetchProduct(id),
		staleTime: 1000 * 60 * 60,
		...options,
	});
