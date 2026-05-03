import Card from "@suid/material/Card";
import CardContent from "@suid/material/CardContent";
import Chip from "@suid/material/Chip";
import Stack from "@suid/material/Stack";
import Typography from "@suid/material/Typography";
import type { Component } from "solid-js";
import type { StockSummary } from "../api/stock";

type StockCardProps = Readonly<{
	stock: StockSummary;
}>;

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
				</Stack>
			</CardContent>
		</Card>
	);
};

export default StockCard;
