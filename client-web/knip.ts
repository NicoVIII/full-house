import type { KnipConfig } from "knip";

const config: KnipConfig = {
	project: ["src/**/*.{ts,tsx}"],
	ignoreFiles: ["src/data/product/get_by_barcode/query.ts"],
};

export default config;
