import { A, useNavigate, useParams } from "@solidjs/router";
import DeleteOutline from "@suid/icons-material/DeleteOutline";
import Alert from "@suid/material/Alert";
import Box from "@suid/material/Box";
import CircularProgress from "@suid/material/CircularProgress";
import IconButton from "@suid/material/IconButton";
import Paper from "@suid/material/Paper";
import Stack from "@suid/material/Stack";
import Typography from "@suid/material/Typography";
import { createQuery, useQueryClient } from "@tanstack/solid-query";
import type { Component } from "solid-js";
import { createEffect, createMemo, createSignal, For, Show } from "solid-js";
import {
	deleteProduct,
	fetchProduct,
	type Product,
	type ProductResponse,
} from "../../../api/products";
import { routes } from "../../../routes";

const ProductDetailPage: Component = () => {
	const params = useParams();
	const navigate = useNavigate();
	const queryClient = useQueryClient();
	const productIdFromRoute = createMemo(() => params.productId ?? "");
	const [isDeleting, setIsDeleting] = createSignal(false);

	// Main product query
	const productQuery = createQuery<ProductResponse>(() => ({
		enabled: productIdFromRoute() !== "",
		queryFn: () => fetchProduct(productIdFromRoute()),
		queryKey: ["products", "detail", productIdFromRoute()] as const,
		staleTime: 1000 * 60 * 60,
	}));

	const currentProduct = createMemo(() => productQuery.data?.data);

	const parentProductId = createMemo(
		() => currentProduct()?.parent_product_id ?? null,
	);

	// Parent product query — only for resolving the display name
	const parentQuery = createQuery<ProductResponse>(() => ({
		enabled: parentProductId() !== null,
		queryFn: async () => {
			const nextParentProductId = parentProductId();

			if (nextParentProductId === null) {
				throw new Error("Parent product id is missing");
			}

			return fetchProduct(nextParentProductId);
		},
		queryKey: ["products", "detail", parentProductId() ?? ""] as const,
		staleTime: 1000 * 60 * 60,
	}));

	// Hydrate cache with loaded products
	createEffect(() => {
		const product = currentProduct();
		if (product === undefined) {
			return;
		}

		queryClient.setQueryData(["products", "detail", product.id], {
			data: product,
		});
	});

	// Child product queries — one per child id
	const childQueries = createMemo(() => {
		const product = currentProduct();
		if (!product) {
			return [];
		}

		return product.child_product_ids.map((childId) =>
			createQuery<ProductResponse>(() => ({
				enabled: childId !== "",
				queryFn: () => fetchProduct(childId),
				queryKey: ["products", "detail", childId] as const,
				staleTime: 1000 * 60 * 60,
			})),
		);
	});

	const children = createMemo(() =>
		childQueries()
			.map((q) => q.data?.data)
			.filter((c): c is Product => c !== undefined),
	);

	const childrenAreLoading = createMemo(() =>
		childQueries().some((q) => q.isPending),
	);
	const childrenError = createMemo(
		() => childQueries().find((q) => q.isError)?.error ?? null,
	);

	const hasChildren = createMemo(
		() => (currentProduct()?.child_product_ids.length ?? 0) > 0,
	);

	const handleDelete = async () => {
		const product = currentProduct();
		if (!product) {
			return;
		}

		const confirmed = window.confirm(`Delete product "${product.name}"?`);
		if (!confirmed) {
			return;
		}

		setIsDeleting(true);
		try {
			await deleteProduct(product.id);
			await queryClient.invalidateQueries({
				queryKey: ["products", "infinite"],
			});
			navigate(routes.catalog.build());
		} catch (error) {
			console.error("Delete failed:", error);
		} finally {
			setIsDeleting(false);
		}
	};

	return (
		<Stack spacing={3}>
			<Paper class="hero-panel" elevation={0}>
				<Stack spacing={2}>
					<A class="product-inline-link" href={routes.catalog.build()}>
						Back to catalog
					</A>
					<Show
						when={productIdFromRoute() !== ""}
						fallback={
							<Alert severity="error">Product id is missing in route.</Alert>
						}
					>
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
								when={currentProduct() !== undefined}
								fallback={
									<Stack spacing={2} sx={{ alignItems: "center", py: 4 }}>
										<CircularProgress />
										<Typography>Loading product...</Typography>
									</Stack>
								}
							>
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
											{currentProduct()?.name}
										</Typography>
										<Stack spacing={0.5}>
											<Typography color="text.secondary" variant="body2">
												{currentProduct()?.id}
											</Typography>
											<Show when={parentProductId()}>
												{(parentProductId) => (
													<Typography variant="body2" color="text.secondary">
														Parent:{" "}
														<A
															class="product-inline-link product-inline-link-strong"
															href={`/products/${parentProductId()}`}
														>
															{parentQuery.data?.data.name ?? parentProductId()}
														</A>
													</Typography>
												)}
											</Show>
										</Stack>
									</Stack>
									<span
										title={
											hasChildren()
												? "Cannot delete: this product has variants. Remove them first."
												: "Delete product"
										}
										style={{ display: "inline-flex" }}
									>
										<IconButton
											aria-label="Delete product"
											color="error"
											disabled={hasChildren() || isDeleting()}
											onClick={() => void handleDelete()}
											size="small"
										>
											<DeleteOutline />
										</IconButton>
									</span>
								</Box>
							</Show>
						</Show>
					</Show>
				</Stack>
			</Paper>

			<Show when={currentProduct() !== undefined && !productQuery.isError}>
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
								{currentProduct()?.child_product_ids.length ?? 0} variant
								{(currentProduct()?.child_product_ids.length ?? 0) === 1
									? ""
									: "s"}
							</Typography>
						</Stack>

						<Show
							when={childrenError() === null}
							fallback={
								<Alert severity="error">
									{childrenError()?.message ?? "Failed to load variants."}
								</Alert>
							}
						>
							<Show
								when={!childrenAreLoading()}
								fallback={
									<Stack spacing={2} sx={{ alignItems: "center", py: 3 }}>
										<CircularProgress size={28} />
										<Typography>Loading variants...</Typography>
									</Stack>
								}
							>
								<Show
									when={children().length > 0}
									fallback={
										<Typography color="text.secondary">
											No variants linked to this product.
										</Typography>
									}
								>
									<Stack spacing={1}>
										<For each={children()}>
											{(child) => (
												<Box class="product-detail-child-row">
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
																href={routes.catalog.subs.detail.build(
																	child.id,
																)}
															>
																{child.name}
															</A>
															<Typography
																color="text.secondary"
																variant="body2"
															>
																{child.id}
															</Typography>
														</Stack>
													</Stack>
												</Box>
											)}
										</For>
									</Stack>
								</Show>
							</Show>
						</Show>
					</Stack>
				</Paper>
			</Show>
		</Stack>
	);
};

export default ProductDetailPage;
