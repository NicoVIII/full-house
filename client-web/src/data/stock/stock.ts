export type StockSummary = Readonly<{
	product_id: string;
	product_name: string;
	best_before_date: string;
	quantity: number;
}>;

export type StockListResponse = Readonly<{
	data: StockSummary[];
	total: number;
	offset: number;
	limit: number;
}>;
