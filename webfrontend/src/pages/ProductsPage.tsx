import Box from "@suid/material/Box";
import {
	createInfiniteQuery,
	type InfiniteData,
	useQueryClient,
} from "@tanstack/solid-query";
import type { Component } from "solid-js";
import { createEffect, createMemo } from "solid-js";
import {
	fetchProducts,
	type Product,
	type ProductListResponse,
} from "../api/products";
import CreateProductDialog from "../components/CreateProductDialog";
import ProductsHero from "../components/ProductsHero";
import ProductsPanel from "../components/ProductsPanel";
import {
	flattenPaginatedItems,
	readPaginatedTotal,
} from "./paginated_query_helpers";

const PAGE_SIZE = 6;

const ProductsPage: Component = () => {
	const queryClient = useQueryClient();

	const productsQuery = createInfiniteQuery<
		ProductListResponse,
		Error,
		InfiniteData<ProductListResponse, number>,
		readonly ["products", "infinite"],
		number
	>(() => ({
		getNextPageParam: (lastPage) => {
			const nextOffset = lastPage.offset + lastPage.data.length;
			return nextOffset < lastPage.total ? nextOffset : undefined;
		},
		initialPageParam: 0,
		queryFn: ({ pageParam }) =>
			fetchProducts({
				limit: PAGE_SIZE,
				offset: pageParam,
			}),
		queryKey: ["products", "infinite"] as const,
		staleTime: 1000 * 60 * 60,
	}));

	const products = createMemo(() =>
		flattenPaginatedItems<Product, ProductListResponse>(productsQuery.data),
	);
	const total = createMemo(() => readPaginatedTotal(productsQuery.data));
	const productsById = createMemo(
		() => new Map(products().map((product) => [product.id, product])),
	);

	createEffect(() => {
		products().forEach((product) => {
			queryClient.setQueryData(["products", "detail", product.id], {
				data: product,
			});
		});
	});

	const handleProductCreated = async () => {
		await queryClient.invalidateQueries({
			queryKey: ["products", "infinite"],
		});
	};

	return (
		<>
			<ProductsHero />
			<Box sx={{ mb: 3, display: "flex", justifyContent: "flex-end" }}>
				<CreateProductDialog onCreated={handleProductCreated} />
			</Box>
			<ProductsPanel
				error={productsQuery.error}
				hasNextPage={productsQuery.hasNextPage}
				isError={productsQuery.isError}
				isFetchingNextPage={productsQuery.isFetchingNextPage}
				isPending={productsQuery.isPending}
				onLoadMore={() => void productsQuery.fetchNextPage()}
				productsById={productsById()}
				products={products()}
				total={total()}
			/>
		</>
	);
};

export default ProductsPage;
