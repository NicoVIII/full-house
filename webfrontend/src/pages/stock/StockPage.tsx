import Box from "@suid/material/Box";
import Typography from "@suid/material/Typography";
import { createInfiniteQuery, type InfiniteData } from "@tanstack/solid-query";
import type { Component } from "solid-js";
import { createMemo } from "solid-js";
import { fetchStock, type StockListResponse } from "../../data/stock/stock";
import {
	flattenPaginatedItems,
	readPaginatedTotal,
} from "../paginated_query_helpers";
import StockPanel from "./StockPanel";

const PAGE_SIZE = 6;

const StockPage: Component = () => {
	const stockQuery = createInfiniteQuery<
		StockListResponse,
		Error,
		InfiniteData<StockListResponse, number>,
		readonly ["stock", "infinite"],
		number
	>(() => ({
		getNextPageParam: (lastPage) => {
			const nextOffset = lastPage.offset + lastPage.data.length;
			return nextOffset < lastPage.total ? nextOffset : undefined;
		},
		initialPageParam: 0,
		queryFn: ({ pageParam }) =>
			fetchStock({
				limit: PAGE_SIZE,
				offset: pageParam,
			}),
		queryKey: ["stock", "infinite"] as const,
		staleTime: 1000 * 60 * 60,
	}));

	const stock = createMemo(() => flattenPaginatedItems(stockQuery.data));
	const total = createMemo(() => readPaginatedTotal(stockQuery.data));

	return (
		<>
			<Box sx={{ display: "flex" }}>
				<Typography
					variant="h2"
					component="h1"
					sx={{ flexGrow: 1, fontWeight: 700 }}
				>
					Stock
				</Typography>
			</Box>
			<StockPanel
				error={stockQuery.error}
				hasNextPage={stockQuery.hasNextPage}
				isError={stockQuery.isError}
				isFetchingNextPage={stockQuery.isFetchingNextPage}
				isPending={stockQuery.isPending}
				onLoadMore={() => void stockQuery.fetchNextPage()}
				stock={stock()}
				total={total()}
			/>
		</>
	);
};

export default StockPage;
