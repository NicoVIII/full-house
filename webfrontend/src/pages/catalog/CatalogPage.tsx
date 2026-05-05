import { Typography } from "@suid/material";
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
} from "../../api/products";
import {
	flattenPaginatedItems,
	readPaginatedTotal,
} from "../paginated_query_helpers";
import CreateProductFab from "./CreateProductFab";
import ProductsPanel from "./ProductsPanel";

const PAGE_SIZE = 6;

const CatalogPage: Component = () => {
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
			<Box sx={{ display: "flex" }}>
				<Typography
					variant="h2"
					component="h1"
					sx={{ flexGrow: 1, fontWeight: 700 }}
				>
					Products
				</Typography>
				<Box sx={{ alignItems: "center", display: "flex" }}>
					<CreateProductFab onCreated={handleProductCreated} />
				</Box>
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

export default CatalogPage;
