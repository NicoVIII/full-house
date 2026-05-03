/* @refresh reload */

import { attachDevtoolsOverlay } from "@solid-devtools/overlay";
import { Navigate, Route, Router } from "@solidjs/router";
import CssBaseline from "@suid/material/CssBaseline";
import { QueryClient, QueryClientProvider } from "@tanstack/solid-query";
import { SolidQueryDevtools } from "@tanstack/solid-query-devtools";
import { render } from "solid-js/web";
import App from "./App";
import ProductDetailPage from "./pages/ProductDetailPage";
import ProductsPage from "./pages/ProductsPage";
import StockPage from "./pages/StockPage";

// eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- We are sure this is there
const root = document.getElementById("root")!;
const queryClient = new QueryClient();

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
