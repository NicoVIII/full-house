type PaginatedQueryPage<TItem> = Readonly<{
	data: TItem[];
	total: number;
}>;

type PaginatedQueryData<TPage> = Readonly<{
	pages: TPage[];
}>;

export function flattenPaginatedItems<
	TItem,
	TPage extends PaginatedQueryPage<TItem>,
>(queryData: PaginatedQueryData<TPage> | undefined): TItem[] {
	return queryData?.pages.flatMap((page) => page.data) ?? [];
}

export function readPaginatedTotal<TPage extends Readonly<{ total: number }>>(
	queryData: PaginatedQueryData<TPage> | undefined,
): number {
	return queryData?.pages[0]?.total ?? 0;
}
