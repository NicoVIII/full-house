/* @refresh reload */
import { Navigate, Route, Router } from '@solidjs/router';
import { render } from 'solid-js/web';
import { QueryClient, QueryClientProvider } from '@tanstack/solid-query';
import { SolidQueryDevtools } from '@tanstack/solid-query-devtools';
import CssBaseline from '@suid/material/CssBaseline';

import App from './App';
import { attachDevtoolsOverlay } from '@solid-devtools/overlay';
import ProductDetailPage from './pages/ProductDetailPage';
import ProductsPage from './pages/ProductsPage';
import StockPage from './pages/StockPage';

const root = document.getElementById('root');
const queryClient = new QueryClient();

if (!(root instanceof HTMLElement)) {
  // eslint-disable-next-line functional/no-throw-statements -- This is okay - we have no good way to recover from this
  throw new Error(
    'Root element not found. Did you forget to add it to your index.html? Or maybe the id attribute got misspelled?',
  );
}

render(
  () => (
    <QueryClientProvider client={queryClient}>
      <CssBaseline />
      <Router root={App}>
        <Route component={() => <Navigate href="/products" />} path="/" />
        <Route component={ProductDetailPage} path="/products/:productId" />
        <Route component={ProductsPage} path="/products" />
        <Route component={StockPage} path="/stock" />
      </Router>
      <SolidQueryDevtools buttonPosition="bottom-left" />
    </QueryClientProvider>
  ),
  root,
);

attachDevtoolsOverlay({ noPadding: true });
