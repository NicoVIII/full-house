import { mutationOptions } from "@tanstack/solid-query";
import { MutationOptions } from "../../tanstack_helper";
import { Product } from "../product";
import { createProduct, Request } from "./request";

export const createProductMutationOptions = (
	options?: MutationOptions<Product, Request>,
) =>
	mutationOptions({
		mutationKey: ["createProduct"],
		mutationFn: createProduct,
		...options,
	});
