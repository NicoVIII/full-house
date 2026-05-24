import js from "@eslint/js";
import type { Linter } from "eslint";
import functional from "eslint-plugin-functional";
import oxlint from "eslint-plugin-oxlint";
import solidPlugin from "eslint-plugin-solid";
import { defineConfig } from "eslint/config";
import { OxlintConfig } from "oxlint";
import tseslint from "typescript-eslint";

import oxlintConfig from "./oxlint.config";

export default defineConfig([
	{
		ignores: ["dist/**", "node_modules/**", "build/**", "src/skirout/**"],
	},
	{
		files: ["src/**/*.{ts,tsx}"],
	},
	js.configs.recommended,
	tseslint.configs.strictTypeChecked,
	tseslint.configs.stylisticTypeChecked,
	{
		rules: {
			"@typescript-eslint/switch-exhaustiveness-check": "error",
		},
	},
	functional.configs.recommended,
	functional.configs.stylistic,
	{
		// We have to make some adjustments to the functional plugin rules to
		// accommodate the way Solid components are structured
		rules: {
			"functional/functional-parameters": ["error", { enforceParameterCount: false }],
			"functional/no-expression-statements": "off",
			"functional/no-mixed-types": "off",
			"functional/no-return-void": "off",
		},
	},
	solidPlugin.configs["flat/typescript"] as unknown as Linter.Config,
	{
		languageOptions: {
			parserOptions: {
				projectService: true,
			},
		},
	},
	{
		// Special rules for test files
		files: ["**/*.test.{ts,tsx}"],
		rules: {},
	},
	// @ts-expect-error -- Works, but types are somehow twisted
	...oxlint.buildFromOxlintConfig(oxlintConfig as OxlintConfig),
]);
