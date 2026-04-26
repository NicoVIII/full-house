import js from '@eslint/js';
import { defineConfig } from 'eslint/config';
import type { Linter } from 'eslint';
import solidPlugin from 'eslint-plugin-solid';
import tseslint from 'typescript-eslint';
import functional from 'eslint-plugin-functional';

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
    {
        rules: {
            '@typescript-eslint/switch-exhaustiveness-check': 'error',
        },
    },
    functional.configs.recommended,
    functional.configs.stylistic,
    {
        // We have to make some adjustments to the functional plugin rules to
        // accommodate the way Solid components are structured
        rules: {
            'functional/functional-parameters': ['error', { enforceParameterCount: false }],
            'functional/no-expression-statements': 'off',
            'functional/no-mixed-types': 'off',
            'functional/no-return-void': 'off',
        }
    },
    solidPlugin.configs['flat/typescript'] as unknown as Linter.Config,
    {
        languageOptions: {
            parserOptions: {
                projectService: true,
            },
        }
    },
    {
        // Special rules for test files
        files: ['**/*.test.{ts,tsx}'],
        rules: {},
    }
]);
