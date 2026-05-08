import { A } from "@solidjs/router";
import Typography from "@suid/material/Typography";
import { useQuery } from "@tanstack/solid-query";
import type { Component } from "solid-js";
import { productQueryOptions } from "../../../data/product/get/query";
import { ProductId } from "../../../data/product/product";
import { routes } from "../../../routes";

export type Props = Readonly<{
	parentId: ProductId;
}>;

const ParentLink: Component<Props> = (props) => {
	const parentQuery = useQuery(() => productQueryOptions(props.parentId));
	return (
		<Typography variant="body2" color="text.secondary">
			Parent:{" "}
			<A
				class="product-inline-link product-inline-link-strong"
				href={routes.catalog.subs.detail.build(props.parentId)}
			>
				{parentQuery.data?.name ?? props.parentId}
			</A>
		</Typography>
	);
};

export default ParentLink;
