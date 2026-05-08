import { Typography } from "@suid/material";
import Box from "@suid/material/Box";
import { createInfiniteQuery, useQueryClient } from "@tanstack/solid-query";
import type { Component } from "solid-js";
import { createMemo } from "solid-js";
import { productListQueryOptions } from "../../data/product/list/query";
import {
	flattenPaginatedItems,
	readPaginatedTotal,
} from "../paginated_query_helpers";
import CreateProductFab from "./CreateProductFab";
import ProductsPanel from "./ProductsPanel";

const CatalogPage: Component = () => {
	const queryClient = useQueryClient();

	const productsQuery = createInfiniteQuery(productListQueryOptions);

	const products = createMemo(() => flattenPaginatedItems(productsQuery.data));
	const total = createMemo(() => readPaginatedTotal(productsQuery.data));
	const productsById = createMemo(
		() => new Map(products().map((product) => [product.id, product])),
	);

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
