@echo off
cd ..
haxelib newrepo
echo Installing and updating libraries.
haxelib install flixel-addons 3.0.2
haxelib install flixel-ui 2.5.0
haxelib install flxanimate 3.0.4
haxelib install hscript
haxelib install hxCodec 2.6.1
haxelib install hxcpp-debug-server
haxelib remove discord_rpc
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib remove hxcpp
haxelib git hxcpp https://github.com/HaxeFoundation/hxcpp
haxelib remove linc_luajit
haxelib git linc_luajit https://github.com/nebulazorua/linc_luajit
echo Libraries installed and updated.
pause
echo Setting up Flixel.
haxelib install lime 8.1.0
haxelib install openfl 9.2.1
haxelib install flixel 5.2.2
haxelib run lime setup
echo Flixel setup complete.
echo Installing Microsoft Visual Studio Community (Dependency)
curl -# -O https://download.visualstudio.microsoft.com/download/pr/3105fcfe-e771-41d6-9a1c-fc971e7d03a7/8eb13958dc429a6e6f7e0d6704d43a55f18d02a253608351b6bf6723ffdaf24e/vs_Community.exe
vs_Community.exe --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 -p
del vs_Community.exe
echo Finished.
pause
