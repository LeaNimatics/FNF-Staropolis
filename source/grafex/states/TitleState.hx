package grafex.states;

import grafex.system.statesystem.MusicBeatState;
import grafex.system.Conductor;

import grafex.sprites.Alphabet;

import grafex.effects.shaders.ColorSwap;
import grafex.effects.ColorblindFilters;

import grafex.states.MainMenuState;
import grafex.states.substates.PrelaunchingState;

import grafex.util.PlayerSettings;
import grafex.util.ClientPrefs;
import grafex.util.Highscore;
import grafex.util.Utils;

import flixel.FlxG;
import flixel.addons.effects.FlxTrail;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import grafex.data.WeekData;
import openfl.display.BitmapData;
import sys.FileSystem;
import sys.io.File;
import flixel.addons.display.FlxBackdrop;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import lime.ui.WindowAttributes;

import haxe.ds.StringMap;

import grafex.system.script.GrfxScriptHandler;

using StringTools;

using flixel.util.FlxSpriteUtil;

class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;

	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	public var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var mustUpdate:Bool = false;
	
	public static var updateVersion:String = '';

	public var switchTime:Float = 1;

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

        switchTime = 1;

        FlxG.worldBounds.set(-500, -500, FlxG.width + 500, FlxG.height + 500);

		PlayerSettings.init();

		#if LUA_ALLOWED
		Paths.pushGlobalMods();
		#end

		Application.current.window.title = Main.appTitle;
		WeekData.loadTheFirstEnabledMod();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		super.create();

		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = true;
		
		FlxG.mouse.load(Paths.image("cursor").bitmap, 1, 0, 0); // Huh? - PurSnake

		#if desktop
		DiscordClient.initialize();
		Application.current.onExit.add (function (exitCode) {
			DiscordClient.shutdown();
		});
		#end
		if (initialized)
			startIntro();
		else
		{
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				startIntro();
			});
		} 
	}

	var bg:FlxSprite;
	var logo:FlxSprite;
	var doodly:FlxSprite;
	var enter:FlxSprite;
	var mellow:FlxSprite;
	var lea:FlxSprite;
	var listSprite:FlxSpriteGroup;

	function startIntro()
	{
		ColorblindFilters.applyFiltersOnGame();
        if(!initialized && FlxG.sound.music == null) FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

		persistentUpdate = true;

		listSprite = new FlxSpriteGroup();
		add(listSprite);

		bg = new FlxSprite(-687, -349);
		bg.loadGraphic(Paths.image('titlescreen/Alley'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		listSprite.add(bg);

		doodly = new FlxSprite(-318, -147);
		doodly.frames = Paths.getSparrowAtlas('titlescreen/Icons');
		doodly.animation.addByPrefix('doodle', 'Icons', 24, true);
		doodly.animation.play('doodle');		
		listSprite.add(doodly);

		logo = new FlxSprite(0, -109);
		logo.frames = Paths.getSparrowAtlas('titlescreen/FakeLogo');
		logo.animation.addByPrefix('logo', 'FakeLogoIdle', 24, true);
		logo.animation.play('logo');
		listSprite.add(logo);

		mellow = new FlxSprite(-60, 66);
        mellow.frames = Paths.getSparrowAtlas('titlescreen/Mellow');
		mellow.animation.addByPrefix('mellow', 'IdleMellow', 24, true);
		listSprite.add(mellow);

		lea = new FlxSprite(565, 125);
		lea.frames = Paths.getSparrowAtlas('titlescreen/Leanimatics');
		lea.animation.addByPrefix('lea', 'LéaIdle', 24, true);
		listSprite.add(lea);

		enter = new FlxSprite(430, 466);
		enter.frames = Paths.getSparrowAtlas('titlescreen/Enter');
        enter.animation.addByPrefix('enter', 'EnterIdle', 24, true);
		enter.animation.play('enter');
        listSprite.add(enter);

		if (listSprite != null){
			listSprite.forEach(function(spr:FlxSprite){
				spr.scale.set(0.65, 0.65);
				spr.antialiasing = ClientPrefs.globalAntialiasing;
			});
		}

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		//credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true; 
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var timer:Float = 0;
	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (mellow != null){
			FlxG.watch.addQuick("mellow.x", mellow.x);
			FlxG.watch.addQuick("mellow.y", mellow.y);
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;
		}

		if (initialized && !transitioning && skippedIntro)
		{		
			if(pressedEnter)
			{
				FlxG.camera.flash(ClientPrefs.flashing ? 0xFFFFFFFF : 0x4CFFFFFF, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);		
                           			
				transitioning = true;
				new FlxTimer().start(switchTime, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new MainMenuState());
					closedState = true;
				});
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		call("onUpdatePost", [elapsed]);
	}

	public function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
			money.y -= 350;
			FlxTween.tween(money, {y: money.y + 350}, 0.3, {ease: FlxEase.expoOut, startDelay: 0.0});
		}
	}

	public function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
			coolText.y += 750;
		    FlxTween.tween(coolText, {y: coolText.y - 750}, 0.3, {ease: FlxEase.expoOut, startDelay: 0.0});
		}
	}

	public function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function stepHit()
	{
		super.stepHit();
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();
		if (lea != null) lea.animation.play('lea');
		if (mellow != null) mellow.animation.play('mellow');

		if(!closedState) {
			sickBeats++;
			coolTextBeat(sickBeats);
		}
	}

	function coolTextBeat(beats:Int)
	{
		switch (beats)
		{
			case 1:
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				FlxG.sound.music.fadeIn(4, 0, 0.7);
			case 2:
				createCoolText(['PurSnake']);
			case 4:
				addMoreText('present');
			case 5:
				deleteCoolText();
			case 6:
				createCoolText(['In memory', 'of'], -40);
			case 8:
				addMoreText('my penis', -40);
			case 9:
				deleteCoolText();
			case 10:
				createCoolText([curWacky[0]]);
			case 12:
				addMoreText(curWacky[1]);
			case 13:
				deleteCoolText();
			case 14:
				addMoreText('Friday');
				addMoreText('Night');
				addMoreText('Funkin');
			case 15:
				addMoreText('Grafex');
			case 16:
				addMoreText('Engine');
			case 17:
				skipIntro();
		}
	}

	override function sectionHit()
	{
		super.sectionHit();
	}

	override function destroy() {
		super.destroy();
	}

	public static function getGameIconPath()
	{
		#if (desktop && MODS_ALLOWED)
		var path = "mods/" + Paths.currentModDirectory + "/images/icon.png";
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)) {
			path = "mods/images/icon.png";
		}
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)) {
			path = "assets/images/icon.png";
		}
		trace(path, FileSystem.exists(path));
		#else
		var path = Paths.getPreloadPath("images/icon.png");
		#end
		return path;
	}
	
	var skippedIntro:Bool = false;

	public function skipIntro():Void
	{
		if (!skippedIntro)
		{
			FlxG.camera.flash(FlxColor.WHITE, 4);
		}
		if (!skippedIntro)
		{
			skippedIntro = true;
			remove(credGroup);
		}
	}
}
