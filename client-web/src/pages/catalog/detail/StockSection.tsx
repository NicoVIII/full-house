import Paper from "@suid/material/Paper";
import Stack from "@suid/material/Stack";
import Typography from "@suid/material/Typography";
import type { Component } from "solid-js";

import type { Product } from "../../../data/product/product";
import CreateStockItemButton from "./CreateStockItemButton";

type StockSectionProps = Readonly<{
	product: Product;
	onStockItemCreated: () => void;
}>;

const StockSection: Component<StockSectionProps> = (props) => {
	return (
		<Paper elevation={0} sx={{ p: 3 }}>
			<Stack spacing={2}>
				<Stack
					direction={{ xs: "column", sm: "row" }}
					spacing={1}
					sx={{
						alignItems: { xs: "flex-start", sm: "center" },
						justifyContent: "space-between",
					}}
				>
					<Typography variant="h6" sx={{ fontWeight: 600 }}>
						Stock
					</Typography>
					<CreateStockItemButton
						productId={props.product.id}
						onCreated={props.onStockItemCreated}
					/>
				</Stack>
			</Stack>
		</Paper>
	);
};

export default StockSection;
