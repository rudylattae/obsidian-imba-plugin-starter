import path from 'path';
import { imba } from 'vite-plugin-imba';
import { defineConfig, loadEnv, createLogger, mergeConfig } from 'vite';
import copyAssets from "rollup-plugin-copy-assets";
import pkg from './package.json' assert { type: 'json' };


const logger = createLogger();
const defaultConfig = {
	plugins: [
		imba()
	],
	build: {
		target: 'node18',
		lib: {
			entry: path.join(__dirname, 'main.imba'),
			formats: ['cjs']
		},
		rollupOptions: {
			output: {
				entryFileNames: 'main.js',
				assetFileNames: 'styles.css'
			},
			external: [
				'obsidian'
			]
		}
	}
};

export default defineConfig(({ command, mode, ssrBuild }) => {

	let outDir = path.resolve('./dist');
	const env = loadEnv(mode, process.cwd(), '');
	if (env.OBSIDIAN_TEST_VAULT_PATH !== undefined && env.OBSIDIAN_TEST_VAULT_PATH !== "") {
		const obsidianTestVaultPath = env.OBSIDIAN_TEST_VAULT_PATH;
		const obsidianTestVaultPluginsPath = path.join(obsidianTestVaultPath, '.obsidian', 'plugins', pkg.name);
		outDir = obsidianTestVaultPluginsPath;
		logger.info(`Sending build output to ${outDir}`);
	} else {
		logger.warn('No value found for OBSIDIAN_TEST_VAULT_PATH in .env, ignoring.')
	}

	if (mode === 'development') {
		return mergeConfig(
			defaultConfig,
			{
				plugins: [
					copyAssets({
						assets: [
							'manifest.json',
							'.hotreload'
						]
					})
				],
				build: {
					outDir: outDir,
					emptyOutDir: true,
					minify: false,
					sourcemap: 'inline',
				}
			}
		);
	}

	if (mode === 'production') {
		return mergeConfig(
			defaultConfig,
			{
				plugins: [
					copyAssets({
						assets: [
							'manifest.json'
						]
					})
				],
			}
		);
	}
});
