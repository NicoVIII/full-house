import { ServiceClient } from "skir-client";

export type ListResponse<T> = Readonly<{
	data: T[];
	limit: number;
	offset: number;
	total: number;
}>;

export const skirServiceClient = new ServiceClient(globalThis.location.origin + "/api/skir");
