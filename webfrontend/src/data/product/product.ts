declare const _brand: unique symbol;

export type ProductId = string & Readonly<{ [_brand]: "ProductId" }>;

export const ProductId = (id: string): ProductId => id as ProductId;

export type Product = Readonly<{
	id: ProductId;
	name: string;
	parent_product_id: ProductId | undefined;
	child_product_ids: ProductId[];
	[_brand]: "Product";
}>;

export const Product = (data: Omit<Product, typeof _brand>): Product =>
	data as Product;
