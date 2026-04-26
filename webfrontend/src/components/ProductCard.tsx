import Card from '@suid/material/Card';
import CardContent from '@suid/material/CardContent';
import Chip from '@suid/material/Chip';
import Stack from '@suid/material/Stack';
import Typography from '@suid/material/Typography';
import type { Component } from 'solid-js';
import { Show } from 'solid-js';
import type { Product } from '../api/products';

type ProductCardProps = {
    product: Product;
};

const ProductCard: Component<ProductCardProps> = (props) => {
    return (
        <Card class="product-card" elevation={0}>
            <CardContent>
                <Stack spacing={2}>
                    <Typography variant="h5" component="h2" sx={{ fontWeight: 600 }}>
                        {props.product.name}
                    </Typography>
                    <Show when={props.product.parent_product_id}>
                        <Chip
                            color="primary"
                            label={`Parent: ${props.product.parent_product_id}`}
                            variant="outlined"
                            sx={{ alignSelf: 'flex-start' }}
                        />
                    </Show>
                </Stack>
            </CardContent>
        </Card>
    );
};

export default ProductCard;
