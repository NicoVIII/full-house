import Alert from "@suid/material/Alert";
import Button from "@suid/material/Button";
import Chip from "@suid/material/Chip";
import Paper from "@suid/material/Paper";
import Stack from "@suid/material/Stack";
import TextField from "@suid/material/TextField";
import Typography from "@suid/material/Typography";
import { useMutation } from "@tanstack/solid-query";
import type { Component } from "solid-js";
import { createSignal, For, Show } from "solid-js";

import { type Product } from "../../../data/product/product";
import { updateProductBarcodesMutationOptions } from "../../../data/product/update_barcodes/mutation";

type BarcodeSectionProps = Readonly<{
	product: Product;
}>;

const BarcodeSection: Component<BarcodeSectionProps> = (props) => {
	const [newBarcode, setNewBarcode] = createSignal("");
	const [barcodeError, setBarcodeError] = createSignal<string>();

	const updateBarcodesMutation = useMutation(() =>
		updateProductBarcodesMutationOptions({
			onSuccess: () => {
				setNewBarcode("");
				setBarcodeError(undefined);
			},
			onError: (error) => {
				setBarcodeError(error.message);
			},
		}),
	);

	const handleAddBarcode = () => {
		const barcode = newBarcode().trim();

		if (barcode === "") {
			setBarcodeError("Barcode must not be empty.");
			return;
		}

		setBarcodeError(undefined);
		updateBarcodesMutation.mutate({
			id: props.product.id,
			add_barcodes: [barcode],
			remove_barcodes: [],
		});
	};

	const handleRemoveBarcode = (barcode: string) => {
		setBarcodeError(undefined);
		updateBarcodesMutation.mutate({
			id: props.product.id,
			add_barcodes: [],
			remove_barcodes: [barcode],
		});
	};

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
						Barcodes
					</Typography>
					<Typography color="text.secondary" variant="body2">
						{props.product.barcodes.length} barcode{props.product.barcodes.length === 1 ? "" : "s"}
					</Typography>
				</Stack>
				<Show
					when={props.product.barcodes.length > 0}
					fallback={<Typography color="text.secondary">No barcodes assigned.</Typography>}
				>
					<Stack direction="row" spacing={1} sx={{ flexWrap: "wrap", gap: 1 }}>
						<For each={props.product.barcodes}>
							{(barcode) => (
								<Chip
									label={barcode}
									onDelete={() => {
										handleRemoveBarcode(barcode);
									}}
									disabled={updateBarcodesMutation.isPending}
									variant="outlined"
								/>
							)}
						</For>
					</Stack>
				</Show>
				<Stack direction={{ xs: "column", sm: "row" }} spacing={1}>
					<TextField
						fullWidth
						label="New barcode"
						value={newBarcode()}
						disabled={updateBarcodesMutation.isPending}
						onChange={(event) => setNewBarcode(event.target.value)}
					/>
					<Button
						variant="outlined"
						disabled={updateBarcodesMutation.isPending}
						onClick={handleAddBarcode}
					>
						{updateBarcodesMutation.isPending ? "Saving..." : "Add barcode"}
					</Button>
				</Stack>
				<Show when={barcodeError() !== undefined}>
					<Alert severity="error">{barcodeError()}</Alert>
				</Show>
			</Stack>
		</Paper>
	);
};

export default BarcodeSection;
