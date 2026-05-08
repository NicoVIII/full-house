import {
	QueryKey,
	SolidMutationOptions,
	UndefinedInitialDataOptions,
} from "@tanstack/solid-query";

export type QueryOptions<TData, TQueryKey extends QueryKey> = Readonly<
	Omit<
		ReturnType<UndefinedInitialDataOptions<TData, Error, TData, TQueryKey>>,
		"queryKey" | "queryFn"
	>
>;

export type MutationOptions<TData, TVariables> = Readonly<
	Omit<
		SolidMutationOptions<TData, Error, TVariables>,
		"mutationKey" | "mutationFn"
	>
>;
