import { A } from "@solidjs/router";
import Alert from "@suid/material/Alert";
import Box from "@suid/material/Box";
import CircularProgress from "@suid/material/CircularProgress";
import Stack from "@suid/material/Stack";
import Typography from "@suid/material/Typography";
import { useQuery } from "@tanstack/solid-query";
import type { Component } from "solid-js";
import { Show } from "solid-js";
import { productQueryOptions } from "../../../data/product/get/query";
import { ProductId } from "../../../data/product/product";
import { routes } from "../../../routes";

export type Props = Readonly<{
	id: ProductId;
}>;

const VariantRow: Component<Props> = (props) => {
	const query = useQuery(() => productQueryOptions(props.id));
	return (
		<Box class="product-detail-child-row">
			<Show
				when={query.data}
				fallback={
					<Show when={query.isError} fallback={<CircularProgress size={20} />}>
						<Alert severity="error">
							{query.error instanceof Error
								? query.error.message
								: "Failed to load variant."}
						</Alert>
					</Show>
				}
			>
				{(child) => (
					<Stack
						direction={{ xs: "column", sm: "row" }}
						spacing={1}
						sx={{
							alignItems: { xs: "flex-start", sm: "center" },
							justifyContent: "space-between",
						}}
					>
						<Stack spacing={0.25}>
							<A
								class="product-inline-link product-inline-link-strong"
								href={routes.catalog.subs.detail.build(child().id)}
							>
								{child().name}
							</A>
							<Typography color="text.secondary" variant="body2">
								{child().id}
							</Typography>
						</Stack>
					</Stack>
				)}
			</Show>
		</Box>
	);
};

export default VariantRow;
