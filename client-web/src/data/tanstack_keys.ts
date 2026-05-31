import type { ProductId } from "./product/product";

export const tanstackQueryKeys = {
	product: {
		byId: (id: ProductId) => ["product", id] as const,
		byBarcode: (barcode: string) => ["productByBarcode", barcode] as const,
		listInfinite: () => ["products", "infinite"] as const,
	},
	stock: {
		all: () => ["stock"] as const,
		listInfinite: () => ["stock", "infinite"] as const,
	},
} as const;

export const tanstackMutationKeys = {
	product: {
		create: () => ["createProduct"] as const,
		delete: (id: ProductId) => ["deleteProduct", id] as const,
		updateBarcodes: () => ["updateProductBarcodes"] as const,
		lookupByBarcode: () => ["lookupProductByBarcode"] as const,
	},
	stock: {
		create: () => ["createStockItem"] as const,
		remove: () => ["removeStockItem"] as const,
	},
} as const;
