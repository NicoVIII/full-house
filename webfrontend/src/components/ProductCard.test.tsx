import { describe, it, expect } from 'vitest';
import { render } from 'solid-js/web';
import ProductCard from './ProductCard';
import type { Product } from '../api/products';

describe('ProductCard', () => {
    const mockProduct: Product = {
        id: '123',
        name: 'Test Product',
        parent_product_id: null,
    };

    it('renders product name', () => {
        const container = document.createElement('div');
        render(() => <ProductCard product={mockProduct} />, container);

        expect(container.textContent).toContain('Test Product');
    });

    it('renders parent product chip when parent_product_id exists', () => {
        const productWithParent: Product = {
            ...mockProduct,
            parent_product_id: 'parent-123',
        };

        const container = document.createElement('div');
        render(() => <ProductCard product={productWithParent} />, container);

        expect(container.textContent).toContain('Parent: parent-123');
    });

    it('does not render parent product chip when parent_product_id is null', () => {
        const container = document.createElement('div');
        render(() => <ProductCard product={mockProduct} />, container);

        expect(container.textContent).not.toContain('Parent:');
    });

    it('renders with product-card class', () => {
        const container = document.createElement('div');
        render(() => <ProductCard product={mockProduct} />, container);

        const card = container.querySelector('.product-card');
        expect(card).toBeTruthy();
    });
});
