import AddIcon from "@suid/icons-material/Add";
import Alert from "@suid/material/Alert";
import Box from "@suid/material/Box";
import Button from "@suid/material/Button";
import Dialog from "@suid/material/Dialog";
import DialogActions from "@suid/material/DialogActions";
import DialogContent from "@suid/material/DialogContent";
import DialogTitle from "@suid/material/DialogTitle";
import Fab from "@suid/material/Fab";
import { Portal } from "@suid/material/Portal/Portal";
import Stack from "@suid/material/Stack";
import TextField from "@suid/material/TextField";
import { useMutation } from "@tanstack/solid-query";
import type { Component } from "solid-js";
import { createSignal, Show } from "solid-js";
import { createProductMutationOptions } from "../../data/product/create/mutation";

type CreateProductDialogProps = Readonly<{
	onCreated: () => void | Promise<void>;
}>;

const CreateProductFab: Component<CreateProductDialogProps> = (props) => {
	const [isOpen, setIsOpen] = createSignal(false);
	const [name, setName] = createSignal("");
	const [parentProductId, setParentProductId] = createSignal("");
	const [validationError, setValidationError] = createSignal<string | null>(
		null,
	);
	const [submitError, setSubmitError] = createSignal<string | null>(null);
	const [isSubmitting, setIsSubmitting] = createSignal(false);

	const close = () => {
		setIsOpen(false);
		setValidationError(null);
		setSubmitError(null);
	};

	const reset = () => {
		setName("");
		setParentProductId("");
	};

	const createProductMutation = useMutation(() => ({
		...createProductMutationOptions(),
		onSuccess: async () => {
			await props.onCreated();
			reset();
			close();
		},
		onError: (error: Readonly<Error>) => {
			setSubmitError(error.message);
		},
		onSettled: () => {
			setIsSubmitting(false);
		},
	}));
	const handleSubmit = () => {
		const trimmedName = name().trim();
		const trimmedParent = parentProductId().trim();

		if (trimmedName === "") {
			setValidationError("Product name must not be empty.");
			return;
		}

		setValidationError(null);
		setSubmitError(null);
		setIsSubmitting(true);

		createProductMutation.mutate({
			name: trimmedName,
			parent_product_id: trimmedParent !== "" ? trimmedParent : undefined,
		});
	};

	const fabStyle = {
		position: "fixed",
		bottom: 32,
		right: 32,
	} as const;

	return (
		<>
			<Portal>
				<Fab
					sx={{ ...fabStyle, display: { xs: "inline-flex", md: "none" } }}
					color="primary"
					variant="extended"
					onClick={() => setIsOpen(true)}
				>
					<AddIcon /> Product
				</Fab>
			</Portal>
			<Button
				sx={{ display: { xs: "none", md: "inline-flex" } }}
				variant="contained"
				onClick={() => setIsOpen(true)}
			>
				<AddIcon /> Product
			</Button>

			<Dialog fullWidth maxWidth="sm" open={isOpen()} onClose={close}>
				<DialogTitle>Add Product</DialogTitle>
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
								error={validationError() !== null}
								helperText={validationError() ?? "Required"}
								label="Name"
								onChange={(event) => {
									setName(event.target.value);
									setValidationError(
										validationError() !== null ? null : validationError(),
									);
								}}
								required
								value={name()}
							/>
							<TextField
								disabled={isSubmitting()}
								helperText="Optional UUID for parent product"
								label="Parent Product ID"
								onChange={(event) => {
									setParentProductId(event.target.value);
								}}
								value={parentProductId()}
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
							{isSubmitting() ? "Creating..." : "Create Product"}
						</Button>
					</DialogActions>
				</Box>
			</Dialog>
		</>
	);
};

export default CreateProductFab;
