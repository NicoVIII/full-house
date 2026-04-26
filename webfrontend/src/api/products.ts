export interface Product {
    id: string;
    name: string;
    parent_product_id: string | null;
}

export interface ProductListResponse {
    data: Product[];
    total: number;
    offset: number;
    limit: number;
}

interface FetchProductsParams {
    offset: number;
    limit: number;
}

export async function fetchProducts({
    offset,
    limit,
}: FetchProductsParams): Promise<ProductListResponse> {
    const searchParams = new URLSearchParams({
        offset: String(offset),
        limit: String(limit),
    });
    const response = await fetch(`/api/v1/products?${searchParams.toString()}`);

    if (!response.ok) {
        throw new Error(`Products request failed with status ${String(response.status)}`);
    }

    return (await response.json()) as ProductListResponse;
}
