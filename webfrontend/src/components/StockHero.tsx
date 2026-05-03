import Chip from "@suid/material/Chip";
import Paper from "@suid/material/Paper";
import Stack from "@suid/material/Stack";
import Typography from "@suid/material/Typography";
import type { Component } from "solid-js";

const StockHero: Component = () => {
	return (
		<Paper class="hero-panel" elevation={0}>
			<Stack spacing={2}>
				<Chip label="Inventory Snapshot" sx={{ alignSelf: "flex-start" }} />
				<Typography variant="h2" component="h1" sx={{ fontWeight: 700 }}>
					In Stock
				</Typography>
			</Stack>
		</Paper>
	);
};

export default StockHero;
