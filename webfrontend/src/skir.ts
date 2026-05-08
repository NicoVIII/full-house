import { Serializer } from "skir-client";

export type WireFormat = "binary" | "dense" | "readable";

const wireFormat: WireFormat = (() => {
	switch (import.meta.env.VITE_WIRE_FORMAT) {
		case "readable":
			return "readable";
		case "dense":
			return "dense";
		case "binary":
			return "binary";
		default:
			return "dense";
	}
})();

const readableJsonMime = "application/json";
const denseJsonMime = "application/vnd.skir.dense+json";
const binaryMime = "application/vnd.skir.binary";

export function buildHeader(): [string, string][] {
	switch (wireFormat) {
		case "readable":
			return [
				["content-type", readableJsonMime],
				["accept", readableJsonMime],
			];
		case "dense":
			return [
				["content-type", denseJsonMime],
				["accept", denseJsonMime],
			];
		case "binary":
			return [
				["content-type", binaryMime],
				["accept", binaryMime],
			];
	}
}

export function encode<T>(serializer: Readonly<Serializer<T>>, value: T) {
	switch (wireFormat) {
		case "readable":
			return serializer.toJsonCode(value, "readable");
		case "dense":
			return serializer.toJsonCode(value, "dense");
		case "binary":
			return serializer.toBytes(value).toBuffer();
	}
}

export async function decode<T>(
	response: Response,
	serializer: Readonly<Serializer<T>>,
): Promise<T> {
	switch (wireFormat) {
		case "readable":
		case "dense":
			return serializer.fromJsonCode(await response.text());
		case "binary":
			return serializer.fromBytes(await response.arrayBuffer());
	}
}
