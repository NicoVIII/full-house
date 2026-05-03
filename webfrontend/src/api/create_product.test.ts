import { beforeEach, describe, expect, it, vi } from "vitest";
import { createProduct } from "../api/products";

describe("createProduct", () => {
	beforeEach(() => {
		vi.clearAllMocks();
	});

	it("posts to /api/v1/products and returns created product", async () => {
		const mockResponse = {
			data: { id: "abc-123", name: "Espresso", parent_product_id: null },
		};

		// eslint-disable-next-line functional/immutable-data
		global.fetch = vi.fn(() =>
			Promise.resolve({
				ok: true,
				json: () => Promise.resolve(mockResponse),
			} as Response),
		);

		const result = await createProduct({ name: "Espresso" });

		expect(result).toEqual(mockResponse);
		expect(global.fetch).toHaveBeenCalledWith(
			"/api/v1/products",
			expect.objectContaining({
				method: "POST",
				headers: { "content-type": "application/json" },
				body: JSON.stringify({ name: "Espresso", parent_product_id: null }),
			}),
		);
	});

	it("sends parent_product_id when provided", async () => {
		const mockResponse = {
			data: {
				id: "abc-123",
				name: "Oat Latte",
				parent_product_id: "parent-uuid-456",
			},
		};

		// eslint-disable-next-line functional/immutable-data
		global.fetch = vi.fn(() =>
			Promise.resolve({
				ok: true,
				json: () => Promise.resolve(mockResponse),
			} as Response),
		);

		await createProduct({
			name: "Oat Latte",
			parent_product_id: "parent-uuid-456",
		});

		expect(global.fetch).toHaveBeenCalledWith(
			"/api/v1/products",
			expect.objectContaining({
				body: JSON.stringify({
					name: "Oat Latte",
					parent_product_id: "parent-uuid-456",
				}),
			}),
		);
	});

	it("throws error message from backend on 400", async () => {
		// eslint-disable-next-line functional/immutable-data
		global.fetch = vi.fn(() =>
			Promise.resolve({
				ok: false,
				status: 400,
				json: () =>
					Promise.resolve({
						error: "invalid_parameter",
						message: "name must not be empty",
					}),
			} as Response),
		);

		await expect(createProduct({ name: "" })).rejects.toThrow(
			"name must not be empty",
		);
	});

	it("throws generic message on 500 when response body is not parseable", async () => {
		// eslint-disable-next-line functional/immutable-data
		global.fetch = vi.fn(() =>
			Promise.resolve({
				ok: false,
				status: 500,
				json: () => Promise.reject(new Error("parse failure")),
			} as Response),
		);

		await expect(createProduct({ name: "Test" })).rejects.toThrow(
			"Create product request failed with status 500",
		);
	});
});
