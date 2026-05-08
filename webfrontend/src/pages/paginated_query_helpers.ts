type PaginatedQueryPage<TItem> = Readonly<{
	data: TItem[];
	total: number;
}>;

type PaginatedQueryData<TItem> = Readonly<{
	pages: PaginatedQueryPage<TItem>[];
}>;

export function flattenPaginatedItems<TItem>(
	queryData: PaginatedQueryData<TItem> | undefined,
): TItem[] {
	return queryData?.pages.flatMap((page) => page.data) ?? [];
}

export function readPaginatedTotal<TItem>(
	queryData: PaginatedQueryData<TItem> | undefined,
): number {
	return queryData?.pages[0]?.total ?? 0;
}
