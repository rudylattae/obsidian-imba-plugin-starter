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
				const m = new TallyModal(app)
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

class ValueRegister
	startValue = 0
	value = startValue
	def inc
		value++
	def dec
		value--
	def reset 
		value = startValue

tag ValueDisplay
	prop register\ValueRegister
	<self> "Count = {register.value}!"

tag CounterButton < button
	prop step = 1
	<self @click=emit('record', {step:1})> <slot> "➕ {step}"

tag ResetButton < button
	<self @click=emit('reset')> <slot> 'Reset'

class TallyModal < Modal
	register\ValueRegister
	display\ValueDisplay
	clicker\CounterButton
	reset\ResetButton

	constructor app\App
		super
		register = new ValueRegister {startValue:10}

	def onOpen
		display = <ValueDisplay register=register>
		clicker = <CounterButton @record=register.inc>
		reset = <ResetButton[ml:1rem] @reset=register.reset>

		imba.mount display, titleEl
		imba.mount clicker, contentEl
		imba.mount reset, contentEl

	def onClose
		imba.unmount display
		imba.unmount clicker
		imba.unmount reset

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
