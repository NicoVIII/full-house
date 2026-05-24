import { defineConfig, type OxlintConfig } from "oxlint";

import tsStrict from "./node_modules/oxlint-config-presets/@typescript-eslint/strict-type-checked.json" with { type: "json" };
import tsStylistic from "./node_modules/oxlint-config-presets/@typescript-eslint/stylistic-type-checked.json" with { type: "json" };
import vitestRecommended from "./node_modules/oxlint-config-presets/@vitest/recommended.json" with { type: "json" };
import importRecommended from "./node_modules/oxlint-config-presets/import/recommended.json" with { type: "json" };
import importTypescript from "./node_modules/oxlint-config-presets/import/typescript.json" with { type: "json" };
import jsdocRecommendedTsdoc from "./node_modules/oxlint-config-presets/jsdoc/recommended-tsdoc.json" with { type: "json" };
import jsxA11yStrict from "./node_modules/oxlint-config-presets/jsx-a11y/strict.json" with { type: "json" };
import unicornRecommended from "./node_modules/oxlint-config-presets/unicorn/recommended.json" with { type: "json" };

export default defineConfig({
	extends: [
		tsStrict as OxlintConfig,
		tsStylistic as OxlintConfig,
		importRecommended as OxlintConfig,
		importTypescript as OxlintConfig,
		jsxA11yStrict as OxlintConfig,
		jsdocRecommendedTsdoc as OxlintConfig,
		unicornRecommended as OxlintConfig,
		vitestRecommended as OxlintConfig,
	],
	env: {
		browser: true,
	},
	ignorePatterns: ["dist/**", "node_modules/**", "build/**", "src/skirout/**"],
	plugins: ["eslint", "typescript", "import", "promise", "jsx-a11y", "vitest"],
	rules: {
		"import/no-unassigned-import": ["error", { allow: ["**/*.css"] }],
		"jsx-a11y/no-autofocus": ["error", { ignoreNonDOM: true }],
		"unicorn/filename-case": [
			"error",
			{
				cases: {
					camelCase: false,
					kebabCase: false,
					snakeCase: true,
					pascalCase: true,
				},
			},
		],
		"unicorn/no-array-for-each": "off", // Write functional
	},
	overrides: [
		{
			files: ["**/*.test.{ts,tsx}"],
			env: {
				vitest: true,
			},
		},
	],
});
