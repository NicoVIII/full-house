import { Route, Router } from "@solidjs/router";
import { render } from "solid-js/web";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { Product, ProductId } from "../../data/product/product";
import ProductCard from "./ProductCard";

describe("ProductCard", () => {
	const mockProduct = Product({
		id: ProductId("123"),
		name: "Test Product",
		parent_product_id: undefined,
		child_product_ids: [],
	});

	beforeEach(() => {
		vi.clearAllMocks();
	});

	const renderCard = (product: Product = mockProduct) => {
		const container = document.createElement("div");
		render(
			() => (
				<Router>
					<Route path="/" component={() => <ProductCard product={product} />} />
				</Router>
			),
			container,
		);

		return container;
	};

	it("renders product name", () => {
		const container = renderCard();

		expect(container.textContent).toContain("Test Product");
	});

	it("renders parent product chip when parent_product_id exists", () => {
		const productWithParent: Product = {
			...mockProduct,
			parent_product_id: ProductId("parent-123"),
		};

		const container = renderCard(productWithParent);

		expect(container.textContent).toContain("Parent: parent-123");
	});

	it("does not render parent product chip when parent_product_id is null", () => {
		const container = renderCard();

		expect(container.textContent).not.toContain("Parent:");
	});

	it("renders with product-card class", () => {
		const container = renderCard();

		const card = container.querySelector(".product-card");
		expect(card).toBeTruthy();
	});

	it("does not render a delete button", () => {
		const container = renderCard();

		const deleteButton = container.querySelector("button");
		expect(deleteButton).toBeFalsy();
	});

	it("links the product title to the product detail page", () => {
		const container = renderCard();

		const titleLink = container.querySelector("a.product-card-title-link");
		expect(titleLink?.getAttribute("href")).toBe("/catalog/123");
	});

	it("links the parent chip to the parent detail page", () => {
		const productWithParent: Product = {
			...mockProduct,
			parent_product_id: ProductId("parent-123"),
		};

		const container = renderCard(productWithParent);

		const parentLink = container.querySelector("a.product-inline-link");
		expect(parentLink?.getAttribute("href")).toBe("/catalog/parent-123");
	});

	it("shows variant count chip when product has children", () => {
		const productWithChildren: Product = {
			...mockProduct,
			child_product_ids: [ProductId("child-1"), ProductId("child-2")],
		};

		const container = renderCard(productWithChildren);

		expect(container.textContent).toContain("2 variants");
	});
});
