class_name GameManager
extends Node

var game_paused: bool = false

var engame_started: bool = false
var endof_endgame: bool = false
var current_endgame_path: String = "true_beginning" # End types: True Beginning, Ending A, Ending B, True Ending. True Beginning is an ending that leads into the actual game, Ending A and B serve as distractions. True ending will only be capable of being triggered after True Beginning is triggered, even if the end gate is reached
