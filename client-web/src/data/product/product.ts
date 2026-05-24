import { Branded, newBranded } from "../brand";

export type ProductId = Branded<string, "ProductId">;

export const ProductId = newBranded<ProductId>;

export type Product = Branded<
	Readonly<{
		id: ProductId;
		name: string;
		parent_product_id: ProductId | undefined;
		child_product_ids: ProductId[];
	}>,
	"Product"
>;

export const Product = newBranded<Product>;
