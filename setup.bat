@echo off
color 0a
cd ..
@echo on
echo Installing dependencies.
haxelib newrepo
haxelib install lime 8.0.1
haxelib install openfl 9.2.2
haxelib install flixel 4.11.0
haxelib install flixel-addons 3.0.2
haxelib install flixel-ui 2.5.0
haxelib install flixel-tools 1.5.1
haxelib git hxCodec https://github.com/polybiusproxy/hxCodec.git
haxelib install tjson
haxelib git flxanimate https://github.com/ShadowMario/flxanimate dev
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc.git
haxelib git hscript-improved https://github.com/FNF-CNE-Devs/hscript-improved
echo Finished!
pause