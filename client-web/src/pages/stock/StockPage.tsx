import Box from "@suid/material/Box";
import Typography from "@suid/material/Typography";
import { createInfiniteQuery, useMutation } from "@tanstack/solid-query";
import type { Component } from "solid-js";
import { createMemo, createSignal } from "solid-js";
import { stockListQueryOptions } from "../../data/stock/list/query";
import { removeStockItemMutationOptions } from "../../data/stock/remove/mutation";
import { type StockSummary } from "../../data/stock/stock";
import {
	flattenPaginatedItems,
	readPaginatedTotal,
} from "../paginated_query_helpers";
import StockPanel from "./StockPanel";

const StockPage: Component = () => {
	const [removeError, setRemoveError] = createSignal<string | null>(null);
	const [removingKey, setRemovingKey] = createSignal<string | null>(null);

	const stockQuery = createInfiniteQuery(stockListQueryOptions);

	const removeMutation = useMutation(() =>
		removeStockItemMutationOptions({
			onMutate: (variables) => {
				setRemoveError(null);
				setRemovingKey(`${variables.product_id}|${variables.best_before_date}`);
			},
			onSuccess: async (_result, _variables, _on_result, context) => {
				await context.client.invalidateQueries(stockListQueryOptions());
			},
			onError: (error: Readonly<Error>) => {
				setRemoveError(error.message);
			},
			onSettled: () => {
				setRemovingKey(null);
			},
		}),
	);

	const handleRemoveOne = (item: StockSummary) => {
		const confirmed = window.confirm(
			`Remove one item from stock for ${item.product_name} with best-before date ${item.best_before_date}?`,
		);

		if (!confirmed) {
			return;
		}

		removeMutation.mutate({
			product_id: item.product_id,
			best_before_date: item.best_before_date,
		});
	};

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
				isRemovingKey={removingKey()}
				onLoadMore={() => void stockQuery.fetchNextPage()}
				onRemoveOne={handleRemoveOne}
				removeError={removeError()}
				stock={stock()}
				total={total()}
			/>
		</>
	);
};

export default StockPage;
