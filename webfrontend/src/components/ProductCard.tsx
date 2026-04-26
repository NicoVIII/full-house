import Card from '@suid/material/Card';
import CardContent from '@suid/material/CardContent';
import Chip from '@suid/material/Chip';
import DeleteOutline from '@suid/icons-material/DeleteOutline';
import IconButton from '@suid/material/IconButton';
import Box from '@suid/material/Box';
import Stack from '@suid/material/Stack';
import Typography from '@suid/material/Typography';
import type { Component } from 'solid-js';
import { Show, createSignal } from 'solid-js';
import type { Product } from '../api/products';

type ProductCardProps = Readonly<{
    product: Product;
    onDelete?: ((productId: string) => Promise<void>) | undefined;
}>;

const ProductCard: Component<ProductCardProps> = (props) => {
    const [isDeleting, setIsDeleting] = createSignal(false);

    const handleDelete = async () => {
        const confirmed = window.confirm(`Delete product "${props.product.name}"?`);
        if (!confirmed) {
            return;
        }

        setIsDeleting(true);
        try {
            await props.onDelete?.(props.product.id);
        } finally {
            setIsDeleting(false);
        }
    };

    return (
        <Card class="product-card" elevation={0}>
            <CardContent>
                <Stack spacing={2}>
                    <Box sx={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 1 }}>
                        <Typography variant="h5" component="h2" sx={{ fontWeight: 600 }}>
                            {props.product.name}
                        </Typography>
                        <Show when={props.onDelete}>
                            <IconButton
                                aria-label="Delete product"
                                title="Delete product"
                                onClick={() => {
                                    void handleDelete();
                                }}
                                disabled={isDeleting()}
                                size="small"
                                color="error"
                            >
                                <DeleteOutline fontSize="small" />
                            </IconButton>
                        </Show>
                    </Box>
                    <Show when={props.product.parent_product_id}>
                        {(parentProductId) => (
                            <Chip
                                color="primary"
                                label={`Parent: ${parentProductId()}`}
                                variant="outlined"
                                sx={{ alignSelf: 'flex-start' }}
                            />
                        )}
                    </Show>
                </Stack>
            </CardContent>
        </Card>
    );
};

export default ProductCard;
