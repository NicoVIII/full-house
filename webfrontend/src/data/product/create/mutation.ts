import { mutationOptions } from "@tanstack/solid-query";
import { MutationOptions } from "../../tanstack_helper";
import { Product } from "../product";
import { CreateProductRequest, createProduct } from "./request";

export const createProductMutationOptions = (
	options?: MutationOptions<Product, CreateProductRequest>,
) =>
	mutationOptions({
		mutationKey: ["createProduct"],
		mutationFn: createProduct,
		...options,
	});
