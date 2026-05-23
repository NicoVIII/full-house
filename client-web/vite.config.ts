import devtools from "solid-devtools/vite";
import { defineConfig } from "vite";
import solidPlugin from "vite-plugin-solid";

export default defineConfig({
	plugins: [
		devtools({
			autoname: true,
		}),
		solidPlugin(),
	],
	server: {
		host: true,
		port: 3000,
		proxy: {
			"/api": {
				target: "http://localhost:8000",
				changeOrigin: true,
			},
		},
	},
	build: {
		target: "esnext",
	},
});
