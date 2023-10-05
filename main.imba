import './style.imba'
import { App, Plugin, Notice, Modal, PluginSettingTab, Setting, ItemView } from 'obsidian'
import * as manifest from './manifest.json'


###
==================== obsidian-styled elements ====================
These are convenient little elements (tags) that have the requisite styles
###
tag obsidian-switch
	prop enabled = no
	<self.checkbox-container .is-enabled=enabled @click=(enabled = !enabled)>
			<input type="checkbox" bind=enabled tabindex="0">

tag obsidian-text < input
	prop type = 'input'
	<self type=type spellcheck='false'>


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
	backgroundActivityCompletionMessage: 'Done pretending!'
	enableDemoView: yes
const DEMO_VIEW = 'demo-view'


###
==================== tally-counter ====================
Stuff related to the tally counter functionality
###
class ValueRegister
	constructor initial = 0
		initial = initial
		current = initial

	def inc step
		current += step
	def dec step
		current -= step
	def reset 
		current = initial

tag ValueDisplay
	prop register\ValueRegister
	<self> "Count = {register.current}"

tag CounterButton < button
	prop step = 1
	<self @click=emit('count', {step:step})> <slot> "➕ {step}"

tag ResetButton < button
	<self @click=emit('reset')> <slot> 'Reset'

tag TallyCounter
	prop initial
	prop step
	
	get register
		if !#register 
			#register = new ValueRegister initial
		#register

	css d:hflex mb:1rem

	<self>
		<CounterButton step=step @count=(do(e) register.inc e.detail.step )>
		<ResetButton[ml:0.5rem] @reset=register.reset>
		<ValueDisplay[ml:0.5rem] register=register>

class TallyCounterModal < Modal
	register\ValueRegister
	display\ValueDisplay
	clicker\CounterButton
	reset\ResetButton

	constructor app\App, settings
		super
		#stepBy = settings.tallyCounterStepBy
		register = new ValueRegister settings.tallyCounterStartFrom

	def onOpen
		display = <ValueDisplay register=register>
		clicker = <CounterButton @count=(do(e) register.inc e.detail.step) step=#stepBy>
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
	prop offIndicator = '✅'
	prop onIndicator = '🔃'

	get state
		busy ? onIndicator : offIndicator
	
	def doing
		busy = yes
	
	def done
		busy = no
	
	<self @click=emit('look-busy')> "Imba Plugin Starter: {state}"


###
==================== demo view ====================
###
tag DemoFragment
	prop pluginName
	prop counterSpecs = []

	css .plugin-name ml:0.5rem pl:0.3rem pr:0.3rem fw:bold bg:yellow8 
	css h4 bdb:1px solid red

	def rng min, max
		let a = Math.ceil min
		let b = Math.floor max
		Math.floor(Math.random! * (b - a + 1) + a)

	def addNewCounter
		initial = rng 0, 10
		step = rng 1, 10
		counterSpecs.push {initial, step}

	<self>
		<h2> 'Demo View!'
		<p> 'This is a demo view from'
			<span.plugin-name> pluginName
		<h4> 'Toggle state'
		<p> '''Click the switch to toggle the state of the status indicator.

		This is the same "StatusIndicator" component shows up in the statusbar. 
		'''
		<[d:hflex]>
			<obsidian-switch$toggle>
			<StatusIndicator[ml:1rem fs:md] offIndicator='⚪' onIndicator='🟢' busy=$toggle.enabled>
		
		<h4> 'Tally Counters'
		<p> '''Play with multiple "TallyCounter" components
		The button below will add a new counter with random start and step values.'''
		<button [mb:1rem] @click=addNewCounter> 'Add New Counter'
		for spec in counterSpecs
			<TallyCounter initial=spec.initial step=spec.step>
		

class DemoView < ItemView
	leaf\WorskpaceLeaf
	settings
	content\DemoWidget

	constructor leaf\WorkspaceLeaf, settings
		super
		leaf = leaf
		settings = settings

	def getViewType
		DEMO_VIEW

	def getDisplayText
		"Demo View";

	def getIcon
		'diff'

	def onOpen
		const contentEl = containerEl.children[1]
		content = <DemoFragment pluginName=manifest.name>
		imba.mount content, contentEl

	def onClose
		console.log 'Closed demo view'
		imba.unmount content



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
			ribbonIconEl = addRibbonIcon 'bean', "Open {manifest.name} View", do(evt) openTallyCounterModal!

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

		# wire up view
		if settings.enableDemoView
			registerView(DEMO_VIEW, do(leaf\WorkspaceLeaf) new DemoView(leaf, settings))

			# add command to show the demo view
			addCommand({
				id: 'show-demo-view',
				name: 'Show Demo View',
				callback: do showDemoView!
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

	def showDemoView
		const views = await app.workspace.getLeavesOfType(DEMO_VIEW)
		if views.length === 0
			await app.workspace.getRightLeaf(false).setViewState({
				type: DEMO_VIEW
				active: true
			})
		app.workspace.revealLeaf app.workspace.getLeavesOfType(DEMO_VIEW)[0]

	def onunload
		# handle stuff that need to happen when the plugin is disabled
		yes

	def loadSettings
		settings = Object.assign({}, DEFAULT_SETTINGS, await loadData!)

	def saveSettings
		await saveData(settings)

