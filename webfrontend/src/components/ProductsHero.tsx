import Chip from '@suid/material/Chip';
import Paper from '@suid/material/Paper';
import Stack from '@suid/material/Stack';
import Typography from '@suid/material/Typography';
import type { Component } from 'solid-js';

const ProductsHero: Component = () => {
    return (
        <Paper class="hero-panel" elevation={0}>
            <Stack spacing={2}>
                <Chip label="Full House Catalog" sx={{ alignSelf: 'flex-start' }} />
                <Typography variant="h2" component="h1" sx={{ fontWeight: 700 }}>
                    Products
                </Typography>
            </Stack>
        </Paper>
    );
};

export default ProductsHero;
