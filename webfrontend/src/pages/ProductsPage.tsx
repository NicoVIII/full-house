import { createInfiniteQuery, type InfiniteData } from '@tanstack/solid-query';
import type { Component } from 'solid-js';
import { createMemo } from 'solid-js';
import { fetchProducts, type Product, type ProductListResponse } from '../api/products';
import ProductsHero from '../components/ProductsHero';
import ProductsPanel from '../components/ProductsPanel';
import { flattenPaginatedItems, readPaginatedTotal } from './paginated_query_helpers';

const PAGE_SIZE = 6;

const ProductsPage: Component = () => {
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

    return (
        <>
            <ProductsHero />
            <ProductsPanel
                error={productsQuery.error}
                hasNextPage={productsQuery.hasNextPage}
                isError={productsQuery.isError}
                isFetchingNextPage={productsQuery.isFetchingNextPage}
                isPending={productsQuery.isPending}
                onLoadMore={() => void productsQuery.fetchNextPage()}
                products={products()}
                total={total()}
            />
        </>
    );
};

export default ProductsPage;
