export async function readApiErrorMessage(
	response: Response,
	fallback: string,
): Promise<string> {
	try {
		const payload = (await response.json()) as { message?: unknown };
		return typeof payload.message === "string" ? payload.message : fallback;
	} catch {
		return fallback;
	}
}

export type ListResponse<T> = Readonly<{
	data: T[];
	limit: number;
	offset: number;
	total: number;
}>;
