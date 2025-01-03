package;

import Song;
import haxe.Json;
#if !MODS_ALLOWED
import openfl.utils.Assets;
#end

/**
 * Typedef defining the contents of a `Stage` file.
 */
typedef StageFile = {
	var directory:String;
	var defaultZoom:Float;
	var isPixelStage:Bool;

	var boyfriend:Array<Single>; // who made these dynamic lmao
	var girlfriend:Array<Single>;
	var opponent:Array<Single>;
	var p4:Array<Single>;
	var hide_girlfriend:Bool;

	var camera_boyfriend:Array<Single>;
	var camera_opponent:Array<Single>;
	var camera_girlfriend:Array<Single>;
	var camera_p4:Array<Single>;
	var camera_speed:Null<Single>;

	var sprites:Array<StageSprite>;
	var animations:Array<Array<StageAnimation>>;
}

/**
 * Typedef defining the contents of a sprite in a `Stage` file.
 */
typedef StageSprite = {
	var animated:Bool;
	var front:Bool;
	var glitch_shader:Null<Bool>;

	var position:Array<Float>;
	var scroll:Array<Float>;
	var size:Array<Null<Float>>;

	var alpha:Null<Float>;
	var angle:Null<Int>;

	var layer_pos:Int;

	var glitch_speed:Null<Float>;
	var glitch_amplitude:Null<Float>;
	var glitch_frequency:Null<Float>;

	var animation_index:Int;

	var antialiasing:Bool;

	var tag:String;
	var image:String;

	var flip_x:Null<Bool>;
	var flip_y:Null<Bool>;

	var gf_front:Bool;

	var origin:Array<Null<Int>>;
	var hide_lq:Null<Bool>;
}

/**
 * Typedef defining the contents of an animation in a `Stage` file.
 */
typedef StageAnimation = {
	var name:String;
	var xml_prefix:String;
	var framerate:Int;
	var looped:Bool;
	var flip_x:Bool;
	var flip_y:Bool;
}

/**
 * Class containing all related functions for stage loading and control.
 */
class StageData {
	public static var forceNextDirectory:String = null;

	public static function loadDirectory(SONG:SwagSong) {
		var stage:String = '';
		if (SONG.assets.stage != null) {
			stage = SONG.assets.stage;
		} else if (SONG.header.song != null) {
			switch (SONG.header.song.toLowerCase().replace(' ', '-')) {
				case 'spookeez' | 'south' | 'monster':
					stage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					stage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					stage = 'limo';
				case 'cocoa' | 'eggnog':
					stage = 'mall';
				case 'winter-horrorland':
					stage = 'mallEvil';
				case 'senpai' | 'roses':
					stage = 'school';
				case 'thorns':
					stage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					stage = 'tank';
				default:
					stage = 'stage';
			}
		} else {
			stage = 'stage';
		}

		var stageFile:StageFile = getStageFile(stage);
		forceNextDirectory = (stageFile == null ? '' : stageFile.directory);
	}

	public static function getStageFile(stage:String):StageFile {
		var rawJson:String = null;
		var path:String = Paths.getPreloadPath('data/stages/' + stage + '.json');

		#if MODS_ALLOWED
		var modPath:String = Paths.modFolders('data/stages/' + stage + '.json');
		if (FileSystem.exists(modPath)) {
			rawJson = File.getContent(modPath);
		} else if (FileSystem.exists(path)) {
			rawJson = File.getContent(path);
		}
		#else
		if (Assets.exists(path)) {
			rawJson = Assets.getText(path);
		}
		#end
	else {
		return null;
	}
		return cast Json.parse(rawJson);
	}
}
