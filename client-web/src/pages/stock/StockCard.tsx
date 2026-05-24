import Button from "@suid/material/Button";
import Card from "@suid/material/Card";
import CardContent from "@suid/material/CardContent";
import Chip from "@suid/material/Chip";
import Stack from "@suid/material/Stack";
import Typography from "@suid/material/Typography";
import type { Component } from "solid-js";

import type { StockSummary } from "../../data/stock/stock";

type StockCardProps = Readonly<{
	stock: StockSummary;
	onRemove: (stock: StockSummary) => void;
	isRemoving: boolean;
}>;

function formatBestBeforeDate(isoDate: string): string {
	const parsed = /^(\d{4})-(\d{2})-(\d{2})$/.exec(isoDate);

	if (!parsed) {
		return isoDate;
	}

	const yearRaw = parsed[1];
	const monthRaw = parsed[2];
	const dayRaw = parsed[3];

	if (yearRaw === undefined || monthRaw === undefined || dayRaw === undefined) {
		return isoDate;
	}
	const year = Number.parseInt(yearRaw, 10);
	const month = Number.parseInt(monthRaw, 10);
	const day = Number.parseInt(dayRaw, 10);

	return new Intl.DateTimeFormat(undefined, {
		year: "numeric",
		month: "short",
		day: "numeric",
	}).format(new Date(year, month - 1, day));
}

const StockCard: Component<StockCardProps> = (props) => {
	return (
		<Card class="product-card" elevation={0}>
			<CardContent>
				<Stack spacing={2}>
					<Typography variant="h5" component="h2" sx={{ fontWeight: 600 }}>
						{props.stock.product_name}
					</Typography>
					<Chip
						color="success"
						label={`In stock: ${String(props.stock.quantity)}`}
						sx={{ alignSelf: "flex-start" }}
						variant="outlined"
					/>
					<Chip
						color="info"
						label={`Best before: ${formatBestBeforeDate(props.stock.best_before_date)}`}
						sx={{ alignSelf: "flex-start" }}
						variant="outlined"
					/>
					<Button
						disabled={props.isRemoving}
						onClick={() => {
							props.onRemove(props.stock);
						}}
						variant="outlined"
						sx={{ alignSelf: "flex-start" }}
					>
						{props.isRemoving ? "Removing..." : "Remove one"}
					</Button>
				</Stack>
			</CardContent>
		</Card>
	);
};

export default StockCard;
