import Paper from "@suid/material/Paper";
import Stack from "@suid/material/Stack";
import Typography from "@suid/material/Typography";
import type { Component } from "solid-js";
import { For, Show } from "solid-js";

import type { Product } from "../../../data/product/product";
import VariantRow from "./VariantRow";

type VariantSectionProps = Readonly<{
	product: Product;
}>;

const VariantSection: Component<VariantSectionProps> = (props) => {
	return (
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
						{props.product.child_product_ids.length} variant
						{props.product.child_product_ids.length === 1 ? "" : "s"}
					</Typography>
				</Stack>

				<Show
					when={props.product.child_product_ids.length > 0}
					fallback={
						<Typography color="text.secondary">No variants linked to this product.</Typography>
					}
				>
					<Stack spacing={1}>
						<For each={props.product.child_product_ids}>
							{(childId) => <VariantRow id={childId} />}
						</For>
					</Stack>
				</Show>
			</Stack>
		</Paper>
	);
};

export default VariantSection;
