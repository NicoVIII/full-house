declare const _brand: unique symbol;

export type Branded<Type, Brand extends string> = Type & Readonly<{ [_brand]: Brand }>;
export type Unbranded<BrandedType> = Omit<BrandedType, typeof _brand>;

export function newBranded<TBranded>(value: Unbranded<TBranded>): TBranded {
	return value as TBranded;
}
