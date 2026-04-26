export type Product = {
    id: string;
    name: string;
    parent_product_id: string | null;
};

export type ProductListResponse = {
    data: Product[];
    total: number;
    offset: number;
    limit: number;
};

type FetchProductsParams = {
    offset: number;
    limit: number;
};

export async function fetchProducts({
    offset,
    limit,
}: FetchProductsParams): Promise<ProductListResponse> {
    const response = await fetch(`/api/v1/products?offset=${offset}&limit=${limit}`);

    if (!response.ok) {
        throw new Error(`Products request failed with status ${response.status}`);
    }

    return (await response.json()) as ProductListResponse;
}
