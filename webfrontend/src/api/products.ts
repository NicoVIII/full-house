export type Product = Readonly<{
    id: string;
    name: string;
    parent_product_id: string | null;
}>;

export type ProductListResponse = Readonly<{
    data: Product[];
    total: number;
    offset: number;
    limit: number;
}>;

type FetchProductsParams = Readonly<{
    offset: number;
    limit: number;
}>;

export type CreateProductRequest = Readonly<{
    name: string;
    parent_product_id?: string | null;
}>;

export type CreateProductResponse = Readonly<{
    data: Product;
}>;

export async function deleteProduct(productId: string): Promise<void> {
    const response = await fetch(`/api/v1/products/${productId}`, {
        method: 'DELETE',
    });

    if (!response.ok) {
        const defaultMessage = `Delete product request failed with status ${String(response.status)}`;
        throw new Error(await readApiErrorMessage(response, defaultMessage));
    }
}

async function readApiErrorMessage(
    response: Response,
    fallback: string,
): Promise<string> {
    try {
        const payload = (await response.json()) as { message?: unknown };
        return typeof payload.message === 'string' ? payload.message : fallback;
    } catch {
        return fallback;
    }
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

export async function createProduct({
    name,
    parent_product_id,
}: CreateProductRequest): Promise<CreateProductResponse> {
    const response = await fetch('/api/v1/products', {
        method: 'POST',
        headers: {
            'content-type': 'application/json',
        },
        body: JSON.stringify({
            name,
            parent_product_id: parent_product_id ?? null,
        }),
    });

    if (!response.ok) {
        const defaultMessage = `Create product request failed with status ${String(response.status)}`;
        throw new Error(await readApiErrorMessage(response, defaultMessage));
    }

    return (await response.json()) as CreateProductResponse;
}
