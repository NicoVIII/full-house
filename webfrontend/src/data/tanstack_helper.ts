import {
	QueryKey,
	SolidMutationOptions,
	UndefinedInitialDataOptions,
} from "@tanstack/solid-query";

export type QueryOptions<TData, TQueryKey extends QueryKey> = Omit<
	ReturnType<UndefinedInitialDataOptions<TData, Error, TData, TQueryKey>>,
	"queryKey" | "queryFn"
>;

export type MutationOptions<TData, TVariables> = Omit<
	SolidMutationOptions<TData, Error, TVariables>,
	"mutationKey" | "mutationFn"
>;
