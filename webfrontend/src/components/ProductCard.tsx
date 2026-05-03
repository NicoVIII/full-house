import { A } from "@solidjs/router";
import Box from "@suid/material/Box";
import Card from "@suid/material/Card";
import CardContent from "@suid/material/CardContent";
import Chip from "@suid/material/Chip";
import Stack from "@suid/material/Stack";
import Typography from "@suid/material/Typography";
import type { Component } from "solid-js";
import { Show } from "solid-js";
import type { Product } from "../api/products";

type ProductCardProps = Readonly<{
	product: Product;
	parentProduct?: Product | undefined;
}>;

const ProductCard: Component<ProductCardProps> = (props) => {
	const childCount = () => props.product.child_product_ids.length;

	return (
		<Card
			class="product-card"
			elevation={0}
			sx={{ display: "flex", flexDirection: "column" }}
		>
			<CardContent
				sx={{ display: "flex", flexDirection: "column", flexGrow: 1, gap: 2 }}
			>
				<Typography variant="h5" component="h2" sx={{ fontWeight: 600 }}>
					<A
						class="product-card-title-link"
						href={`/products/${props.product.id}`}
					>
						{props.product.name}
					</A>
				</Typography>

				{/* Relationships section — consistent height placeholder */}
				<Box class="product-card-relationships">
					<Show
						when={props.product.parent_product_id !== null || childCount() > 0}
					>
						<Stack spacing={0.75}>
							<Show when={props.product.parent_product_id}>
								{(parentProductId) => (
									<A
										class="product-inline-link"
										href={`/products/${parentProductId()}`}
									>
										<Chip
											size="small"
											color="primary"
											label={`Parent: ${props.parentProduct?.name ?? parentProductId()}`}
											variant="outlined"
											sx={{ alignSelf: "flex-start" }}
										/>
									</A>
								)}
							</Show>
							<Show when={childCount() > 0}>
								<Chip
									size="small"
									label={`${String(childCount())} variant${childCount() !== 1 ? "s" : ""}`}
									variant="filled"
									sx={{
										alignSelf: "flex-start",
										backgroundColor: "rgba(68, 106, 143, 0.1)",
										color: "#446a8f",
									}}
								/>
							</Show>
						</Stack>
					</Show>
				</Box>
			</CardContent>
		</Card>
	);
};

export default ProductCard;
