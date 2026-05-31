import { infiniteQueryOptions } from "@tanstack/solid-query";

import { tanstackQueryKeys } from "../../tanstack_keys";
import { fetchStock } from "./request";

const PAGE_SIZE = 6;

export const stockListQueryOptions = () =>
	infiniteQueryOptions({
		queryKey: tanstackQueryKeys.stock.listInfinite(),
		queryFn: ({ pageParam }) =>
			fetchStock({
				limit: PAGE_SIZE,
				offset: pageParam,
			}),
		getNextPageParam: (lastPage) => {
			const nextOffset = lastPage.offset + lastPage.data.length;
			return nextOffset < lastPage.total ? nextOffset : undefined;
		},
		initialPageParam: 0,
		staleTime: 1000 * 60 * 60,
	});
