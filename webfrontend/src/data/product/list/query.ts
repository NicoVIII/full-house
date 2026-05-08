import { infiniteQueryOptions } from "@tanstack/solid-query";
import { setProductQueryData } from "../get/query";
import { fetchProducts } from "./request";

const PAGE_SIZE = 6;

export const productListQueryOptions = () =>
	infiniteQueryOptions({
		queryKey: ["products", "infinite"] as const,
		queryFn: async ({ pageParam, client }) => {
			const products = await fetchProducts({
				limit: PAGE_SIZE,
				offset: pageParam,
			});
			// Pre-populate the cache for individual product queries
			products.data.forEach((product) => {
				setProductQueryData(client, product);
			});
			return products;
		},
		getNextPageParam: (lastPage) => {
			const nextOffset = lastPage.offset + lastPage.data.length;
			return nextOffset < lastPage.total ? nextOffset : undefined;
		},
		initialPageParam: 0,
		staleTime: 1000 * 60 * 60,
	});
