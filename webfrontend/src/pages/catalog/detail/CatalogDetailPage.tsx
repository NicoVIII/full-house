import { A, useNavigate, useParams } from "@solidjs/router";
import DeleteOutline from "@suid/icons-material/DeleteOutline";
import Alert from "@suid/material/Alert";
import Box from "@suid/material/Box";
import CircularProgress from "@suid/material/CircularProgress";
import IconButton from "@suid/material/IconButton";
import Paper from "@suid/material/Paper";
import Stack from "@suid/material/Stack";
import Typography from "@suid/material/Typography";
import { useMutation, useQuery } from "@tanstack/solid-query";
import type { Component } from "solid-js";
import { createMemo, For, Show } from "solid-js";
import { deleteProductMutationOptions } from "../../../data/product/delete/mutation";
import { productQueryOptions } from "../../../data/product/get/query";
import { Product, ProductId } from "../../../data/product/product";
import { routes } from "../../../routes";
import ParentLink from "./ParentLink";
import VariantRow from "./VariantRow";

const usePageParams = () => {
	const params = useParams();
	// eslint-disable-next-line @typescript-eslint/no-non-null-assertion
	const productId = createMemo(() => ProductId(params.productId!));
	return { productId };
};

const ProductDetailPage: Component = () => {
	const navigate = useNavigate();
	const { productId } = usePageParams();

	const productQuery = useQuery(() => productQueryOptions(productId()));
	const product = () => productQuery.data;

	const deleteMutation = useMutation(() =>
		deleteProductMutationOptions(productId()),
	);

	const handleDelete = (p: Product) => {
		if (!window.confirm(`Delete product "${p.name}"?`)) return;
		deleteMutation.mutate(undefined, {
			onSuccess: () => {
				navigate(routes.catalog.build());
			},
			onError: (error) => {
				console.error("Delete failed:", error);
			},
		});
	};

	return (
		<Stack spacing={3}>
			<Paper class="hero-panel" elevation={0}>
				<Stack spacing={2}>
					<A class="product-inline-link" href={routes.catalog.build()}>
						Back to catalog
					</A>
					<Show
						when={!productQuery.isError}
						fallback={
							<Alert severity="error">
								{productQuery.error instanceof Error
									? productQuery.error.message
									: "Failed to load product."}
							</Alert>
						}
					>
						<Show
							when={product()}
							fallback={
								<Stack spacing={2} sx={{ alignItems: "center", py: 4 }}>
									<CircularProgress />
									<Typography>Loading product...</Typography>
								</Stack>
							}
						>
							{(product) => (
								<Box
									sx={{
										display: "flex",
										alignItems: "flex-start",
										justifyContent: "space-between",
										gap: 2,
									}}
								>
									<Stack spacing={1.5}>
										<Typography
											variant="overline"
											sx={{ color: "#446a8f", letterSpacing: "0.12em" }}
										>
											Product detail
										</Typography>
										<Typography variant="h3" sx={{ fontWeight: 700 }}>
											{product().name}
										</Typography>
										<Stack spacing={0.5}>
											<Typography color="text.secondary" variant="body2">
												{product().id}
											</Typography>
											<Show when={product().parent_product_id}>
												{(parentId) => <ParentLink parentId={parentId()} />}
											</Show>
										</Stack>
									</Stack>
									<span
										title={
											product().child_product_ids.length > 0
												? "Cannot delete: this product has variants. Remove them first."
												: "Delete product"
										}
										style={{ display: "inline-flex" }}
									>
										<IconButton
											aria-label="Delete product"
											color="error"
											disabled={
												product().child_product_ids.length > 0 ||
												deleteMutation.isPending
											}
											onClick={() => {
												handleDelete(product());
											}}
											size="small"
										>
											<DeleteOutline />
										</IconButton>
									</span>
								</Box>
							)}
						</Show>
					</Show>
				</Stack>
			</Paper>

			<Show when={!productQuery.isError}>
				<Show when={product()}>
					{(p) => (
						<Paper elevation={0} sx={{ p: 3 }}>
							<Stack spacing={2}>
								<Stack
									direction={{ xs: "column", sm: "row" }}
									spacing={1}
									sx={{
										alignItems: { xs: "flex-start", sm: "center" },
										justifyContent: "space-between",
									}}
								>
									<Typography variant="h6" sx={{ fontWeight: 600 }}>
										Variants
									</Typography>
									<Typography color="text.secondary" variant="body2">
										{p().child_product_ids.length} variant
										{p().child_product_ids.length === 1 ? "" : "s"}
									</Typography>
								</Stack>

								<Show
									when={p().child_product_ids.length > 0}
									fallback={
										<Typography color="text.secondary">
											No variants linked to this product.
										</Typography>
									}
								>
									<Stack spacing={1}>
										<For each={p().child_product_ids}>
											{(childId) => <VariantRow id={childId} />}
										</For>
									</Stack>
								</Show>
							</Stack>
						</Paper>
					)}
				</Show>
			</Show>
		</Stack>
	);
};

export default ProductDetailPage;
