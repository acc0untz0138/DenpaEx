package;

import Shaders.ColorSwap;
import editors.ChartingState;
import flixel.FlxSprite;
import flixel.math.FlxRect;

typedef EventNote = {
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

typedef PreloadedChartNote = {
	strumTime:Float,
	noteData:Int,
	mustPress:Bool,
	noteType:String,
	animSuffix:String,
	noteskin:String,
	texture:String,
	noAnimation:Bool,
	noMissAnimation:Bool,
	gfNote:Bool,
	isSustainNote:Bool,
	isSustainEnd:Bool,
	sustainLength:Float,
	sustainScale:Float,
	parent:PreloadedChartNote,
	prevNote:Note,
	strum:StrumNote,
	mania:Int,
	hitHealth:Float,
	missHealth:Float,
	hitCausesMiss:Null<Bool>,
	wasHit:Bool,
	spawnTimeMult:Float,
	wasSpawned:Bool,
	canBeHit:Bool,
	ignoreNote:Bool,
	wasMissed:Bool
}

/**
* Basic class for all `Note`s.
*/
class Note extends FlxSprite
{
	public static final gfxLetter:Array<String> = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];

	public static final scales:Array<Float> = [0.9, 0.85, 0.8, 0.7, 0.66, 0.6, 0.55, 0.50, 0.46];
	public static final lessX:Array<Int> = [0, 0, 0, 0, 0, 8, 7, 8, 8];
	public static final separator:Array<Int> = [0, 0, 1, 1, 2, 2, 2, 3, 3];
	public static final xtra:Array<Int> = [150, 89, 0, 0, 0, 0, 0, 0, 0];
	public static final posRest:Array<Int> = [0, 0, 0, 0, 25, 32, 46, 52, 60];
	public static final minMania:Int = 0;
	public static final maxMania:Int = 8;
	public static final defaultMania:Int = 3;
	//E = Space
	//ABCD = Left Down Up Right
	//FGHI = LDUR 2

	public static final keysShit:Map<Int, Map<String, Dynamic>> = [
		0 => ["letters" => ["E"], "anims" => ["SPACE"],
			"strumAnims" => ["SPACE"], "pixelAnimIndex" => [4]],

		1 => ["letters" => ["A", "D"], "anims" => ["LEFT", "RIGHT"],
			"strumAnims" => ["LEFT", "RIGHT"], "pixelAnimIndex" => [0, 3]],

		2 => ["letters" => ["A", "E", "D"], "anims" => ["LEFT", "SPACE", "RIGHT"],
			"strumAnims" => ["LEFT", "SPACE", "RIGHT"], "pixelAnimIndex" => [0, 4, 3]],

		3 => ["letters" => ["A", "B", "C", "D"], "anims" => ["LEFT", "DOWN", "UP", "RIGHT"],
			"strumAnims" => ["LEFT", "DOWN", "UP", "RIGHT"], "pixelAnimIndex" => [0, 1, 2, 3]],

		4 => ["letters" => ["A", "B", "E", "C", "D"], "anims" => ["LEFT", "DOWN", "SPACE", "UP", "RIGHT"],
			 "strumAnims" => ["LEFT", "DOWN", "SPACE", "UP", "RIGHT"], "pixelAnimIndex" => [0, 1, 4, 2, 3]],

		5 => ["letters" => ["A", "C", "D", "F", "B", "I"], "anims" => ["LEFT", "UP", "RIGHT", "LEFT", "DOWN", "RIGHT"],
			 "strumAnims" => ["LEFT", "UP", "RIGHT", "LEFT", "DOWN", "RIGHT"], "pixelAnimIndex" => [0, 2, 3, 5, 1, 8]],

		6 => ["letters" => ["A", "C", "D", "E", "F", "B", "I"], "anims" => ["LEFT", "UP", "RIGHT", "SPACE", "LEFT", "DOWN", "RIGHT"],
			 "strumAnims" => ["LEFT", "UP", "RIGHT", "SPACE", "LEFT", "DOWN", "RIGHT"], "pixelAnimIndex" => [0, 2, 3, 4, 5, 1, 8]],
			
		7 => ["letters" => ["A", "B", "C", "D", "F", "G", "H", "I"], "anims" => ["LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"],
			 "strumAnims" => ["LEFT", "DOWN", "UP", "RIGHT", "LEFT", "DOWN", "UP", "RIGHT"], "pixelAnimIndex" => [0, 1, 2, 3, 5, 6, 7, 8]],
		
		8 => ["letters" => ["A", "B", "C", "D", "E", "F", "G", "H", "I"], "anims" => ["LEFT", "DOWN", "UP", "RIGHT", "SPACE", "LEFT", "DOWN", "UP", "RIGHT"],
			 "strumAnims" => ["LEFT", "DOWN", "UP", "RIGHT", "SPACE", "LEFT", "DOWN", "UP", "RIGHT"], "pixelAnimIndex" => [0, 1, 2, 3, 4, 5, 6, 7, 8]],
	];

	public static final ammo:Array<Int> = [1, 2, 3, 4, 5, 6, 7, 8, 9];
	public static final pixelScales:Array<Float> = [1.2, 1.15, 1.1, 1, 0.9, 0.83, 0.8, 0.74, 0.7];

	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var isSustainEnd:Bool = false;
	public var noteType(default, set):String = null;

	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var colorSwap:ColorSwap;
	public var inEditor:Bool = false;
	public var gfNote:Bool = false;
	public var strum:Int = 0; //used to sort the note to strums in playstate
	public var strumToFollow:StrumNote = null; //used when we need to make the note follow a strum
	private var earlyHitMult:Float = 0.6;

	public static final swagWidth:Float = 160 * 0.7;

	// Lua shit
	public var noteSplashDisabled:Bool = false;
	public var forceNoteSplash:Bool = false;
	public var noteSplashTexture:String = null;
	public var noteSplashHue:Float = 0;
	public var noteSplashSat:Float = 0;
	public var noteSplashBrt:Float = 0;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;

	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;
	public var copyVisible:Bool = true;
	public var copyScale:Bool = false;
	public var scaleHackHitbox:Bool = true;
	public var spawnTimeMult:Float = 1;

	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;
	public var rating:String = 'unknown';
	public var ratingDisabled:Bool = false;

	public var sustainScale:Float = 1;

	public var texture(default, set):String = null;

	public var noAnimation:Bool = false;
	public var hitCausesMiss:Bool = false;
	public var distance:Float = 2000;

	public var hitsoundDisabled:Bool = false;

	public var mania:Int = 3;

	var defaultWidth:Float = 0;
	var defaultHeight:Float = 0;

	private function set_texture(value:String):String {
		if (!PlayState.isPixelStage)
		{
			if (!Paths.noteSkinFramesMap.exists(value)) Paths.initNote(value);
			frames = @:privateAccess Paths.noteSkinFramesMap.get(value);
			animation.copyFrom(@:privateAccess Paths.noteSkinAnimsMap.get(value));
			antialiasing = ClientPrefs.settings.get("globalAntialiasing");
			if (inEditor) scale.set(0.7, 0.7);
				else scale.set(Note.scales[PlayState.mania], Note.scales[PlayState.mania]);
			updateHitbox();
		}
		texture = value;
		return value;
	}

	private function set_noteType(value:String):String {
		noteSplashTexture = PlayState.SONG.assets.splashSkin;
		if (ClientPrefs.settings.get("noteColor") == 'Default')
		{
			colorSwap.hue = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[noteData] % Note.ammo[mania])][0] / 360;
			colorSwap.saturation = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[noteData] % Note.ammo[mania])][1] / 100;
			colorSwap.brightness = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[noteData] % Note.ammo[mania])][2] / 100;	
		}
		if(noteData > -1 && noteType != value) {
			switch(value) {
				case 'Hurt Note':
					ignoreNote = mustPress;
					reloadNote('HURT', 'NOTE_assets');
					noteSplashTexture = 'splashes/HURTnoteSplashes';
					colorSwap.hue = colorSwap.saturation = colorSwap.brightness = 0;
					missHealth = (isSustainNote ? 0.1 : 0.3);
					hitCausesMiss = true;
				case 'No Animation':
					noAnimation = true;
				case 'GF Sing' | 'GF Cross Fade':
					gfNote = true;
				case 'Third Strum':
					strum = 2;
					spawnTimeMult = 2;
				#if MODS_ALLOWED
				case '' | 'Hey!' | 'Cross Fade' | 'Alt Animation' | 'Normal':
					//do nothing dumbass
				default:
					final prefix = value.split(" ")[0].toUpperCase();
					if (Paths.fileExists('images/${value.toUpperCase()}_assets.png', IMAGE)) {
						reloadNote(prefix, '_assets');
						colorSwap.hue = colorSwap.saturation = colorSwap.brightness = 0;
					}
				#end
			}
			noteType = value;
		}
		noteSplashHue = colorSwap.hue;
		noteSplashSat = colorSwap.saturation;
		noteSplashBrt = colorSwap.brightness;
		return value;
	}

	public function new(?inEditor:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		mania = PlayState.mania;

		this.inEditor = inEditor;

		y -= 2000;

		if(noteData > -1) {
			texture = Paths.defaultSkin;
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;

			x += swagWidth * (noteData % Note.ammo[mania]);
			if(!isSustainNote) {
				animation.play(Note.keysShit.get(mania).get('letters')[noteData % Note.ammo[mania]]);
			}
		}

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.65;
			multAlpha = 0.65;
			hitsoundDisabled = true;
			if(ClientPrefs.settings.get("downScroll")) flipY = true;
	
			offsetX += width / 2;
			copyAngle = false;
	
			animation.play('${Note.keysShit.get(mania).get('letters')[noteData]} tail');
			isSustainEnd = true;
			hitHealth = 0;
			missHealth = 0;
	
			updateHitbox();
	
			offsetX -= width / 2;
	
			if (PlayState.isPixelStage) offsetX += 30 * Note.pixelScales[mania];
	
			if (prevNote.isSustainNote)
			{
				prevNote.animation.play('${Note.keysShit.get(mania).get('letters')[prevNote.noteData]} hold');
				prevNote.isSustainEnd = false;
				prevNote.hitHealth = (0.023 / 2) / (PlayState.SONG.header.bpm / 150);
				prevNote.missHealth = (0.0475 / 2) / (PlayState.SONG.header.bpm / 150);
	
				prevNote.scale.y *= Conductor.stepCrochet / 100 * (PlayState.isPixelStage ? 1.05 : 1.055);
				if(PlayState.instance != null) prevNote.scale.y *= PlayState.instance.songSpeed;
	
				if(PlayState.isPixelStage) {
					prevNote.scale.y *= 1.19;
					prevNote.scale.y *= (6 / height); //Auto adjust note size
				}
				prevNote.updateHitbox();
			}
	
			if(PlayState.isPixelStage) {
				scale.y *= PlayState.daPixelZoom;
				updateHitbox();
			}
		} else if(!isSustainNote) {
			earlyHitMult = 1.2; //set this so that you can hit within like 210 ms or so (so you can wtf)
		}
		moves = false; //notes dont use velocity!
		x += offsetX;
	}

	var lastNoteOffsetXForPixelAutoAdjusting:Float = 0;
	var lastNoteScaleToo:Float = 1;
	public var originalHeightForCalcs:Float = 6;
	function reloadNote(?prefix:String = '', ?texture:String = '', ?suffix:String = '') {
		if(prefix == null) prefix = '';
		if(texture == null) texture = '';
		if(suffix == null) suffix = '';
		
		var skin:String = texture;
		if(texture.length < 1) {
			skin = PlayState.SONG.assets.arrowSkin;
			if(skin == null || skin.length < 1) skin = 'NOTE_assets';
		}

		var animName:String = null;
		if(animation.curAnim != null) animName = animation.curAnim.name;

		var arraySkin:Array<String> = skin.split('/');
		arraySkin[arraySkin.length-1] = prefix + arraySkin[arraySkin.length-1] + suffix;

		var lastScaleY:Float = scale.y;
		var blahblah:String = arraySkin.join('/');

		defaultWidth = 157;
		defaultHeight = 154;
		if(PlayState.isPixelStage) {
			if(isSustainNote) {
				//get yo nerdy ass outta here with your "width / 18" math mf
				originalHeightForCalcs = 12;
				loadGraphic(Paths.image('pixelUI/${blahblah}ENDS'), true, 7, 6);
			} else {
				loadGraphic(Paths.image('pixelUI/$blahblah'), true, 17, 17);
			}
			defaultWidth = width;
			setGraphicSize(Std.int(width * PlayState.daPixelZoom * Note.pixelScales[mania]));
			loadPixelNoteAnims();
			antialiasing = false;

			if(isSustainNote) {
				offsetX += lastNoteOffsetXForPixelAutoAdjusting;
				lastNoteOffsetXForPixelAutoAdjusting = (width - 7) * (PlayState.daPixelZoom / 2);
				offsetX -= lastNoteOffsetXForPixelAutoAdjusting;
			}
		} else {
			frames = Paths.getSparrowAtlas(blahblah);
			loadNoteAnims();
		}
		if(isSustainNote) scale.y = lastScaleY;
		updateHitbox();

		if(animName != null) animation.play(animName, true);

		if(inEditor) {
			setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
			updateHitbox();
		}
	}

	function loadNoteAnims()
    {
		for (letter in gfxLetter)
		{
			if (isSustainNote) {
				animation.addByPrefix('$letter hold', '$letter hold');
				animation.addByPrefix('$letter tail', '$letter tail');
			} else {
				animation.addByPrefix(letter, letter + '0');
			}
		}
		setGraphicSize(Std.int(defaultWidth * scales[mania]), (isSustainNote ? Std.int(defaultHeight * scales[0]) : 0));
		updateHitbox();
	}

	function loadPixelNoteAnims()
    {
		if(isSustainNote) {
			for (i=>letter in gfxLetter) {
				animation.add('$letter hold', [i]);
				animation.add('$letter tail', [i + 9]);
			}
		} else {
			for (i=>letter in gfxLetter) {
				animation.add(letter, [i + 9]);
			}
		}
	}

	public function applyManiaChange()
	{
		if (isSustainNote) 
			scale.y = 1;
		reloadNote(texture);
		if (isSustainNote)
			offsetX = width / 2;
		if (!isSustainNote)
		{
			var animToPlay:String = '';
			animToPlay = Note.keysShit.get(mania).get('letters')[noteData % Note.ammo[mania]];
			animation.play(animToPlay);
		}
	
		if (isSustainNote && prevNote != null)
		{
			animation.play(Note.keysShit.get(mania).get('letters')[noteData % Note.ammo[mania]] + ' tail');
			if (prevNote.isSustainNote)
			{
				//after some debugging, it appears prevNote has a null animation controller
				//why? no fucking clue
				if (prevNote.animation != null) {
					prevNote.animation.play(Note.keysShit.get(mania).get('letters')[noteData % Note.ammo[mania]] + ' hold');
					prevNote.updateHitbox();
				}
			}
		}
	
		updateHitbox();
	}
	public var correctionOffset:Int = 0;
	//remove later possibly??
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (mustPress)
		{
			canBeHit = (strumTime > Conductor.songPosition - Conductor.safeZoneOffset && strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult));
			tooLate = (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit);
		}
		else
		{
			//why is this updated every frame ??
			canBeHit = false;
		
			if (!(strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))) return;
			wasGoodHit = ((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition);
		}
	}

	public function followStrum(strum:StrumNote, fakeCrochet:Float, songSpeed:Float = 1):Void
	{
		if (isSustainNote) 
		{
			
			flipY = strum.downScroll;
			offsetX = 50 * Note.scales[PlayState.mania];
			scale.set(Note.scales[PlayState.mania], isSustainEnd ? 1 : Conductor.stepCrochet * 0.0105 * (songSpeed / spawnTimeMult) * sustainScale);
			if (PlayState.isPixelStage) 
			{
				scale.x *= PlayState.daPixelZoom;
				scale.y *= PlayState.daPixelZoom;
			}

			updateHitbox();
		}
			
		if (strum == null) noteData = PlayState.mania;
		distance = (0.45 * (Conductor.songPosition - strumTime) * songSpeed * spawnTimeMult);
		if (!strum.downScroll) distance *= -1;

						if(animation != null && animation.curAnim != null && animation.curAnim.name.endsWith('end'))
						{
							y -= height-2;
						}

		if (copyAngle)
			angle = strum.direction - 90 + strum.angle + offsetAngle;

		if(copyAlpha)
			alpha = strum.alpha * multAlpha;

		if(copyX)
			x = strum.x + offsetX + Math.cos(strum.direction * Math.PI / 180) * distance;

		if(copyY)
		{
			y = strum.y + offsetY + correctionOffset + Math.sin(strum.direction * Math.PI / 180) * distance;
			if(strum.downScroll && isSustainNote)
			{
				if(PlayState.isPixelStage)
				{
					y -= PlayState.daPixelZoom * 9.5;
				}
				y -= (frameHeight * scale.y) - (Note.swagWidth / 2);
			}
		}
	}

	public function clipToStrumNote(myStrum:StrumNote)
	{
		final center:Float = myStrum.y + offsetY + Note.swagWidth / 2;
		var flag1:Bool = (mustPress || !ignoreNote);
		var flag2:Bool = (!mustPress || (wasGoodHit || (prevNote.wasGoodHit && !canBeHit)));
		// Sys.println('${Std.string(wasGoodHit)}, ${Std.string(prevNote.wasGoodHit)}');
		if(flag1 && flag2)
		{
			final swagRect:FlxRect = clipRect != null ? clipRect : new FlxRect(0, 0, frameWidth, frameHeight);

			if (myStrum.downScroll)
			{
				if(y - offset.y * scale.y + height >= center)
				{
					swagRect.width = frameWidth;
					swagRect.height = (center - y) / scale.y;
					swagRect.y = frameHeight - swagRect.height;
				}
			}
			else if (y + offset.y * scale.y <= center)
			{
				swagRect.y = (center - y) / scale.y;
				swagRect.width = width / scale.x;
				swagRect.height = (height / scale.y) - swagRect.y;
			}
			clipRect = swagRect;
		}
	}

	@:noCompletion
	override function set_clipRect(rect:FlxRect):FlxRect
	{
		clipRect = rect;

		if (frames != null)
			frame = frames.frames[animation.frameIndex];

		return rect;
	}

	// this is used for note recycling
	public function setupNoteData(chartNoteData:PreloadedChartNote):Note
	{
		wasGoodHit = hitByOpponent = tooLate = canBeHit = false; // Don't make an update call of this for the note group

		strumTime = chartNoteData.strumTime;
		if(!inEditor) strumTime += ClientPrefs.settings.get("noteOffset");
		noteData = Std.int(chartNoteData.noteData % ammo[PlayState.mania]);
		noteType = chartNoteData.noteType;
		noAnimation = chartNoteData.noAnimation;
		mustPress = chartNoteData.mustPress;
		gfNote = chartNoteData.gfNote;
		isSustainNote = chartNoteData.isSustainNote;
		if (chartNoteData.noteskin.length > 0 && chartNoteData.noteskin != '' && chartNoteData.noteskin != texture) texture = 'noteskins/' + chartNoteData.noteskin;
		if (chartNoteData.texture.length > 0 && chartNoteData.texture != texture) texture = chartNoteData.texture;
		if (chartNoteData.texture.length < 1 && texture != Paths.defaultSkin) texture = Paths.defaultSkin;
		sustainLength = chartNoteData.sustainLength;

		strumToFollow = chartNoteData.strum;
		mania = chartNoteData.mania;
		hitHealth = chartNoteData.hitHealth;
		missHealth = chartNoteData.missHealth;
		hitCausesMiss = chartNoteData.hitCausesMiss;
		spawnTimeMult = chartNoteData.spawnTimeMult;
		isSustainEnd = chartNoteData.isSustainEnd;

		if (!isSustainEnd && isSustainNote)
		{
			hitHealth = (0.023 / 2) / (PlayState.SONG.header.bpm / 150);
			missHealth = (0.0475 / 2) / (PlayState.SONG.header.bpm / 150);
		}

		if (PlayState.isPixelStage) reloadNote('', texture);
		animation.play(Note.keysShit.get(mania).get('letters')[noteData % Note.ammo[mania]]);

		if (isSustainNote) {
			animation.play('${Note.keysShit.get(mania).get('letters')[noteData]}' + (chartNoteData.isSustainEnd ? ' tail' : ' hold'));
			correctionOffset = ClientPrefs.settings.get("downScroll") ? 0 : 55;
			alpha = multAlpha = 0.6;
		} else alpha = multAlpha = 1;

		if (ClientPrefs.settings.get("middleScroll") && !mustPress) alpha = multAlpha = 0.001;

		sustainScale = chartNoteData.sustainScale;

		switch(ClientPrefs.settings.get("noteColor"))
		{
			case 'Rainbow': colorSwap.hue = ((strumTime / 5000 * 360) / 360) % 1;
			case 'Default': 
			colorSwap.hue = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[noteData] % Note.ammo[mania])][0] / 360;
			colorSwap.saturation = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[noteData] % Note.ammo[mania])][1] / 100;
			colorSwap.brightness = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[noteData] % Note.ammo[mania])][2] / 100;
			default:			
		}

		clipRect = null;
		return this;
	}

	override function destroy() {
		shader = null;
		colorSwap = null;
		super.destroy();
	}
}

/**
* Basic class for all `StrumNote`s.
* This class is used to create the strum line.
*/
class StrumNote extends FlxSprite
{
	public var colorSwap:ColorSwap;
	public var resetAnim:Float = 0;
	public var noteData:Int = 0;
	public var direction:Float = 90;
	public var downScroll:Bool = false;
	public var sustainReduce:Bool = true;
	private var animationLengths:Array<Int> = [0, 0, 0];
	public var strum:Int = 0;
	
	private var player:Int;

	private var skinThing:Array<String> = ['static', 'pressed'];
	
	public var texture(default, set):String = null;
	inline private function set_texture(value:String):String {
		if(texture != value) {
			texture = value;
			reloadNote();
		}
		return value;
	}

	public function new(x:Float, y:Float, leData:Int, player:Int) {
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		noteData = leData;
		this.player = player;
		this.noteData = leData;
		super(x, y);

		var stat:String = Note.keysShit.get(PlayState.mania).get('strumAnims')[leData];
		var pres:String = Note.keysShit.get(PlayState.mania).get('letters')[leData];
		skinThing[0] = stat;
		skinThing[1] = pres;

		var skin:String = 'NOTE_assets';
		if(PlayState.SONG.assets.arrowSkin != null && PlayState.SONG.assets.arrowSkin.length > 1) skin = PlayState.SONG.assets.arrowSkin;
		texture = skin; //Load texture and anims

		scrollFactor.set();
		moves = false;
	}

	public function reloadNote()
	{
		var lastAnim:String = null;
		if(animation.curAnim != null) lastAnim = animation.curAnim.name;

		if(PlayState.isPixelStage)
		{
			if(ClientPrefs.settings.get("noteColor") == 'Default') {
				loadGraphic(Paths.image('pixelUI/$texture'), true, 17, 17);
			}
			if(ClientPrefs.settings.get("noteColor") == 'Greyscale') {
				loadGraphic(Paths.image('pixelUI/GREYSCALE_$texture'), true, 17, 17);
			}
			if(ClientPrefs.settings.get("noteColor") == 'Rainbow') {
				loadGraphic(Paths.image('pixelUI/RED_$texture'), true, 17, 17);
			}
			var daFrames:Array<Int> = Note.keysShit.get(PlayState.mania).get('pixelAnimIndex');

			setGraphicSize(Std.int(width * PlayState.daPixelZoom * Note.pixelScales[PlayState.mania]));
			updateHitbox();
			antialiasing = false;
			animation.add('static', [daFrames[noteData]]);
			animation.add('pressed', [daFrames[noteData] + 9, daFrames[noteData] + 18], 12, false);
			animation.add('confirm', [daFrames[noteData] + 27, daFrames[noteData] + 36], 24, false);
		}
		else
		{
			frames = Paths.getSparrowAtlas(texture);

			setGraphicSize(Std.int(width * Note.scales[PlayState.mania]));
			antialiasing = ClientPrefs.settings.get("globalAntialiasing");
		
			animation.addByPrefix('static', 'arrow' + skinThing[0]);
			animation.addByPrefix('pressed', skinThing[1] + ' press', 24, false);
			animation.addByPrefix('confirm', skinThing[1] + ' confirm', 24, false);
		}
		for (i=>anim in ['static', 'pressed', 'confirm'])
			animationLengths[i] = (animation.getByName(anim) != null ? animation.getByName('pressed').numFrames : 1);

		updateHitbox();

		if(lastAnim != null) playAnim(lastAnim, true);
		animation.callback = function(name:String, frameNumber:Int, frameIndex:Int) {
			if (name != 'confirm') return;
			centerOrigin();
		}
	}

	public function postAddedToGroup() {
		playAnim('static');
		switch (PlayState.mania)
		{
			case 0 | 1 | 2: x += width * noteData;
			case 3: x += (Note.swagWidth * noteData);
			default: x += ((width - Note.lessX[PlayState.mania]) * noteData);
		}

		x += Note.xtra[PlayState.mania];
	
		x += 50;
		x += ((FlxG.width / 2) * player);
		ID = noteData;
		x -= Note.posRest[PlayState.mania];
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (resetAnim <= 0) return;

		resetAnim -= elapsed;
		if(resetAnim <= 0) {
			playAnim('static');
			resetAnim = 0;
		}
	}

	override function destroy() {
		shader = null;
		colorSwap = null;
		super.destroy();
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		centerOffsets();
		centerOrigin();
		active = true;
		//hopefully makes it not fuck up animations for custom notes lol
		if (animation.curAnim != null) {
			switch (animation.curAnim.name) {
				case 'static': if (animationLengths[0] < 2) active = false;
				case 'confirm': if (animationLengths[1] < 2) active = false;
				case 'pressed': if (animationLengths[2] < 2) active = false;
			}
		} else {
			active = false;
		}

		if(animation.curAnim == null || animation.curAnim.name == 'static') {
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;
		} else {
			colorSwap.hue = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(PlayState.mania).get('pixelAnimIndex')[noteData] % Note.ammo[PlayState.mania])][0] / 360;
			colorSwap.saturation = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(PlayState.mania).get('pixelAnimIndex')[noteData] % Note.ammo[PlayState.mania])][1] / 100;
			colorSwap.brightness = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(PlayState.mania).get('pixelAnimIndex')[noteData] % Note.ammo[PlayState.mania])][2] / 100;

			if (PlayState.isPixelStage) return;
			if(animation.curAnim.name == 'confirm')
				centerOrigin();
		}
	}
}

/**
* Basic class for all `NoteSplash`s.
*/
class NoteSplash extends FlxSprite
{
	public var colorSwap:ColorSwap = null;
	private var idleAnim:String;
	private var textureLoaded:String = null;

	var sc:Array<Float> = [1.3, 1.2, 1.1, 1, 1, 0.9, 0.8, 0.7, 0.6];

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0) {
		super(x, y);

		var skin:String = 'splashes/noteSplashes';
		if(PlayState.SONG.assets.splashSkin != null && PlayState.SONG.assets.splashSkin.length > 0) skin = PlayState.SONG.assets.splashSkin;

		loadAnims(skin);
		
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		setupNoteSplash(x, y, note);
		moves = false;
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0) {
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		if (PlayState.isPixelStage) {
			setGraphicSize(Std.int(width * PlayState.daPixelZoom * sc[PlayState.mania]));
			antialiasing = false;
			setPosition((x + 150) - Note.swagWidth * 0.95, (y + 150) - Note.swagWidth);
		} else {
			setGraphicSize(Std.int(width * sc[PlayState.mania]));
		}

		alpha = 0.6;

		if(texture == null) {
			if(ClientPrefs.settings.get("noteColor") == 'Default') {
				texture = (PlayState.isPixelStage ? 'splashes/pixelSplashes' : 'splashes/noteSplashes');
			}
			if(ClientPrefs.settings.get("noteColor") == 'Greyscale') {
				texture = (PlayState.isPixelStage ? 'splashes/GREYSCALE_pixelSplashes' : 'splashes/GREYSCALE_noteSplashes');
			}
			if(ClientPrefs.settings.get("noteColor") == 'Rainbow') {
				texture = (PlayState.isPixelStage ? 'splashes/RED_pixelSplashes' : 'splashes/RED_noteSplashes');
			}
			if(PlayState.SONG.assets.splashSkin != null && PlayState.SONG.assets.splashSkin.length > 0) texture = PlayState.SONG.assets.splashSkin;
		}

		if(textureLoaded != texture) loadAnims(texture);
		colorSwap.hue = hueColor;
		colorSwap.saturation = satColor;
		colorSwap.brightness = brtColor;

		offset.set(-34 * Note.scales[PlayState.mania], -23 * Note.scales[PlayState.mania]);
		if (PlayState.isPixelStage || texture != 'splashes/noteSplashes') offset.set(14 / Note.scales[PlayState.mania], 14 / Note.scales[PlayState.mania]);

		var fps:Int = (texture == 'splashes/pixelSplashes' ? 42 : 24);
		animation.play('note' + Note.keysShit.get(PlayState.mania).get('pixelAnimIndex')[note] + '${(texture == 'splashes/noteSplashes' ? '-${FlxG.random.int(1,2)}' : '')}', true, false);
		if(animation.curAnim != null) {
			animation.curAnim.frameRate = fps + FlxG.random.int(-2, 2);
		}
		animation.finishCallback = name -> {
			kill();
			if (PlayState.instance != null) PlayState.instance.grpNoteSplashes.remove(this, true);
			destroy();
		}
	}

	function loadAnims(skin:String) {
		frames = Paths.getSparrowAtlas(skin);
		var usingDefault:Bool = (skin == 'splashes/noteSplashes');
		for (i in 0...9) {
			animation.addByPrefix('note$i${usingDefault ? '-1' : ''}', 'note splash ${Note.keysShit.get(8).get('letters')[i]} ${usingDefault ? '1 ' : ''}', 24, false);
			if (!usingDefault) continue;
			animation.addByPrefix('note$i-2', 'note splash ${Note.keysShit.get(8).get('letters')[i]} 2 ', 24, false);
		}
	}

	override function destroy() {
		shader = null;
		colorSwap = null;
		super.destroy();
	}
}