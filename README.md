# Create Obsidian Plugins with Imba

This repo is a started template for building an [Obsidian](https://obsidian.md) using [Imba](https://imba.io).
To take it for a quick test-drive, follow the steps in [Speedrun](#speedrun).

## Speedrun
If you want to get started with this template in the most straight-forward way, follow the steps below.

1. Create a new repository from this template to start a new plugin
    - See [Creating a repository from a template](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template) for howto.
2. Clone your repo into the `.obsidian\plugins` directory of you [Sandbox Vault](#sandbox-vault) and cd into it
3. Edit the `package.json` and `manifest.json` files to reflect your plugin's identiy
3. Run `npm install` to bring in all the dependencies
4. Run `npn run dev` to compile the plugin
    - `main.imba` -> `main.js`
    -  `styles.imba` -> `styles.css`
5. Open your Obsidian [Sandbox Vault](#sandbox-vault) and enable the `Imba Template` plugin
6. You may now interact with the plugin functionality in Obsidian
7. When you are ready to build a release, run `npm run build` to send minified output to the `./dist` folder
    - `main.imba` -> `./dist/main.js`
    - `styles.imba` -> `./dist/styles.css`
    - `manifest.json` -> `./dist/manifest.json`

## Benefits
Use this template if you want to:

### 1. Quickly prototype your plugin idea with Imba
If you enjoy using Obsidian and want to create plugins for it, this template gives you a chance to use Imba as your preferred language. Simply clone it, install the dependencies and start creating. 

Take a look at the "Usage" section for detailed guidance.

### 2. Live-test your plugin and iterate with a tight feedback loop
Powered by [Vite](https://vitejs.dev/) which delegates to [esbuild](https://esbuild.github.io/) and [Rollup](https://rollupjs.org/) for fast compilation and efficient bundling.

This starter comes with the usual `npm run dev` to watch for changes in your `.imba` files and rebuild your plugin.

See the "Flow state" for guidance on how to setup a seamless integration with Obsidian in order to live test your plugin as you build it.

### 3. Easily build an optimized version of your plugin to publish 
Bundle and minify your Imba code into compact JavaScript and CSS.

## Features
When installed in your [Sandbox Vault](#sandbox-vault), this plugin provides the following features:
- Adds a [Ribbon icon/action](https://docs.obsidian.md/Plugins/User+interface/Ribbon+actions), which when clicked, shows a Notification


## Usage
TODO

## Sandbox Vault
While building your Obsidian plugin, it is possible to do serious damage to the data in your vault. To minimize risk to your data, you should consider developing and testing your plugin in a "sandbox". A sandbox is any vault that has only test files, NOT your actual notes. 

With this approach, even if your plugin code (un?)intentionally does something wild and nules all the data and files, you can rest easy knowing your real data is safe.

To setup a sandbox, 
1. Create a new vault, name it something like "My Sandbox" or "obsidian-sandbox". 
2. Develop and install your plugin in the sandbox

There are some "test data" repositories provided by the Obsidian Community that can be used 

In the [Development flow state](#development-flow-state) section, we'll take a look at how you can develop your plugin outside of the Sandbox Vault and still test your plugin in the sandbox.

## Development flow state
See [Development workflow](https://docs.obsidian.md/Plugins/Getting+started/Development+workflow) to get a basic idea of how plugin development goes in "Obsidianland". If you followed the steps in the [speedrun](#speedrun), you will be using the approach where you develop your plugin inside a folder within your "sandbox".



