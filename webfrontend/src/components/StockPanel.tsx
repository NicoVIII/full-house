import Alert from "@suid/material/Alert";
import Box from "@suid/material/Box";
import Button from "@suid/material/Button";
import CircularProgress from "@suid/material/CircularProgress";
import Paper from "@suid/material/Paper";
import Stack from "@suid/material/Stack";
import Typography from "@suid/material/Typography";
import type { Component } from "solid-js";
import { For, Show } from "solid-js";
import type { StockSummary } from "../api/stock";
import StockCard from "./StockCard";

type StockPanelProps = Readonly<{
	error: Error | null;
	hasNextPage: boolean;
	isError: boolean;
	isFetchingNextPage: boolean;
	isPending: boolean;
	onLoadMore: () => void;
	stock: StockSummary[];
	total: number;
}>;

const StockPanel: Component<StockPanelProps> = (props) => {
	const shownCount = () => props.stock.length;

	return (
		<Show
			when={!props.isPending}
			fallback={
				<Paper
					elevation={0}
					sx={{ display: "grid", p: 6, placeItems: "center" }}
				>
					<Stack spacing={2} sx={{ alignItems: "center" }}>
						<CircularProgress />
						<Typography>Loading stock...</Typography>
					</Stack>
				</Paper>
			}
		>
			<Show
				when={!props.isError}
				fallback={
					<Alert severity="error">
						{props.error instanceof Error
							? props.error.message
							: "Failed to load stock."}
					</Alert>
				}
			>
				<Stack spacing={3}>
					<Paper elevation={0} sx={{ p: 3 }}>
						<Stack
							direction={{ xs: "column", sm: "row" }}
							spacing={2}
							sx={{
								alignItems: { xs: "flex-start", sm: "center" },
								justifyContent: "space-between",
							}}
						>
							<Typography variant="h6" sx={{ fontWeight: 600 }}>
								{props.total} products available
							</Typography>
							<Typography color="text.secondary">
								Showing {shownCount()} of {props.total}
							</Typography>
						</Stack>
					</Paper>

					<Box class="product-grid">
						<For each={props.stock}>
							{(stock) => <StockCard stock={stock} />}
						</For>
					</Box>

					<Paper elevation={0} sx={{ p: 3 }}>
						<Stack spacing={1.5} sx={{ alignItems: "center" }}>
							<Button
								disabled={!props.hasNextPage || props.isFetchingNextPage}
								onClick={props.onLoadMore}
								size="large"
								variant="contained"
							>
								{props.isFetchingNextPage
									? "Loading more..."
									: "Load more products"}
							</Button>
							<Typography color="text.secondary" variant="body2">
								<Show
									when={props.hasNextPage}
									fallback={<span>All stock loaded.</span>}
								>
									More stock data available. Load the next batch.
								</Show>
							</Typography>
						</Stack>
					</Paper>
				</Stack>
			</Show>
		</Show>
	);
};

export default StockPanel;
