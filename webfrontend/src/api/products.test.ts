import { describe, it, expect, beforeEach, vi } from 'vitest';
import { fetchProducts } from '../api/products';

describe('fetchProducts', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    it('fetches products with correct offset and limit', async () => {
        const mockResponse = {
            data: [{ id: '1', name: 'Product 1', parent_product_id: null }],
            total: 1,
            offset: 0,
            limit: 10,
        };

        global.fetch = vi.fn(() =>
            Promise.resolve({
                ok: true,
                json: () => Promise.resolve(mockResponse),
            } as Response),
        );

        const result = await fetchProducts({ offset: 0, limit: 10 });

        expect(result).toEqual(mockResponse);
        expect(global.fetch).toHaveBeenCalledWith('/api/v1/products?offset=0&limit=10');
    });

    it('throws error on failed response', async () => {
        global.fetch = vi.fn(() =>
            Promise.resolve({
                ok: false,
                status: 500,
            } as Response),
        );

        await expect(fetchProducts({ offset: 0, limit: 10 })).rejects.toThrow(
            'Products request failed with status 500',
        );
    });

    it('constructs query string with correct offset and limit values', async () => {
        const mockResponse = {
            data: [],
            total: 0,
            offset: 20,
            limit: 5,
        };

        global.fetch = vi.fn(() =>
            Promise.resolve({
                ok: true,
                json: () => Promise.resolve(mockResponse),
            } as Response),
        );

        await fetchProducts({ offset: 20, limit: 5 });

        expect(global.fetch).toHaveBeenCalledWith('/api/v1/products?offset=20&limit=5');
    });
});
