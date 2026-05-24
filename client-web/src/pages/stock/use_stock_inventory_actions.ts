import { createInfiniteQuery, useMutation } from "@tanstack/solid-query";
import { createMemo, createSignal } from "solid-js";

import { createStockItemMutationOptions } from "../../data/stock/create/mutation";
import { stockListQueryOptions } from "../../data/stock/list/query";
import { removeStockItemMutationOptions } from "../../data/stock/remove/mutation";
import type { StockSummary } from "../../data/stock/stock";
import { flattenPaginatedItems, readPaginatedTotal } from "../paginated_query_helpers";

export function useStockInventoryActions() {
	const stockQuery = createInfiniteQuery(stockListQueryOptions);
	const stock = createMemo(() => flattenPaginatedItems(stockQuery.data));
	const total = createMemo(() => readPaginatedTotal(stockQuery.data));
	const [removeError, setRemoveError] = createSignal<string>();
	const [removingKey, setRemovingKey] = createSignal<string>();

	const createMutation = useMutation(() =>
		createStockItemMutationOptions({
			onSuccess: async () => {
				await stockQuery.refetch();
			},
		}),
	);

	const removeMutation = useMutation(() =>
		removeStockItemMutationOptions({
			onMutate: (variables) => {
				setRemoveError(undefined);
				setRemovingKey(`${variables.product_id}|${variables.best_before_date}`);
			},
			onSuccess: async (_result, _variables, _on_result, context) => {
				await context.client.invalidateQueries(stockListQueryOptions());
			},
			onError: (error: Readonly<Error>) => {
				setRemoveError(error.message);
			},
			onSettled: () => {
				setRemovingKey(undefined);
			},
		}),
	);

	const addStock = (
		input: Readonly<{ productId: string; bestBeforeDate: string }>,
		onError: (message: string) => void,
		onSuccess: () => void,
	) => {
		createMutation.mutate(
			{
				product_id: input.productId,
				best_before_date: input.bestBeforeDate,
			},
			{
				onSuccess: () => {
					onSuccess();
				},
				onError: (error) => {
					onError(error.message);
				},
			},
		);
	};

	const removeStock = (
		input: Readonly<{ productId: string; bestBeforeDate: string }>,
		onError: (message: string) => void,
	) => {
		removeMutation.mutate(
			{
				product_id: input.productId,
				best_before_date: input.bestBeforeDate,
			},
			{
				onError: (error) => {
					setRemoveError(error.message);
					onError(error.message);
				},
			},
		);
	};

	const visibleBatchesForProduct = (productId: string | undefined): StockSummary[] => {
		if (productId === undefined) {
			return [];
		}

		return stock()
			.filter((item) => item.product_id === productId)
			.toSorted((left, right) => left.best_before_date.localeCompare(right.best_before_date));
	};

	const removeOne = (item: StockSummary) => {
		const confirmed = globalThis.confirm(
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

	return {
		stockQuery,
		stock,
		total,
		removeError,
		removingKey,
		addStock,
		removeStock,
		removeOne,
		visibleBatchesForProduct,
		createIsPending: () => createMutation.isPending,
		removeIsPending: () => removeMutation.isPending,
	};
}
