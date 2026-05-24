import { A, useNavigate, useParams } from "@solidjs/router";
import DeleteOutline from "@suid/icons-material/DeleteOutline";
import Alert from "@suid/material/Alert";
import Box from "@suid/material/Box";
import CircularProgress from "@suid/material/CircularProgress";
import IconButton from "@suid/material/IconButton";
import Paper from "@suid/material/Paper";
import Stack from "@suid/material/Stack";
import Typography from "@suid/material/Typography";
import { useMutation, useQuery, useQueryClient } from "@tanstack/solid-query";
import type { Component } from "solid-js";
import { createMemo, Show } from "solid-js";

import { deleteProductMutationOptions } from "../../../data/product/delete/mutation";
import { productQueryOptions } from "../../../data/product/get/query";
import { Product, ProductId } from "../../../data/product/product";
import { routes } from "../../../routes";
import BarcodeSection from "./BarcodeSection";
import ParentLink from "./ParentLink";
import StockSection from "./StockSection";
import VariantSection from "./VariantSection";

const usePageParams = () => {
	const params = useParams();

	// oxlint-disable-next-line typescript/no-non-null-assertion
	const productId = createMemo(() => ProductId(params.productId!));
	return { productId };
};

const ProductDetailPage: Component = () => {
	const navigate = useNavigate();
	const queryClient = useQueryClient();
	const { productId } = usePageParams();

	const productQuery = useQuery(() => productQueryOptions(productId()));
	const product = () => productQuery.data;

	const deleteMutation = useMutation(() => deleteProductMutationOptions(productId()));

	const handleStockItemCreated = () => queryClient.invalidateQueries({ queryKey: ["stock"] });
	const handleStockItemCreatedEvent = () => {
		void handleStockItemCreated();
	};

	const handleDelete = (p: Product) => {
		if (!globalThis.confirm(`Delete product "${p.name}"?`)) return;
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
											disabled={product().child_product_ids.length > 0 || deleteMutation.isPending}
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
						<>
							<BarcodeSection product={p()} />
							<VariantSection product={p()} />
							<StockSection product={p()} onStockItemCreated={handleStockItemCreatedEvent} />
						</>
					)}
				</Show>
			</Show>
		</Stack>
	);
};

export default ProductDetailPage;
