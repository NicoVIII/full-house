import js from '@eslint/js';
import { defineConfig } from 'eslint/config';
import type { Linter } from 'eslint';
import solidPlugin from 'eslint-plugin-solid';
import tseslint from 'typescript-eslint';

export default defineConfig([
    {
        ignores: ['dist/**', 'node_modules/**', 'build/**'],
    },
    {
        files: ['src/**/*.{ts,tsx}'],
    },
    js.configs.recommended,
    tseslint.configs.strictTypeChecked,
    tseslint.configs.stylisticTypeChecked,
    solidPlugin.configs['flat/typescript'] as unknown as Linter.Config,
    {
        languageOptions: {
            parserOptions: {
                projectService: true,
            },
        }
    },
]);
