import './style.imba'
import { App, Plugin, Notice, Modal, PluginSettingTab, Setting } from 'obsidian'


const DEFAULT_SETTINGS =
	someText: 'Change me'
	someToggle: yes

export default class ImbaPluginStarter < Plugin
	settings

	def onload
		# load plugin settings
		await loadSettings!

		# add an icon to the ribbon for an action
		ribbonIconEl = addRibbonIcon 'list-tree', 'Hello Imba Starter', do(evt) new Notice 'Hello from the Imba Starter!'

		# add text to status bar
		const statusBarItemEl = addStatusBarItem()
		statusBarItemEl.setText('Imba Starter')

		# add command to show modal
		addCommand({
			id: 'show-basic-counter',
			name: 'Show Basic Counter',
			callback: do 
				const m = new BasicCounterModal(app)
				m.open!
		})

		# add settings tab for this plugin
		addSettingTab new ImbaStarterSettingTab(app, self)

	def onunload
		# handle stuff that need to happen when the plugin is disabled
		yes

	def loadSettings
		settings = Object.assign({}, DEFAULT_SETTINGS, await loadData!)

	def saveSettings
		await saveData(settings)

tag basic-counter
	count = 0
	<self @click=count++> "Clicked {count} times!"

class BasicCounterModal < Modal
	counter\basic-counter

	constructor app\App
		super

	def onOpen
		counter = <basic-counter>
		imba.mount counter, contentEl

	def onClose
		imba.unmount counter

class ImbaStarterSettingTab < PluginSettingTab
	plugin\MyPlugin

	constructor app\App, plugin\MyPlugin
		super
		plugin = plugin

	def display		
		const { containerEl } = self
		containerEl.empty!
		
		new Setting(containerEl)
			.setName('Setting 1')
			.setDesc('A setting to be changed')
			.addText do(text)
				text.setPlaceholder 'Provide some text'
				text.setValue plugin.settings.someText
				text.onChange do(value)
					plugin.settings.someText = value
					await plugin.saveSettings!
