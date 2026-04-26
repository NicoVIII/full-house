import Box from '@suid/material/Box';
import Container from '@suid/material/Container';
import Stack from '@suid/material/Stack';
import type { Component } from 'solid-js';
import { createMemo } from 'solid-js';
import { createInfiniteQuery } from '@tanstack/solid-query';
import { fetchProducts } from './api/products';
import ProductsHero from './components/ProductsHero';
import ProductsPanel from './components/ProductsPanel';
import './styles.css';

const PAGE_SIZE = 6;

const App: Component = () => {
  const productsQuery = createInfiniteQuery(() => ({
    queryKey: ['products', 'infinite'],
    initialPageParam: 0,
    queryFn: ({ pageParam }) =>
      fetchProducts({
        offset: pageParam,
        limit: PAGE_SIZE,
      }),
    getNextPageParam: (lastPage) => {
      const nextOffset = lastPage.offset + lastPage.data.length;
      return nextOffset < lastPage.total ? nextOffset : undefined;
    },
    staleTime: 1000 * 60 * 60, // 1 hour
  }));

  const products = createMemo(() =>
    productsQuery.data?.pages.flatMap((page) => page.data) ?? [],
  );

  const total = createMemo(() => productsQuery.data?.pages[0]?.total ?? 0);

  return (
    <Box class="app-shell">
      <Container maxWidth="md" sx={{ py: 6 }}>
        <Stack spacing={4}>
          <ProductsHero />
          <ProductsPanel
            error={productsQuery.error}
            hasNextPage={productsQuery.hasNextPage ?? false}
            isError={productsQuery.isError}
            isFetchingNextPage={productsQuery.isFetchingNextPage}
            isPending={productsQuery.isPending}
            onLoadMore={() => void productsQuery.fetchNextPage()}
            products={products()}
            total={total()}
          />
        </Stack>
      </Container>
    </Box>
  );
};

export default App;
