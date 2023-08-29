import { imba } from 'vite-plugin-imba';
import { defineConfig } from 'vite';

export default defineConfig({
	base: '',
	plugins: [imba()],
	build: {
		rollupOptions: {
			// overwrite default .html entry
			input: ['src/main.imba', 'src/style.imba'],
			output: {
				manualChunks: undefined,
				entryFileNames: '[name].js',
				assetFileNames: '[name].[ext]'
			},
			external: ["obsidian"]
		}
	}
});
