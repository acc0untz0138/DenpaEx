package;

import Alphabet;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

/**
 * Substate used to alter the Gamplay Modifers map.
 */
class GameplayChangersSubstate extends MusicBeatSubstate {
	private var curOption:GameplayOption = null;
	private var curSelected:Int = 0;
	private var optionsArray:Array<Dynamic> = [];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var checkboxGroup:FlxTypedGroup<CheckboxThingie>;
	private var grpTexts:FlxTypedGroup<AttachedText>;

	function getOptions() {
		var skip:Bool = pauseMenu != null;

		var goption:GameplayOption = new GameplayOption('Scroll Type', 'scrolltype', 'string', 'multiplicative', ["multiplicative", "constant"]);
		optionsArray.push(goption);

		var option:GameplayOption = new GameplayOption('Scroll Speed', 'scrollspeed', 'float', 1);
		option.scrollSpeed = 2.0;
		option.minValue = 0.35;
		option.changeValue = 0.05;
		option.slowChangeValue = 0.01;
		option.decimals = 2;
		if (goption.getValue() != "constant") {
			option.displayFormat = '%vX';
			option.maxValue = 3;
		} else {
			option.displayFormat = "%v";
			option.maxValue = 10;
		}
		optionsArray.push(option);

		var option:GameplayOption = new GameplayOption('Playback Rate', 'songspeed', 'float', 1);
		option.scrollSpeed = 2;
		option.changeValue = 0.25;
		option.slowChangeValue = 0.05;
		option.minValue = 0.1;
		option.maxValue = 10; // peeps wanted 10x speed
		option.displayFormat = '%vX';
		option.decimals = 2;
		optionsArray.push(option);

		var option:GameplayOption = new GameplayOption('Health Gain Multiplier', 'healthgain', 'float', 1);
		option.scrollSpeed = 2.5;
		option.minValue = 0;
		option.maxValue = 5;
		option.changeValue = 0.1;
		option.slowChangeValue = 0.1;
		option.displayFormat = '%vX';
		optionsArray.push(option);

		var option:GameplayOption = new GameplayOption('Health Loss Multiplier', 'healthloss', 'float', 1);
		option.scrollSpeed = 2.5;
		option.minValue = 0.5;
		option.maxValue = 5;
		option.changeValue = 0.1;
		option.slowChangeValue = 0.1;
		option.displayFormat = '%vX';
		optionsArray.push(option);

		var option:GameplayOption = new GameplayOption('Instakill on Miss', 'instakill', 'bool', false);
		optionsArray.push(option);

		var option:GameplayOption = new GameplayOption('Sick Only', 'sickonly', 'bool', false);
		optionsArray.push(option);

		if (!skip) {
			var option:GameplayOption = new GameplayOption('Poison', 'poison', 'bool', false);
			optionsArray.push(option);

			var option:GameplayOption = new GameplayOption('Freeze', 'freeze', 'bool', false);
			optionsArray.push(option);

			var option:GameplayOption = new GameplayOption('Flashlight', 'flashlight', 'bool', false);
			optionsArray.push(option);
		}

		var option:GameplayOption = new GameplayOption('Ghost Mode', 'ghostmode', 'bool', false);
		optionsArray.push(option);

		if (!skip) {
			var option:GameplayOption = new GameplayOption('Random Mode', 'randommode', 'bool', false);
			optionsArray.push(option);

			var option:GameplayOption = new GameplayOption('Flip', 'flip', 'bool', false);
			optionsArray.push(option);

			var option:GameplayOption = new GameplayOption('Play as Opponent', 'opponentplay', 'bool', false);
			optionsArray.push(option);
		}

		var option:GameplayOption = new GameplayOption('Quartiz', 'quartiz', 'bool', false);
		optionsArray.push(option);

		var option:GameplayOption = new GameplayOption('Practice Mode', 'practice', 'bool', false);
		optionsArray.push(option);

		var option:GameplayOption = new GameplayOption('Auto', 'botplay', 'bool', false);
		optionsArray.push(option);
	}

	public function getOptionByName(name:String) {
		for (i in optionsArray) {
			var opt:GameplayOption = i;
			if (opt.name == name)
				return opt;
		}
		return null;
	}

	private var iconArray:Array<AttachedSprite> = [];

	private var bg:FlxSprite;

	private var pauseMenu:MusicBeatSubstate = null;

	public function new(?pause:MusicBeatSubstate = null) {
		super();

		this.pauseMenu = pause;

		bg = new FlxSprite(-1280, 0).loadGraphic(Paths.image('loadingscreen'));
		bg.angle = 27;
		bg.alpha = 0;
		add(bg);
		FlxTween.tween(bg, {x: 0, angle: 0, alpha: 1}, 0.22, {ease: FlxEase.quadOut});

		// avoids lagspikes while scrolling through menus!
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedText>();
		add(grpTexts);

		checkboxGroup = new FlxTypedGroup<CheckboxThingie>();
		add(checkboxGroup);

		getOptions();

		for (i in 0...optionsArray.length) {
			var optionText:Alphabet = new Alphabet(0, 70 * i, optionsArray[i].name, true, false, 0.05, 0.8);
			optionText.altRotation = true;
			optionText.x += 300;
			optionText.xAdd = 20;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if (optionsArray[i].type == 'bool') {
				var checkbox:CheckboxThingie = new CheckboxThingie(optionText.x - 105, optionText.y, optionsArray[i].getValue() == true);
				checkbox.sprTracker = optionText;
				checkbox.offsetY = -60;
				checkbox.ID = i;
				checkboxGroup.add(checkbox);
				optionText.xAdd += 80;
			} else {
				var valueText:AttachedText = new AttachedText('' + optionsArray[i].getValue(), optionText.width + 30, true, 0.8);
				valueText.sprTracker = optionText;
				valueText.copyAlpha = true;
				valueText.ID = i;
				grpTexts.add(valueText);
				optionsArray[i].setChild(valueText);
			}
			updateTextFrom(optionsArray[i]);
			if (optionsArray[i].name != "Playback Rate"
				&& optionsArray[i].name != "Scroll Speed"
				&& optionsArray[i].name != "Scroll Type") {
				var icon:AttachedSprite = new AttachedSprite('modifiers/' + optionsArray[i].variable);
				icon.sprTracker = optionText;
				icon.xAdd = optionText.width;
				if (optionsArray[i].name == "Health Gain Multiplier" || optionsArray[i].name == "Health Loss Multiplier")
					icon.xAdd += 60 + grpTexts.members[i].width;
				icon.yAdd = -55;
				icon.copyAlpha = true;
				add(icon);
				iconArray.push(icon);
			}
		}
		changeSelection();
		reloadCheckboxes();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		addVirtualPad(LEFT_FULL, A_B_C);
		addVirtualPadCamera(); // wtf?
		FlxTween.tween(virtualPad, {x: 0, angle: 0, alpha: 1}, 0.22, {ease: FlxEase.quadOut});
	}

	override function destroy() {
		if (pauseMenu != null) {
			pauseMenu.persistentUpdate = true;
			PauseSubState.instance.addVirtualPad(LEFT_FULL, A);
			PlayState.instance.initModifiers(true);
		}
		super.destroy();
	}

	var nextAccept:Int = 5;
	var holdTime:Float = 0;
	var holdValue:Float = 0;

	override function update(elapsed:Float) {
		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (FlxG.mouse.wheel != 0) {
			changeSelection(-FlxG.mouse.wheel);
		}

		if (controls.BACK) {
			ClientPrefs.saveSettings();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxTween.tween(virtualPad, {x: -1280, angle: 27, alpha: 0}, 0.22, {ease: FlxEase.quadOut, onComplete: function(_) {}});
			FlxTween.tween(bg, {x: -1280, angle: 27, alpha: 0}, 0.22, {
				ease: FlxEase.quadOut,
				onComplete: function(_) {
					close();
				}
			});
			grpOptions.forEach(function(option:Alphabet) {
				FlxTween.tween(option, {alpha: 0}, 0.22, {ease: FlxEase.quadOut});
			});
		}

		if (nextAccept <= 0) {
			var usesCheckbox = true;
			if (curOption.type != 'bool') {
				usesCheckbox = false;
			}

			if (usesCheckbox) {
				if (controls.ACCEPT) {
					FlxG.sound.play(Paths.sound('scrollMenu'));
					curOption.setValue((curOption.getValue() == true) ? false : true);
					curOption.change();
					reloadCheckboxes();
				}
			} else {
				if (controls.UI_LEFT || controls.UI_RIGHT) {
					var pressed = (controls.UI_LEFT_P || controls.UI_RIGHT_P);
					if (holdTime > 0.5 || pressed) {
						if (pressed) {
							var add:Dynamic = null;
							if (curOption.type != 'string') {
								add = (controls.UI_LEFT ? (FlxG.keys.pressed.CONTROL ? -curOption.slowChangeValue : -curOption.changeValue) : (FlxG.keys.pressed.CONTROL ? curOption.slowChangeValue : curOption.changeValue));
							}

							switch (curOption.type) {
								case 'int' | 'float' | 'percent':
									holdValue = curOption.getValue() + add;
									if (holdValue < curOption.minValue)
										holdValue = curOption.minValue;
									else if (holdValue > curOption.maxValue)
										holdValue = curOption.maxValue;

									switch (curOption.type) {
										case 'int':
											holdValue = Math.round(holdValue);
											curOption.setValue(holdValue);

										case 'float' | 'percent':
											holdValue = FlxMath.roundDecimal(holdValue, curOption.decimals);
											curOption.setValue(holdValue);
									}

								case 'string':
									var num:Int = curOption.curOption; // lol
									if (controls.UI_LEFT_P)
										--num;
									else
										num++;

									if (num < 0) {
										num = curOption.options.length - 1;
									} else if (num >= curOption.options.length) {
										num = 0;
									}

									curOption.curOption = num;
									curOption.setValue(curOption.options[num]); // lol

									if (curOption.name == "Scroll Type") {
										var oOption:GameplayOption = getOptionByName("Scroll Speed");
										if (oOption != null) {
											if (curOption.getValue() == "constant") {
												oOption.displayFormat = "%v";
												oOption.maxValue = 10;
											} else {
												oOption.displayFormat = "%vX";
												oOption.maxValue = 3;
												if (oOption.getValue() > 3)
													oOption.setValue(3);
											}
											updateTextFrom(oOption);
										}
									}
									// trace(curOption.options[num]);
							}
							updateTextFrom(curOption);
							curOption.change();
							FlxG.sound.play(Paths.sound('scrollMenu'));
						} else if (curOption.type != 'string') {
							holdValue += curOption.scrollSpeed * elapsed * (controls.UI_LEFT ? -1 : 1);
							if (holdValue < curOption.minValue)
								holdValue = curOption.minValue;
							else if (holdValue > curOption.maxValue)
								holdValue = curOption.maxValue;

							switch (curOption.type) {
								case 'int':
									curOption.setValue(Math.round(holdValue));

								case 'float' | 'percent':
									curOption.setValue(FlxMath.roundDecimal(holdValue, curOption.decimals));
							}
							updateTextFrom(curOption);
							curOption.change();
						}
					}

					if (curOption.type != 'string') {
						holdTime += elapsed;
					}
				} else if (controls.UI_LEFT_R || controls.UI_RIGHT_R) {
					clearHold();
				}
			}

			if (virtualPad.buttonC.justPressed || controls.RESET && FlxG.keys.pressed.SHIFT) {
				for (i in 0...optionsArray.length) {
					var leOption:GameplayOption = optionsArray[i];
					leOption.setValue(leOption.defaultValue);
					if (leOption.type != 'bool') {
						if (leOption.type == 'string') {
							leOption.curOption = leOption.options.indexOf(leOption.getValue());
						}
						updateTextFrom(leOption);
					}

					if (leOption.name == 'Scroll Speed') {
						leOption.displayFormat = "%vX";
						leOption.maxValue = 3;
						if (leOption.getValue() > 3) {
							leOption.setValue(3);
						}
						updateTextFrom(leOption);
					}
					leOption.change();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				reloadCheckboxes();
			}

			if (controls.RESET && !FlxG.keys.pressed.SHIFT) {
				var leOption:GameplayOption = optionsArray[curSelected];
				leOption.setValue(leOption.defaultValue);
				if (leOption.type != 'bool') {
					if (leOption.type == 'string') {
						leOption.curOption = leOption.options.indexOf(leOption.getValue());
					}
					updateTextFrom(leOption);
				}

				if (leOption.name == 'Scroll Speed') {
					leOption.displayFormat = "%vX";
					leOption.maxValue = 3;
					if (leOption.getValue() > 3) {
						leOption.setValue(3);
					}
					updateTextFrom(leOption);
				}
				leOption.change();
				FlxG.sound.play(Paths.sound('cancelMenu'));
				reloadCheckboxes();
			}
		}

		if (nextAccept > 0) {
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	function updateTextFrom(option:GameplayOption) {
		var text:String = option.displayFormat;
		var val:Dynamic = option.getValue();
		if (option.type == 'percent')
			val *= 100;
		var def:Dynamic = option.defaultValue;
		option.text = text.replace('%v', val).replace('%d', def);
	}

	function clearHold() {
		if (holdTime > 0.5) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		holdTime = 0;
	}

	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = optionsArray.length - 1;
		if (curSelected >= optionsArray.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}
		for (text in grpTexts) {
			text.alpha = 0.6;
			if (text.ID == curSelected) {
				text.alpha = 1;
			}
		}
		curOption = optionsArray[curSelected]; // shorter lol
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function reloadCheckboxes() {
		for (checkbox in checkboxGroup) {
			checkbox.daValue = (optionsArray[checkbox.ID].getValue() == true);
		}
	}
}

class GameplayOption {
	private var child:Alphabet;

	public var text(get, set):String;
	public var onChange:Void->Void = null; // Pressed enter (on Bool type options) or pressed/held left/right (on other types)

	public var type(get, default):String = 'bool'; // bool, int (or integer), float (or fl), percent, string (or str)

	// Bool will use checkboxes
	// Everything else will use a text
	public var showBoyfriend:Bool = false;
	public var scrollSpeed:Float = 50; // Only works on int/float, defines how fast it scrolls per second while holding left/right

	private var variable:String = null; // Variable from ClientPrefs.hx's gameplaySettings

	public var defaultValue:Dynamic = null;

	public var curOption:Int = 0; // Don't change this
	public var options:Array<String> = null; // Only used in string type
	public var changeValue:Dynamic = 1; // Only used in int/float/percent type, how much is changed when you PRESS
	public var slowChangeValue:Dynamic = 1;
	public var minValue:Dynamic = null; // Only used in int/float/percent type
	public var maxValue:Dynamic = null; // Only used in int/float/percent type
	public var decimals:Int = 1; // Only used in float/percent type

	public var displayFormat:String = '%v'; // How String/Float/Percent/Int values are shown, %v = Current value, %d = Default value
	public var name:String = 'Unknown';

	public function new(name:String, variable:String, type:String = 'bool', defaultValue:Dynamic = 'null variable value', ?options:Array<String> = null) {
		this.name = name;
		this.variable = variable;
		this.type = type;
		this.defaultValue = defaultValue;
		this.options = options;

		if (defaultValue == 'null variable value') {
			switch (type) {
				case 'bool':
					defaultValue = false;
				case 'int' | 'float':
					defaultValue = 0;
				case 'percent':
					defaultValue = 1;
				case 'string':
					defaultValue = '';
					if (options.length > 0) {
						defaultValue = options[0];
					}
			}
		}

		if (getValue() == null) {
			setValue(defaultValue);
		}

		switch (type) {
			case 'string':
				var num:Int = options.indexOf(getValue());
				if (num > -1) {
					curOption = num;
				}

			case 'percent':
				displayFormat = '%v%';
				slowChangeValue = 0.01;
				changeValue = 0.01;
				minValue = 0;
				maxValue = 1;
				scrollSpeed = 0.5;
				decimals = 2;
		}
	}

	public function change() {
		// nothing lol
		if (onChange != null) {
			onChange();
		}
	}

	public function getValue():Dynamic {
		return ClientPrefs.gameplaySettings.get(variable);
	}

	public function setValue(value:Dynamic) {
		ClientPrefs.gameplaySettings.set(variable, value);
	}

	public function setChild(child:Alphabet) {
		this.child = child;
	}

	private function get_text() {
		if (child != null) {
			return child.text;
		}
		return null;
	}

	private function set_text(newValue:String = '') {
		if (child != null) {
			child.changeText(newValue);
		}
		return null;
	}

	private function get_type() {
		var newValue:String = 'bool';
		switch (type.toLowerCase().trim()) {
			case 'int' | 'float' | 'percent' | 'string':
				newValue = type;
			case 'integer':
				newValue = 'int';
			case 'str':
				newValue = 'string';
			case 'fl':
				newValue = 'float';
		}
		type = newValue;
		return type;
	}
}
