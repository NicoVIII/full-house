import { Component, lazy } from "solid-js";

type Route = Readonly<{
	name: string;
	path: string;
	build: (...params: readonly never[]) => string;
	component: Component;
	subs?: Record<string, Route>;
}>;

function buildSimplePath(pattern: string): {
	path: string;
	build: () => string;
} {
	return {
		path: pattern,
		build: () => pattern,
	};
}

export const routes = {
	catalog: {
		name: "Catalog",
		...buildSimplePath("/catalog"),
		component: lazy(() => import("./pages/catalog/CatalogPage")),
		subs: {
			detail: {
				name: "Product",
				path: "/catalog/:productId",
				build: (productId: string) => `/catalog/${productId}`,
				component: lazy(
					() => import("./pages/catalog/detail/CatalogDetailPage"),
				),
			},
		},
	},
	stock: {
		name: "Stock",
		...buildSimplePath("/stock"),
		component: lazy(() => import("./pages/StockPage")),
		subs: {},
	},
} as const satisfies Record<string, Route>;

export const allRoutes = Object.values(routes).flatMap((route) => [
	route,
	...Object.values(route.subs),
]);
export const mainRoutes = [routes.catalog, routes.stock] satisfies Route[];
export const defaultRoute = routes.catalog;
