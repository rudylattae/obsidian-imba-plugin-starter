import './style.imba'
import { App, Plugin, Notice, Modal, PluginSettingTab, Setting, ItemView } from 'obsidian'
import * as manifest from './manifest.json'


###
==================== defaults ====================
Global defaults and contants for this plugin
###
const DEFAULT_SETTINGS =
	enableTallyCounter: yes
	tallyCounterStartFrom: 0
	tallyCounterStepBy: 1
	enableBackgroundActivitySimulator: yes
	backgroundActivityDuration: 1500
	backgroundActivityCompletionMessage: "Done pretending!"


###
==================== tally-counter ====================
Stuff related to the tally counter functionality
###
class ValueRegister
	startValue = 0
	stepBy = 1
	value = startValue
	def inc
		value = value + stepBy
	def dec
		value-=stepBy
	def reset 
		value = startValue

tag ValueDisplay
	prop register\ValueRegister
	<self> "Count = {register.value}!"

tag CounterButton < button
	prop step = 1
	<self @click=emit('record', {step:step})> <slot> "➕ {step}"

tag ResetButton < button
	<self @click=emit('reset')> <slot> 'Reset'

class TallyCounterModal < Modal
	register\ValueRegister
	display\ValueDisplay
	clicker\CounterButton
	reset\ResetButton

	constructor app\App, settings
		super
		#stepBy = settings.tallyCounterStepBy
		register = new ValueRegister {startValue: settings.tallyCounterStartFrom, stepBy: #stepBy}

	def onOpen
		display = <ValueDisplay register=register>
		clicker = <CounterButton @record=register.inc step=#stepBy>
		reset = <ResetButton[ml:1rem] @reset=register.reset>

		imba.mount display, titleEl
		imba.mount clicker, contentEl
		imba.mount reset, contentEl

	def onClose
		imba.unmount display
		imba.unmount clicker
		imba.unmount reset


###
========== background-activity ==========
Stuff related to the background activity simulator functionality
###
tag StatusIndicator
	prop busy = no
	get state
		if !busy 
			'✅'
		else 
			'🔃'
	def doing
		busy = yes
	def done
		busy = no
	<self @click=emit('look-busy')> "Imba Plugin Starter: {state}"


###
==================== settings ====================
###
class ImbaStarterSettingTab < PluginSettingTab
	plugin\ImbaPluginStarter

	constructor app\App, plugin\ImbaPluginStarter
		super
		plugin = plugin

	def display		
		const { containerEl } = self
		containerEl.empty!
		
		new Setting(containerEl)
			.setName('Enable tally counter')
			.setDesc('Turns on/off ability to use the tally counter.')
			.addToggle do(toggle)
				toggle.setValue plugin.settings.enableTallyCounter
				toggle.onChange do(value)
					plugin.settings.enableTallyCounter = value
					await plugin.saveSettings!

		new Setting(containerEl)
			.setName('Start tally counter from')
			.setDesc('Initial count to set tally to')
			.addText do(text)
				text.setValue plugin.settings.tallyCounterStartFrom.toString!
				text.onChange do(value)
					plugin.settings.tallyCounterStartFrom = parseInt(value) || 0
					await plugin.saveSettings!

		new Setting(containerEl)
			.setName('Step tally counter by')
			.setDesc('How much to increase the tally counter by')
			.addText do(text)
				text.setValue plugin.settings.tallyCounterStepBy.toString!
				text.onChange do(value)
					plugin.settings.tallyCounterStepBy = parseInt(value) || 0
					await plugin.saveSettings!

		new Setting(containerEl)
			.setName('Enable background activity simulator')
			.setDesc('Turns on/off ability to simulate a long/short running background activity.')
			.addToggle do(toggle)
				toggle.setValue plugin.settings.enableBackgroundActivitySimulator
				toggle.onChange do(value)
					plugin.settings.enableBackgroundActivitySimulator = value
					await plugin.saveSettings!

		new Setting(containerEl)
			.setName('Background activity duration')
			.setDesc('How long to run the simulated background activity for, in milliseconds.')
			.addSlider do(slider)
				slider.setLimits 1000, 5500, 100 
				slider.setDynamicTooltip!
				slider.setValue plugin.settings.backgroundActivityDuration
				slider.onChange do(value)
					plugin.settings.backgroundActivityDuration = value
					await plugin.saveSettings!

		new Setting(containerEl)
			.setName('Background activity completion message')
			.setDesc('What to say in a notification when the background activity is done.')
			.addText do(text)
				text.setPlaceholder 'Provide some text'
				text.setValue plugin.settings.backgroundActivityCompletionMessage
				text.onChange do(value)
					plugin.settings.backgroundActivityCompletionMessage = value
					await plugin.saveSettings!


###
==================== main ====================
The entry point to this plugin. Registers all relevant commands, views, etc. when plugin is enabled.
###
export default class ImbaPluginStarter < Plugin
	settings
	statusIndicator

	def onload
		# load plugin settings
		await loadSettings!

		# wire up items related to Tally counter
		if settings.enableTallyCounter
			# add an icon to the ribbon for an action
			ribbonIconEl = addRibbonIcon 'hand', "Open {manifest.name} View", do(evt) openTallyCounterModal!

			# add command to open tally counter modal
			addCommand({
				id: 'open-tally-counter',
				name: 'Open Tally Counter',
				callback: do openTallyCounterModal!
					
			})

		# wire up items related to the Background activity Simulator
		if settings.enableBackgroundActivitySimulator
			# add indicator in status bar
			const statusBarItemEl = addStatusBarItem()
			statusIndicator = <StatusIndicator @look-busy=simulateBackgroundActivity>
			imba.mount statusIndicator, statusBarItemEl

			# add command to pretend to "do something"
			addCommand({
				id: 'simulate-backgound-activity',
				name: 'Simulate Background Activity',
				callback: do simulateBackgroundActivity!
			})

		# add settings tab for this plugin
		addSettingTab new ImbaStarterSettingTab(app, self)

	def openTallyCounterModal
		const m = new TallyCounterModal(app, settings)
		m.open!

	def simulateBackgroundActivity
		const duration = settings.backgroundActivityDuration
		new Notice "Pretending to do something for {duration} milliseconds..."
		statusIndicator.doing!
		imba.commit! # we use commit here to force a re-render since we are outside of the main imba loop
		setTimeout(&, duration) do
			statusIndicator.done!
			imba.commit! # another commit
			new Notice settings.backgroundActivityCompletionMessage

	def onunload
		# handle stuff that need to happen when the plugin is disabled
		yes

	def loadSettings
		settings = Object.assign({}, DEFAULT_SETTINGS, await loadData!)

	def saveSettings
		await saveData(settings)

