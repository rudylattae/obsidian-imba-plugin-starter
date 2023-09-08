import './style.imba'
import { Plugin } from 'obsidian';


export default class MyPlugin < Plugin
	def onload
		console.log "My Plugin LOADED!! 5 times!"
		
	def unload
		console.log "My Plugin unloaded!"
