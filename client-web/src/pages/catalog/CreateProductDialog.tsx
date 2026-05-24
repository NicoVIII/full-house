import Alert from "@suid/material/Alert";
import Box from "@suid/material/Box";
import Button from "@suid/material/Button";
import Dialog from "@suid/material/Dialog";
import DialogActions from "@suid/material/DialogActions";
import DialogContent from "@suid/material/DialogContent";
import DialogTitle from "@suid/material/DialogTitle";
import Stack from "@suid/material/Stack";
import TextField from "@suid/material/TextField";
import type { Component } from "solid-js";
import { Show } from "solid-js";

type CreateProductDialogProps = Readonly<{
	open: boolean;
	isSubmitting: boolean;
	name: string;
	onNameChange: (value: string) => void;
	parentProductId: string;
	onParentProductIdChange: (value: string) => void;
	barcodeInput: string;
	onBarcodeInputChange: (value: string) => void;
	validationError: string | undefined;
	submitError: string | undefined;
	onSubmit: () => void;
	onClose: () => void;
}>;

const CreateProductDialog: Component<CreateProductDialogProps> = (props) => {
	return (
		<Dialog fullWidth maxWidth="sm" open={props.open} onClose={props.onClose}>
			<DialogTitle>Add Product</DialogTitle>
			<Box
				component="form"
				onSubmit={(e) => {
					e.preventDefault();
					props.onSubmit();
				}}
			>
				<DialogContent>
					<Stack spacing={2}>
						<TextField
							autoFocus
							disabled={props.isSubmitting}
							error={props.validationError !== undefined}
							helperText={props.validationError ?? "Required"}
							label="Name"
							onChange={(event) => {
								props.onNameChange(event.target.value);
							}}
							required
							value={props.name}
						/>
						<TextField
							disabled={props.isSubmitting}
							helperText="Optional UUID for parent product"
							label="Parent Product ID"
							onChange={(event) => {
								props.onParentProductIdChange(event.target.value);
							}}
							value={props.parentProductId}
						/>
						<TextField
							disabled={props.isSubmitting}
							helperText="Optional. Separate multiple barcodes with commas or new lines"
							label="Barcodes"
							minRows={2}
							multiline
							onChange={(event) => {
								props.onBarcodeInputChange(event.target.value);
							}}
							value={props.barcodeInput}
						/>
						<Show when={props.submitError !== undefined}>
							<Alert severity="error">{props.submitError}</Alert>
						</Show>
					</Stack>
				</DialogContent>
				<DialogActions>
					<Button disabled={props.isSubmitting} onClick={props.onClose} variant="text">
						Cancel
					</Button>
					<Button disabled={props.isSubmitting} type="submit" variant="contained">
						{props.isSubmitting ? "Creating..." : "Create Product"}
					</Button>
				</DialogActions>
			</Box>
		</Dialog>
	);
};

export default CreateProductDialog;
