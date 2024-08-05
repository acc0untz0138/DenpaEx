package;

import Conductor.BPMChangeEvent;
import flixel.FlxSubState;
import mobile.flixel.FlxHitbox;
import mobile.flixel.FlxVirtualPad;
import flixel.FlxCamera;
import flixel.input.actions.FlxActionInput;
import flixel.util.FlxDestroyUtil;

/**
* Basic substate to use for substates in the game.
* Contains beat/step functions.
*/
class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
		curInstance = this;
	}

	@:allow(stats.DebugDisplay)
	private var curStep:Int = 0;
	@:allow(stats.DebugDisplay)
	private var curBeat:Int = 0;
	
	private var controls(get, never):Controls;
	public static var curInstance:MusicBeatSubstate = null;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	var hitbox:FlxHitbox;
	var virtualPad:FlxVirtualPad;
	var trackedInputsVirtualPad:Array<FlxActionInput> = [];

	public function addVirtualPad(DPad:FlxDPadMode, Action:FlxActionMode, visible:Bool = true):Void
	{
		if (virtualPad != null)
			removeVirtualPad();

		virtualPad = new FlxVirtualPad(DPad, Action);
		virtualPad.visible = visible;
		add(virtualPad);

		controls.setVirtualPad(virtualPad, DPad, Action);
		trackedInputsVirtualPad = controls.trackedInputs;
		controls.trackedInputs = [];
	}

	public function addVirtualPadCamera(DefaultDrawTarget:Bool = false):Void
	{
		if (virtualPad != null)
		{
			var camControls:FlxCamera = new FlxCamera();
			camControls.bgColor.alpha = 0;
			FlxG.cameras.add(camControls, DefaultDrawTarget);
			virtualPad.cameras = [camControls];
		}
	}

	public function removeVirtualPad():Void
	{
		if (trackedInputsVirtualPad.length > 0)
			controls.removeVirtualControlsInput(trackedInputsVirtualPad);

		if (virtualPad != null)
			remove(virtualPad);
	}

	public function addHitbox(visible:Bool = true):Void
	{
		final ammo:Int = PlayState.mania + 1;
		if (hitbox != null)
			removeHitbox();

		hitbox = new FlxHitbox(ammo, Std.int(FlxG.width / ammo), FlxG.height);
		hitbox.visible = visible;
		add(hitbox);
	}

	public function addHitboxCamera(DefaultDrawTarget:Bool = false):Void
	{
		if (hitbox != null)
		{
			var camControls:FlxCamera = new FlxCamera();
			camControls.bgColor.alpha = 0;
			FlxG.cameras.add(camControls, DefaultDrawTarget);
			hitbox.cameras = [camControls];
		}
	}

	public function removeHitbox():Void
		if (hitbox != null)
			remove(hitbox);

	override function destroy():Void
	{
		if (trackedInputsVirtualPad.length > 0)
			controls.removeVirtualControlsInput(trackedInputsVirtualPad);

		super.destroy();

		if (virtualPad != null)
			virtualPad = FlxDestroyUtil.destroy(virtualPad);

		if (hitbox != null)
			hitbox = FlxDestroyUtil.destroy(hitbox);
	}

	override function update(elapsed:Float)
	{
		var oldStep:Int = curStep;

		updateCurStep();
		curBeat = Math.floor(curStep / 4);

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
	
	override public function close() {
		curInstance = null;
		super.close();
	}
}
