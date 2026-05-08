import AddIcon from "@suid/icons-material/Add";
import Alert from "@suid/material/Alert";
import Box from "@suid/material/Box";
import Button from "@suid/material/Button";
import Dialog from "@suid/material/Dialog";
import DialogActions from "@suid/material/DialogActions";
import DialogContent from "@suid/material/DialogContent";
import DialogTitle from "@suid/material/DialogTitle";
import Stack from "@suid/material/Stack";
import TextField from "@suid/material/TextField";
import { useMutation } from "@tanstack/solid-query";
import type { Component } from "solid-js";
import { createSignal, Show } from "solid-js";
import type { ProductId } from "../../../data/product/product";
import { createStockItemMutationOptions } from "../../../data/stock/create/mutation";

type CreateStockItemButtonProps = Readonly<{
	productId: ProductId;
	onCreated: () => void | Promise<void>;
}>;

const CreateStockItemButton: Component<CreateStockItemButtonProps> = (
	props,
) => {
	const [isOpen, setIsOpen] = createSignal(false);
	const [productId, setProductId] = createSignal("");
	const [submitError, setSubmitError] = createSignal<string | null>(null);
	const [isSubmitting, setIsSubmitting] = createSignal(false);

	const open = () => {
		setProductId(props.productId);
		setIsOpen(true);
	};

	const close = () => {
		setIsOpen(false);
		setSubmitError(null);
	};

	const mutation = useMutation(() =>
		createStockItemMutationOptions({
			onSuccess: async () => {
				await props.onCreated();
				close();
			},
			onError: (error: Readonly<Error>) => {
				setSubmitError(error.message);
			},
			onSettled: () => {
				setIsSubmitting(false);
			},
		}),
	);

	const handleSubmit = () => {
		setSubmitError(null);
		setIsSubmitting(true);
		mutation.mutate({ product_id: productId() });
	};

	return (
		<>
			<Button variant="contained" onClick={open}>
				<AddIcon /> Stock Item
			</Button>

			<Dialog fullWidth maxWidth="sm" open={isOpen()} onClose={close}>
				<DialogTitle>Add Stock Item</DialogTitle>
				<Box
					component="form"
					onSubmit={(e) => {
						e.preventDefault();
						handleSubmit();
					}}
				>
					<DialogContent>
						<Stack spacing={2}>
							<TextField
								autoFocus
								disabled={isSubmitting()}
								helperText="UUID of the product"
								label="Product ID"
								onChange={(event) => {
									setProductId(event.target.value);
								}}
								required
								value={productId()}
							/>
							<Show when={submitError() !== null}>
								<Alert severity="error">{submitError()}</Alert>
							</Show>
						</Stack>
					</DialogContent>
					<DialogActions>
						<Button disabled={isSubmitting()} onClick={close} variant="text">
							Cancel
						</Button>
						<Button disabled={isSubmitting()} type="submit" variant="contained">
							{isSubmitting() ? "Creating..." : "Add Stock Item"}
						</Button>
					</DialogActions>
				</Box>
			</Dialog>
		</>
	);
};

export default CreateStockItemButton;
