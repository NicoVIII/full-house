import { describe, it, expect } from 'vitest';
import { render } from 'solid-js/web';
import ProductsHero from './ProductsHero';

describe('ProductsHero', () => {
    it('renders hero section with title and catalog chip', () => {
        const container = document.createElement('div');
        render(() => <ProductsHero />, container);

        expect(container.textContent).toContain('Products');
        expect(container.textContent).toContain('Full House Catalog');
    });

    it('renders as a Paper component with hero-panel class', () => {
        const container = document.createElement('div');
        render(() => <ProductsHero />, container);

        const paper = container.querySelector('.hero-panel');
        expect(paper).toBeTruthy();
    });
});
