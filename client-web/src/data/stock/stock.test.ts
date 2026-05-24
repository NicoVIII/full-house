import { beforeEach, describe, expect, it, vi } from "vitest";

import { fetchStock } from "./list/request";
import { removeStockItem } from "./remove/request";

const { invokeRemoteMock } = vi.hoisted(() => ({
	invokeRemoteMock: vi.fn(),
}));

vi.mock("../api_helper", () => ({
	skirServiceClient: {
		invokeRemote: invokeRemoteMock,
	},
}));

describe("fetchStock", () => {
	beforeEach(() => {
		vi.clearAllMocks();
	});

	it("fetches stock summaries with correct offset and limit", async () => {
		const mockRpcResponse = {
			data: [
				{
					productId: "1",
					productName: "Espresso",
					bestBeforeDate: "2026-10-15",
					quantity: 4,
				},
			],
			total: 1,
			offset: 0,
			limit: 10,
		};

		invokeRemoteMock.mockResolvedValue(mockRpcResponse);

		const result = await fetchStock({ offset: 0, limit: 10 });

		expect(result).toEqual({
			data: [
				{
					product_id: "1",
					product_name: "Espresso",
					best_before_date: "2026-10-15",
					quantity: 4,
				},
			],
			total: 1,
			offset: 0,
			limit: 10,
		});
		expect(invokeRemoteMock).toHaveBeenCalledTimes(1);
		expect(invokeRemoteMock).toHaveBeenCalledWith(
			expect.objectContaining({ name: "ListStockItems" }),
			expect.objectContaining({ offset: 0, limit: 10 }),
		);
	});

	it("throws error on failed stock response", async () => {
		invokeRemoteMock.mockRejectedValue(new Error("stock rpc failed"));

		await expect(fetchStock({ offset: 0, limit: 10 })).rejects.toThrow("stock rpc failed");
	});
});

describe("removeStockItem", () => {
	beforeEach(() => {
		vi.clearAllMocks();
	});

	it("removes one stock item and maps updated quantity", async () => {
		invokeRemoteMock.mockResolvedValue({
			productId: "1",
			bestBeforeDate: "2026-10-15",
			quantity: 3,
		});

		const result = await removeStockItem({
			product_id: "1",
			best_before_date: "2026-10-15",
		});

		expect(result).toEqual({
			product_id: "1",
			best_before_date: "2026-10-15",
			quantity: 3,
		});
		expect(invokeRemoteMock).toHaveBeenCalledTimes(1);
		expect(invokeRemoteMock).toHaveBeenCalledWith(
			expect.objectContaining({ name: "RemoveStockItem" }),
			expect.objectContaining({
				productId: "1",
				bestBeforeDate: "2026-10-15",
			}),
		);
	});

	it("throws error when remove stock request fails", async () => {
		invokeRemoteMock.mockRejectedValue(new Error("remove rpc failed"));

		await expect(
			removeStockItem({
				product_id: "1",
				best_before_date: "2026-10-15",
			}),
		).rejects.toThrow("remove rpc failed");
	});
});
