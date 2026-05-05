/* @refresh reload */

import { attachDevtoolsOverlay } from "@solid-devtools/overlay";
import { Navigate, Route, Router } from "@solidjs/router";
import Alert from "@suid/material/Alert/Alert";
import CssBaseline from "@suid/material/CssBaseline";
import { QueryClient, QueryClientProvider } from "@tanstack/solid-query";
import { SolidQueryDevtools } from "@tanstack/solid-query-devtools";
import { For } from "solid-js";
import { render } from "solid-js/web";
import App from "./App";
import { allRoutes, defaultRoute } from "./routes";

// eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- We are sure this is there
const root = document.getElementById("root")!;
const queryClient = new QueryClient();

render(
	() => (
		<QueryClientProvider client={queryClient}>
			<CssBaseline />
			<Router root={App} explicitLinks>
				<Route
					component={() => <Navigate href={defaultRoute.build()} />}
					path="/"
				/>
				<For each={allRoutes}>
					{({ component, path }) => <Route component={component} path={path} />}
				</For>
				<Route
					path="*"
					component={() => <Alert severity="error">Page not found</Alert>}
				/>
			</Router>
			<SolidQueryDevtools buttonPosition="bottom-left" />
		</QueryClientProvider>
	),
	root,
);

attachDevtoolsOverlay({ noPadding: true });
