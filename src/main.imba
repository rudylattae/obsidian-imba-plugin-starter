import { App, Modal, Notice, Plugin, PluginSettingTab, Setting } from 'obsidian';

class MyPlugin < Plugin
	def speak
		console.log "{name} barks."

export def init 
	console.log("IMBA!")
	console.log("Another!")

init!