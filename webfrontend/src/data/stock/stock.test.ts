import { beforeEach, describe, expect, it, vi } from "vitest";
import { fetchStock } from "./stock";

describe("fetchStock", () => {
	beforeEach(() => {
		vi.clearAllMocks();
	});

	it("fetches stock summaries with correct offset and limit", async () => {
		const mockResponse = {
			data: [{ product_id: "1", product_name: "Espresso", quantity: 4 }],
			total: 1,
			offset: 0,
			limit: 10,
		};

		// eslint-disable-next-line functional/immutable-data
		global.fetch = vi.fn(() =>
			Promise.resolve({
				ok: true,
				text: () => Promise.resolve(JSON.stringify(mockResponse)),
			} as Response),
		);

		const result = await fetchStock({ offset: 0, limit: 10 });

		expect(result).toEqual(mockResponse);
		expect(global.fetch).toHaveBeenCalledWith(
			"/api/v1/stock_items?offset=0&limit=10",
		);
	});

	it("throws error on failed stock response", async () => {
		// eslint-disable-next-line functional/immutable-data
		global.fetch = vi.fn(() =>
			Promise.resolve({
				ok: false,
				status: 500,
			} as Response),
		);

		await expect(fetchStock({ offset: 0, limit: 10 })).rejects.toThrow(
			"Stock request failed with status 500",
		);
	});
});
