import { createInfiniteQuery, type InfiniteData, useQueryClient } from '@tanstack/solid-query';
import Box from '@suid/material/Box';
import type { Component } from 'solid-js';
import { createMemo } from 'solid-js';
import { deleteProduct, fetchProducts, type Product, type ProductListResponse } from '../api/products';
import CreateProductDialog from '../components/CreateProductDialog';
import ProductsHero from '../components/ProductsHero';
import ProductsPanel from '../components/ProductsPanel';
import { flattenPaginatedItems, readPaginatedTotal } from './paginated_query_helpers';

const PAGE_SIZE = 6;

const ProductsPage: Component = () => {
    const queryClient = useQueryClient();

    const productsQuery = createInfiniteQuery<
        ProductListResponse,
        Error,
        InfiniteData<ProductListResponse, number>,
        readonly ['products', 'infinite'],
        number
    >(() => ({
        getNextPageParam: (lastPage) => {
            const nextOffset = lastPage.offset + lastPage.data.length;
            return nextOffset < lastPage.total ? nextOffset : undefined;
        },
        initialPageParam: 0,
        queryFn: ({ pageParam }) =>
            fetchProducts({
                limit: PAGE_SIZE,
                offset: pageParam,
            }),
        queryKey: ['products', 'infinite'] as const,
        staleTime: 1000 * 60 * 60,
    }));

    const products = createMemo(() =>
        flattenPaginatedItems<Product, ProductListResponse>(productsQuery.data),
    );
    const total = createMemo(() => readPaginatedTotal(productsQuery.data));

    const handleProductCreated = async () => {
        await queryClient.invalidateQueries({
            queryKey: ['products', 'infinite'],
        });
    };

    const handleProductDeleted = async (productId: string) => {
        try {
            await deleteProduct(productId);
            await queryClient.invalidateQueries({
                queryKey: ['products', 'infinite'],
            });
        } catch (error) {
            console.error('Delete failed:', error);
            throw error;
        }
    };

    return (
        <>
            <ProductsHero />
            <Box sx={{ mb: 3, display: 'flex', justifyContent: 'flex-end' }}>
                <CreateProductDialog onCreated={handleProductCreated} />
            </Box>
            <ProductsPanel
                error={productsQuery.error}
                hasNextPage={productsQuery.hasNextPage}
                isError={productsQuery.isError}
                isFetchingNextPage={productsQuery.isFetchingNextPage}
                isPending={productsQuery.isPending}
                onLoadMore={() => void productsQuery.fetchNextPage()}
                onProductDelete={handleProductDeleted}
                products={products()}
                total={total()}
            />
        </>
    );
};

export default ProductsPage;
