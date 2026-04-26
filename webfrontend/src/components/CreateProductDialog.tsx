import Alert from '@suid/material/Alert';
import Box from '@suid/material/Box';
import Button from '@suid/material/Button';
import Dialog from '@suid/material/Dialog';
import DialogActions from '@suid/material/DialogActions';
import DialogContent from '@suid/material/DialogContent';
import DialogTitle from '@suid/material/DialogTitle';
import Stack from '@suid/material/Stack';
import TextField from '@suid/material/TextField';
import type { Component } from 'solid-js';
import { Show, createSignal } from 'solid-js';
import { createProduct } from '../api/products';

type CreateProductDialogProps = Readonly<{
    onCreated: () => void | Promise<void>;
}>;

const CreateProductDialog: Component<CreateProductDialogProps> = (props) => {
    const [isOpen, setIsOpen] = createSignal(false);
    const [name, setName] = createSignal('');
    const [parentProductId, setParentProductId] = createSignal('');
    const [validationError, setValidationError] = createSignal<string | null>(null);
    const [submitError, setSubmitError] = createSignal<string | null>(null);
    const [isSubmitting, setIsSubmitting] = createSignal(false);

    const close = () => {
        setIsOpen(false);
        setValidationError(null);
        setSubmitError(null);
    };

    const reset = () => {
        setName('');
        setParentProductId('');
    };

    const handleSubmit = () => {
        const trimmedName = name().trim();
        const trimmedParent = parentProductId().trim();

        if (trimmedName === '') {
            setValidationError('Product name must not be empty.');
            return;
        }

        setValidationError(null);
        setSubmitError(null);
        setIsSubmitting(true);

        const onCreated = props.onCreated;

        void createProduct({
            name: trimmedName,
            parent_product_id: trimmedParent === '' ? null : trimmedParent,
        })
            .then(async () => {
                await onCreated();
                reset();
                close();
            })
            .catch((error: unknown) => {
                setSubmitError(
                    error instanceof Error ? error.message : 'Failed to create product.',
                );
            })
            .finally(() => {
                setIsSubmitting(false);
            });
    };

    return (
        <>
            <Button onClick={() => setIsOpen(true)} variant="contained">
                Add Product
            </Button>

            <Dialog fullWidth maxWidth="sm" open={isOpen()} onClose={close}>
                <DialogTitle>Add Product</DialogTitle>
                <Box component="form" onSubmit={(e) => { e.preventDefault(); handleSubmit(); }}>
                    <DialogContent>
                        <Stack spacing={2}>
                            <TextField
                                autoFocus
                                disabled={isSubmitting()}
                                error={validationError() !== null}
                                helperText={validationError() ?? 'Required'}
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
                            {isSubmitting() ? 'Creating...' : 'Create Product'}
                        </Button>
                    </DialogActions>
                </Box>
            </Dialog>
        </>
    );
};

export default CreateProductDialog;
