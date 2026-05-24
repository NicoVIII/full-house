import Alert from "@suid/material/Alert";
import Button from "@suid/material/Button";
import MenuItem from "@suid/material/MenuItem";
import Paper from "@suid/material/Paper";
import Stack from "@suid/material/Stack";
import TextField from "@suid/material/TextField";
import Typography from "@suid/material/Typography";
import type { Component } from "solid-js";
import { For, Show } from "solid-js";

import type { Product } from "../../data/product/product";
import type { StockSummary } from "../../data/stock/stock";
import type { ScanMode } from "./use_barcode_stock_workflow";

type BarcodeWorkflowPanelProps = Readonly<{
	mode: ScanMode;
	onChangeMode: (mode: ScanMode) => void;
	barcodeInput: string;
	onBarcodeInputChange: (value: string) => void;
	onLookup: () => void;
	lookupIsPending: boolean;
	onStartCamera: () => void;
	onStopCamera: () => void;
	isCameraActive: boolean;
	onVideoRef: (element: Readonly<HTMLVideoElement>) => void;
	cameraError: string | undefined;
	scanError: string | undefined;
	resolvedProduct: Product | undefined;
	bestBeforeDate: string;
	onBestBeforeDateChange: (value: string) => void;
	onAddStock: () => void;
	createIsPending: boolean;
	selectedBatchDate: string;
	onSelectedBatchDateChange: (value: string) => void;
	visibleBatchesForResolvedProduct: StockSummary[];
	onRemoveStock: () => void;
	removeIsPending: boolean;
	onCreateFromUnknownBarcode: () => void;
}>;

const BarcodeWorkflowPanel: Component<BarcodeWorkflowPanelProps> = (props) => {
	return (
		<Paper elevation={0} sx={{ mb: 3, p: 3 }}>
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
						Barcode workflow
					</Typography>
					<Stack direction="row" spacing={1}>
						<Button
							variant={props.mode === "add" ? "contained" : "outlined"}
							onClick={() => {
								props.onChangeMode("add");
							}}
						>
							Add
						</Button>
						<Button
							variant={props.mode === "remove" ? "contained" : "outlined"}
							onClick={() => {
								props.onChangeMode("remove");
							}}
						>
							Remove
						</Button>
					</Stack>
				</Stack>

				<Stack direction={{ xs: "column", md: "row" }} spacing={1}>
					<TextField
						fullWidth
						label="Barcode"
						value={props.barcodeInput}
						onChange={(event) => {
							props.onBarcodeInputChange(event.target.value);
						}}
					/>
					<Button variant="contained" onClick={props.onLookup} disabled={props.lookupIsPending}>
						{props.lookupIsPending ? "Looking up..." : "Lookup"}
					</Button>
				</Stack>

				<Stack direction="row" spacing={1}>
					<Button variant="outlined" onClick={props.onStartCamera} disabled={props.isCameraActive}>
						Start camera scan
					</Button>
					<Button variant="text" onClick={props.onStopCamera} disabled={!props.isCameraActive}>
						Stop camera
					</Button>
				</Stack>

				<Show when={props.isCameraActive}>
					<video
						muted
						playsinline
						ref={props.onVideoRef}
						style={{
							width: "100%",
							"max-width": "420px",
							"border-radius": "8px",
							border: "1px solid #d2d7de",
						}}
					/>
				</Show>

				<Show when={props.cameraError !== undefined}>
					<Alert severity="error">{props.cameraError}</Alert>
				</Show>
				<Show when={props.scanError !== undefined}>
					<Alert severity="error">{props.scanError}</Alert>
				</Show>

				<Show when={props.resolvedProduct !== undefined}>
					<Paper elevation={0} sx={{ p: 2, border: "1px solid #d2d7de" }}>
						<Stack spacing={1.5}>
							<Typography variant="h6">{props.resolvedProduct?.name}</Typography>
							<Typography color="text.secondary" variant="body2">
								{props.resolvedProduct?.id}
							</Typography>

							<Show
								when={props.mode === "add"}
								fallback={
									<Stack direction={{ xs: "column", sm: "row" }} spacing={1}>
										<TextField
											fullWidth
											select
											label="Best-before batch"
											value={props.selectedBatchDate}
											onChange={(event) => {
												props.onSelectedBatchDateChange(event.target.value);
											}}
										>
											<For each={props.visibleBatchesForResolvedProduct}>
												{(batch) => (
													<MenuItem value={batch.best_before_date}>
														{batch.best_before_date} ({batch.quantity})
													</MenuItem>
												)}
											</For>
										</TextField>
										<Button
											variant="contained"
											onClick={props.onRemoveStock}
											disabled={props.removeIsPending}
										>
											{props.removeIsPending ? "Removing..." : "Remove one"}
										</Button>
									</Stack>
								}
							>
								<Stack direction={{ xs: "column", sm: "row" }} spacing={1}>
									<TextField
										fullWidth
										type="date"
										label="Best before date"
										InputLabelProps={{ shrink: true }}
										value={props.bestBeforeDate}
										onChange={(event) => {
											props.onBestBeforeDateChange(event.target.value);
										}}
									/>
									<Button
										variant="contained"
										onClick={props.onAddStock}
										disabled={props.createIsPending}
									>
										{props.createIsPending ? "Adding..." : "Add stock"}
									</Button>
								</Stack>
							</Show>
						</Stack>
					</Paper>
				</Show>

				<Show when={props.scanError !== undefined && props.resolvedProduct === undefined}>
					<Button variant="outlined" onClick={props.onCreateFromUnknownBarcode}>
						Create product from this barcode
					</Button>
				</Show>
			</Stack>
		</Paper>
	);
};

export default BarcodeWorkflowPanel;
