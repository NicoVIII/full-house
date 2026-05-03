import { beforeEach, describe, expect, it, vi } from "vitest";
import {
	createProduct,
	deleteProduct,
	fetchProduct,
	fetchProducts,
} from "../api/products";

describe("fetchProducts", () => {
	beforeEach(() => {
		vi.clearAllMocks();
	});

	it("fetches products with correct offset and limit", async () => {
		const mockResponse = {
			data: [
				{
					id: "1",
					name: "Product 1",
					parent_product_id: null,
					child_product_ids: [],
				},
			],
			total: 1,
			offset: 0,
			limit: 10,
		};

		// eslint-disable-next-line functional/immutable-data
		global.fetch = vi.fn(() =>
			Promise.resolve({
				ok: true,
				json: () => Promise.resolve(mockResponse),
			} as Response),
		);

		const result = await fetchProducts({ offset: 0, limit: 10 });

		expect(result).toEqual(mockResponse);
		expect(global.fetch).toHaveBeenCalledWith(
			"/api/v1/products?offset=0&limit=10",
		);
	});

	it("throws error on failed response", async () => {
		// eslint-disable-next-line functional/immutable-data
		global.fetch = vi.fn(() =>
			Promise.resolve({
				ok: false,
				status: 500,
			} as Response),
		);

		await expect(fetchProducts({ offset: 0, limit: 10 })).rejects.toThrow(
			"Products request failed with status 500",
		);
	});

	it("constructs query string with correct offset and limit values", async () => {
		const mockResponse = {
			data: [],
			total: 0,
			offset: 20,
			limit: 5,
		};

		// eslint-disable-next-line functional/immutable-data
		global.fetch = vi.fn(() =>
			Promise.resolve({
				ok: true,
				json: () => Promise.resolve(mockResponse),
			} as Response),
		);

		await fetchProducts({ offset: 20, limit: 5 });

		expect(global.fetch).toHaveBeenCalledWith(
			"/api/v1/products?offset=20&limit=5",
		);
	});

	it("includes parent_product_id filter when provided", async () => {
		const mockResponse = {
			data: [
				{
					id: "2",
					name: "Child Product",
					parent_product_id: "parent-1",
					child_product_ids: [],
				},
			],
			total: 1,
			offset: 0,
			limit: 10,
		};

		// eslint-disable-next-line functional/immutable-data
		global.fetch = vi.fn(() =>
			Promise.resolve({
				ok: true,
				json: () => Promise.resolve(mockResponse),
			} as Response),
		);

		await fetchProducts({
			offset: 0,
			limit: 10,
			parent_product_id: "parent-1",
		});

		expect(global.fetch).toHaveBeenCalledWith(
			"/api/v1/products?offset=0&limit=10&parent_product_id=parent-1",
		);
	});
});

describe("fetchProduct", () => {
	beforeEach(() => {
		vi.clearAllMocks();
	});

	it("fetches a single product by id", async () => {
		const mockResponse = {
			data: {
				id: "1",
				name: "Latte",
				parent_product_id: null,
				child_product_ids: [],
			},
		};

		// eslint-disable-next-line functional/immutable-data
		global.fetch = vi.fn(() =>
			Promise.resolve({
				ok: true,
				json: () => Promise.resolve(mockResponse),
			} as Response),
		);

		const result = await fetchProduct("1");

		expect(result).toEqual(mockResponse);
		expect(global.fetch).toHaveBeenCalledWith("/api/v1/products/1");
	});

	it("surfaces backend detail error messages", async () => {
		// eslint-disable-next-line functional/immutable-data
		global.fetch = vi.fn(() =>
			Promise.resolve({
				ok: false,
				status: 404,
				json: () => Promise.resolve({ message: "product not found" }),
			} as Response),
		);

		await expect(fetchProduct("missing")).rejects.toThrow("product not found");
	});
});

describe("createProduct", () => {
	beforeEach(() => {
		vi.clearAllMocks();
	});

	it("creates a product with optional parent_product_id", async () => {
		const mockResponse = {
			data: {
				id: "1",
				name: "Pour Over",
				parent_product_id: null,
				child_product_ids: [],
			},
		};

		// eslint-disable-next-line functional/immutable-data
		global.fetch = vi.fn(() =>
			Promise.resolve({
				ok: true,
				json: () => Promise.resolve(mockResponse),
			} as Response),
		);

		const result = await createProduct({
			name: "Pour Over",
			parent_product_id: null,
		});

		expect(result).toEqual(mockResponse);
		expect(global.fetch).toHaveBeenCalledWith("/api/v1/products", {
			method: "POST",
			headers: {
				"content-type": "application/json",
			},
			body: JSON.stringify({
				name: "Pour Over",
				parent_product_id: null,
			}),
		});
	});

	it("surfaces backend validation message", async () => {
		// eslint-disable-next-line functional/immutable-data
		global.fetch = vi.fn(() =>
			Promise.resolve({
				ok: false,
				status: 400,
				json: () => Promise.resolve({ message: "name must not be empty" }),
			} as Response),
		);

		await expect(
			createProduct({ name: " ", parent_product_id: null }),
		).rejects.toThrow("name must not be empty");
	});
});

describe("deleteProduct", () => {
	beforeEach(() => {
		vi.clearAllMocks();
	});

	it("sends DELETE request with correct product id", async () => {
		// eslint-disable-next-line functional/immutable-data
		global.fetch = vi.fn(() =>
			Promise.resolve({
				ok: true,
			} as Response),
		);

		await deleteProduct("test-id-123");

		expect(global.fetch).toHaveBeenCalledWith("/api/v1/products/test-id-123", {
			method: "DELETE",
		});
	});

	it("returns successfully on 204 response", async () => {
		// eslint-disable-next-line functional/immutable-data
		global.fetch = vi.fn(() =>
			Promise.resolve({
				ok: true,
				status: 204,
			} as Response),
		);

		await expect(deleteProduct("test-id")).resolves.not.toThrow();
	});

	it("throws error on 409 conflict (stock items)", async () => {
		// eslint-disable-next-line functional/immutable-data
		global.fetch = vi.fn(() =>
			Promise.resolve({
				ok: false,
				status: 409,
				json: () =>
					Promise.resolve({
						message: "cannot delete product with existing stock items",
					}),
			} as Response),
		);

		await expect(deleteProduct("test-id")).rejects.toThrow(
			"cannot delete product with existing stock items",
		);
	});

	it("throws error on 404 not found", async () => {
		// eslint-disable-next-line functional/immutable-data
		global.fetch = vi.fn(() =>
			Promise.resolve({
				ok: false,
				status: 404,
				json: () => Promise.resolve({ message: "product not found" }),
			} as Response),
		);

		await expect(deleteProduct("bad-id")).rejects.toThrow("product not found");
	});

	it("uses default error message when response json fails", async () => {
		// eslint-disable-next-line functional/immutable-data
		global.fetch = vi.fn(() =>
			Promise.resolve({
				ok: false,
				status: 500,
				json: () => Promise.reject(new Error("Invalid JSON")),
			} as Response),
		);

		await expect(deleteProduct("test-id")).rejects.toThrow(
			"Delete product request failed with status 500",
		);
	});
});
