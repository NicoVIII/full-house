export type StockSummary = Readonly<{
    product_id: string;
    product_name: string;
    quantity: number;
}>;

export type StockListResponse = Readonly<{
    data: StockSummary[];
    total: number;
    offset: number;
    limit: number;
}>;

type FetchStockParams = Readonly<{
    offset: number;
    limit: number;
}>;

export async function fetchStock({
    offset,
    limit,
}: FetchStockParams): Promise<StockListResponse> {
    const searchParams = new URLSearchParams({
        offset: String(offset),
        limit: String(limit),
    });
    const response = await fetch(`/api/v1/stock?${searchParams.toString()}`);

    if (!response.ok) {
        throw new Error(`Stock request failed with status ${String(response.status)}`);
    }

    return (await response.json()) as StockListResponse;
}
