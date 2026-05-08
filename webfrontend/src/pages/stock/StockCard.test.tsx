import { render } from "solid-js/web";
import { describe, expect, it } from "vitest";
import { StockSummary } from "../../data/stock/stock";
import StockCard from "./StockCard";

describe("StockCard", () => {
	const mockStock: StockSummary = {
		product_id: "123",
		product_name: "Espresso",
		quantity: 4,
	};

	it("renders the product name", () => {
		const container = document.createElement("div");
		render(() => <StockCard stock={mockStock} />, container);

		expect(container.textContent).toContain("Espresso");
	});

	it("renders the stock quantity", () => {
		const container = document.createElement("div");
		render(() => <StockCard stock={mockStock} />, container);

		expect(container.textContent).toContain("In stock: 4");
	});
});
