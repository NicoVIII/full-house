import { useSearchParams } from "@solidjs/router";
import AddIcon from "@suid/icons-material/Add";
import Button from "@suid/material/Button";
import Fab from "@suid/material/Fab";
import { Portal } from "@suid/material/Portal/Portal";
import { useMutation } from "@tanstack/solid-query";
import type { Component } from "solid-js";
import { createEffect, createSignal } from "solid-js";

import { createProductMutationOptions } from "../../data/product/create/mutation";
import CreateProductDialog from "./CreateProductDialog";

const CreateProductFab: Component = () => {
	const [searchParams, setSearchParams] = useSearchParams();
	const [isOpen, setIsOpen] = createSignal(false);
	const [name, setName] = createSignal("");
	const [parentProductId, setParentProductId] = createSignal("");
	const [barcodeInput, setBarcodeInput] = createSignal("");
	const [hasHandledBarcodePrefill, setHasHandledBarcodePrefill] = createSignal(false);
	const [validationError, setValidationError] = createSignal<string>();
	const [submitError, setSubmitError] = createSignal<string>();
	const [isSubmitting, setIsSubmitting] = createSignal(false);

	const close = () => {
		setIsOpen(false);
		setValidationError(undefined);
		setSubmitError(undefined);

		if (searchParams.barcode === undefined) {
			return;
		}

		setSearchParams({ barcode: undefined });
	};

	const reset = () => {
		setName("");
		setParentProductId("");
		setBarcodeInput("");
		setHasHandledBarcodePrefill(false);
	};

	createEffect(() => {
		const barcodeRaw = searchParams.barcode;
		const barcode = Array.isArray(barcodeRaw) ? barcodeRaw[0] : barcodeRaw;
		const shouldPrefill = barcode !== undefined && !hasHandledBarcodePrefill();

		// eslint-disable-next-line functional/no-conditional-statements
		if (shouldPrefill) {
			setBarcodeInput(barcode);
			setIsOpen(true);
			setHasHandledBarcodePrefill(true);
		}
	});

	const createProductMutation = useMutation(() =>
		createProductMutationOptions({
			onSuccess: () => {
				reset();
				// eslint-disable-next-line functional/no-conditional-statements
				if (searchParams.barcode !== undefined) {
					setSearchParams({ barcode: undefined });
				}
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
		const trimmedName = name().trim();
		const trimmedParent = parentProductId().trim();
		const barcodes = barcodeInput()
			.split(/[\n,]/)
			.map((value) => value.trim())
			.filter((value, index, all) => value !== "" && all.indexOf(value) === index);

		if (trimmedName === "") {
			setValidationError("Product name must not be empty.");
			return;
		}

		setValidationError(undefined);
		setSubmitError(undefined);
		setIsSubmitting(true);

		createProductMutation.mutate({
			name: trimmedName,
			parent_product_id: trimmedParent === "" ? undefined : trimmedParent,
			barcodes,
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

			<CreateProductDialog
				open={isOpen()}
				isSubmitting={isSubmitting()}
				name={name()}
				onNameChange={(value) => {
					setName(value);
					setValidationError(validationError() === undefined ? validationError() : undefined);
				}}
				parentProductId={parentProductId()}
				onParentProductIdChange={setParentProductId}
				barcodeInput={barcodeInput()}
				onBarcodeInputChange={setBarcodeInput}
				validationError={validationError()}
				submitError={submitError()}
				onSubmit={handleSubmit}
				onClose={close}
			/>
		</>
	);
};

export default CreateProductFab;
