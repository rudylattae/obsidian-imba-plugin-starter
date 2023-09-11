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

function getTestVaultPluginsPath(pkg, env) {
	if (env.OBSIDIAN_SANDBOX_VAULT_PATH !== undefined && env.OBSIDIAN_SANDBOX_VAULT_PATH !== "") {
		return path.join(env.OBSIDIAN_SANDBOX_VAULT_PATH, '.obsidian', 'plugins', pkg.name);
	}
	return false;
}

export default defineConfig(({ command, mode, ssrBuild }) => {

	let outDir = path.resolve('.');
	let assetsToCopy = [];
	const env = loadEnv(mode, process.cwd(), '');
	const obsidianTestVaultPluginsPath = getTestVaultPluginsPath(pkg, env) 

	if (mode === 'development') {
		if (obsidianTestVaultPluginsPath) {
			outDir = obsidianTestVaultPluginsPath;
			assetsToCopy = [
				'manifest.json',
				'.hotreload'
			]
		}

		return mergeConfig(
			defaultConfig,
			{
				plugins: [
					copyAssets({
						assets: assetsToCopy
					})
				],
				build: {
					outDir: outDir,
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
