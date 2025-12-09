How to compile:

Go to https://github.com/JordanSantiagoYT/FNF-JS-Engine/tree/main/setup and if you're on windows, download https://github.com/JordanSantiagoYT/FNF-JS-Engine/blob/main/setup/windows-msvc.bat and run it. It will download a verified applicaton from microsoft with requirements required to follow the next step.
Next, download https://github.com/JordanSantiagoYT/FNF-JS-Engine/blob/main/setup/windows.bat (windows) or https://github.com/JordanSantiagoYT/FNF-JS-Engine/blob/main/setup/unix.sh (linux) (moible has been cancled by these creators due to drama)...
After they're done, go to https://haxe.org/download and https://git-scm.com/downloads to download the last requirements, note that you should download the required versions listed. As for the build ingredients, they're forked from specific verions. For example:
OpenFL downgraded to 9.3.3, 9.4.0 caused some shaders to implode...
Changed the Lime version from 8.2.0 to 8.1.3 as we found out Lime 8.2.0 has worse performance: https://github.com/openfl/lime/issues/1853

For windows (I don't know much about Linux), you'll likely need to download and install "hxCodec" before the game can run. But first, I think we can safely compile the Anti-Crash Engine (required).
If you downloaded directly in downloads folder and extracted here, you'll want to go to (username)\Downloads\DenpaEx-master\crshhndlr -> right click -> Open in Terminal
run "lime test windows" and wait for the crash handler to open...

Not so fast, we still have to install hxCodec... Go to https://lib.haxe.org/p/hxCodec and copy the command... For the most standard download, you wanna press WIN + R and type in cmd so it opens up standardly. don't worry you're only instaling hxCodec, it's perfectly safe and needed to compile DempaEx.exe.

Now right click in (username)\Downloads\DenpaEx-master -> Open in Terminal
run "lime test windows"

Optional: You can download JS Engine debug file from https://github.com/AmadeyHunter/BackUp/blob/main/Open%20me%20to%20use%20the%20debug%20terminal.bat (me who make this file based of their's and compiling expirence), I even changed it so it works for DenpaEx as it should work for any Psych Engine Version (for 0.7 and v1 idk)...

One thing I noyticed is you need "discord_rpc" downloaded manually instead... Don't worry, it's the same as hxCodec: https://lib.haxe.org/p/discord_rpc
