# Guild Wars Installation Guide for Linux


## Table of Contents
- **[Part 0: About This Guide](#part-0-about-this-guide)**
- **[Part 1: What About Steam/Lutris/Etc.?](#part1-what-about-steam-lutris-etc)**
- **[Part 2: About Environment Variables and Bash Scripts](#part-2-about-environment-variables-and-bash-scripts)**
- **[Part 3: Setting Up 32-Bit Support](#part-3-setting-up-32-bit-support)**
- **[Part 4: Choosing a Wine Fork](#part-4-choosing-a-wine-fork)**
- **[Part 5: Basic Guild Wars Installation](#part-5-basic-guild-wars-installation)**
- **[Part 6: FPS Control](#part-6-fps-control)**
- **[Part 7: DXVK](#part-7-dxvk)**
- **[Part 8: ESYNC/FSYNC/NTSYNC](#part-8-esyncfsyncntsync)**
- **[Part 9: TexMod/uMod/gMod](#part-9-texmodumodgmod)**
- **[Part 10: DirectSong](#part-11-directsong)**
- **[Part 11: DSOAL-GW1 (Deprecated)](#part-10-dsoal-gw1-deprecated)**
- **[Part 12: Toolbox](#part-12-toolbox)**
- **[Part 13: Chat Filter](#part-13-chat-filter)**
- **[Part 14: paw\*ned2](#part-14-pawned2)**
- **[Part 15: Multiboxing](#part-15-multiboxing)**
- **[Part 16: Solving Steam Headaches](#part-16-solving-steam-headaches)**




## Part 0: About This Guide

This is a guide for installing Guild Wars on Linux. It covers both the "bare bones" basic installation, and the "full bells and whistles" installation with a complete set of add-ons, and everything in between.

Unlike my previous guide on reddit, this guide resides on github. There are a few reasons for this: I'm hoping that github will make it easier to edit this document to keep it up to date, and also for others to contribute. I'm able to include the files for "extras" like uMod right here in the repo. I don't want to give reddit monetizeable content anymore.

## Part 1: What About Steam/Lutris/Etc.?

This guide does ***NOT*** recommend the use of Steam, Lutris, Heroic Launcher, Bottles, or any other "one click" solution for installing Guild Wars. While their apparent simplicity is appealing at first glance, they greatly increase the difficulty of getting add-ons to work, and increase complexity behind the scenes in an opaque way that makes troubleshooting more difficult.

Steam makes installing almost any add-on into a giant headache. DirectSong, Toolbox, and uMod are particularly miserable. While workarounds are presented in Part 16, it is better to just avoid these headaches in the first place.

Lutris and other "Steam wannabe" launchers incorporate Proton and the Steam runtime. This makes DirectSong much harder to set up. Also, Guild Wars has been known to crash when run under the Steam runtime without Steam itself, when it tries to run SteamAPI_Init() and fails. Due to the opacity here, I cannot confidentally suggest that any particular configuration is truly free of this bug, or will remain free of it through future updates. And, in general, runtimes should be avoided whenever possible because they add complexity and make troubleshooting harder.

An additional problem with Lutris and its ilk is that you must rely on recipes that were often written by someone who didn't really know what they were doing.

While Proton has historically offered better performance than ordinary wine, this is no longer the case. With DXVK installed and NTSYNC activated (see Parts 7 and 8), ordinary wine's performance is now on par with Proton. Perhaps ever superior insofar as mainline Proton doesn't have NTSYNC yet, and NTSYNC is supposed to be slightly faster than FSYNC. (Presently, to get NTSYNC in Proton, you need a custom fork of Proton and likely need to activate a kernel module, which Lutris, *et al.* cannot do for you.)

Because Lutris *et al.* obscure from you the details of what they're doing, it can be difficult or impossible to troubleshoot when something goes wrong. Issues that begin with "I did what you said, but only in Lutris, and it doesn't work" are subject to being closed without comment (or with grouchy comment) because they often cannot be diagnosed beyond "Lutris did something stupid."

If you really, really want a low effort solution, skip straight to Part 5. Assuming that you have wine installed correctly (covered in Parts 2-4), that will give you a basic Guild Wars installation in just 6 console commands. (If you can manage a tiny bit more effort, see Parts 7 and 8 for large performance gains.)


## Part 2: About Environment Variables and Bash Scripts

Wine depends on environment variables to set important parameters.

The `WINEPREFIX` environment variable tells wine which prefix to use. You must specify this *every* time you want to interact with the wine prefix you will be creating for Guild Wars.

The `WINEARCH` environment variable tells wine what Windows architecture to simulate when first setting up a wine prefix. In the past, you needed a 32-bit wine prefix for Guild Wars if you wanted to set up DirectSong. That is no longer the case. Currently, it is advised to use a 64-bit wine prefix for forward compatibility with the "new wow64 mode" (see Part 3). To set up a 64-bit prefix, either leave `WINEARCH` unset when first creating the  wine prefix, or set it to `win64`. (On wine >= 10.2, `wow64` will also create a 64-bit prefix.)

For wine >= 10.2, the `WINEARCH` environment variable is also used when running wine to tell wine to activate the "new wow64 mode" (see Part 3). To use the "new wow64 mode," you must specify `WINEARCH=wow64` *every* time you run wine.

This guide presents environment variables in a mix-and-match style. For one-off commands, environment variables are presented as part of the command, like so: `WINEPREFIX=~/.wine-gw some-command`. For a series of commands that will be executed in the same console window, environment variables are presented as export statements that set an environment variable for the lifetime of the console window, like so: `export WINEPREFIX=~/.wine-gw`. Unless context suggests otherwise, you should generally assume that all the instructions one part of this guide take place in the same console window, using the same exports.

After Guild Wars is fully set up, you may want to make a bash script to set all your environment variables and reduce everything to one click, then modify your Guild Wars desktop file (shortcut) to invoke your script.

Example script: start dhuum.sh, uMod, and Guild Wars, then inject Toolbox (using dll hook for uMod, with fps limit increased to 144):
```
#!/usr/bin/env bash

export WINEPREFIX=~/.wine-gw
export WINEDEBUG=-all

cd ~/.wine-gw/drive_c/Program\ Files\ \(x86\)/Guild\ Wars

bash dhuum.sh &
wine start /d "C:\Program Files (x86)\uMod" "C:\Program Files (x86)\uMod\uMod.exe" &
sleep 1
wine start /d "C:\Program Files (x86)\Guild Wars" "C:\Program Files (x86)\Guild Wars\Gw.exe" -fps 144 &
sleep 1
wine start /d "C:\Program Files (x86)\GWToolbox" "C:\Program Files (x86)\GWToolbox\GWToolbox.exe" /quiet
```

Sometimes Guild Wars may not exit cleanly, leaving behind a zombie process. You can use `dhuum.sh` from the "extras" directory of this repo to scan and kill `Gw.exe` if it becomes a zombie process, ensuring a clean exit. Download it into your Guild Wars installation directory and add it to your launcher script as shown in the example above.

**Aside:** Wondering what a "wine prefix" is, but too timid to ask? A wine prefix is essentially a *name* for a particular emulated Windows computer. It also names the directory where the files for that particular emulated computer reside. When you set the `WINEPREFIX` environment variable, you're telling wine which wine prefix -- which emulated Windows computer -- to run the command in. If the corresponding directory already exists, wine will use it; otherise, it will create it. In order for two programs -- say Guild Wars and Toolbox -- to be able to interact, they must be run within the same wine prefix. Conversely, programs running in independent wine prefixes -- say two copies of Guild Wars -- are oblivious to each other. Also, segregating programs into different wine prefixes allows for doing dll overrides and compatibility tweaks for the sake of one program without potentially breaking another.

## Part 3: Setting Up 32-Bit Support

This section covers general set-up for running 32-bit Windows programs via wine. There are two options: First, you can install all of the necessary 32-bit libraries needed to run 32-bit wine. Second, on versions of wine >= 10.2, you can use the "new wow64 mode" to run 32-bit Windows programs inside 64-bit Linux processes.

#### Option 1, Install 32-Bit Libraries:

**Note:** Unless Guild Wars is your very first foray into Linux gaming, you've probably already done this. If you have Steam installed, or can already play other 32-bit Windows games, then this is already done. In which case, you should skip this section.

Add i386 to multiarch:
```
sudo dpkg --add-architecture i386
sudo apt-get update
```
Install the 32-bit binaries for your graphics drivers.
For AMD (open source drivers) ([info](https://wiki.debian.org/AtiHowTo#A32-bit_support
)):
```
sudo apt-get install libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386
```
For nVidia (proprietary drivers) ([info](https://wiki.debian.org/NvidiaGraphicsDrivers#multiarch-install)):
```
sudo apt-get install nvidia-driver-libs:i386
```

Install Wine and its dependencies, both 64- and 32-bit, by following [the instructions at WineHQ](https://wiki.winehq.org/Download).

(Note: `sudo apt-get install --install-recommends winehq-XXX` may cause `sane-airscan` to be uninstalled and replaced with `sane-airscan:i386`. If this happens, just carry on with installing wine and then reinstall `sane-airscan` afterwards (which will remove `sane-airscan:i386`).

#### Option 2, New WOW64 Mode:

If you have wine >= 10.2, you may use the "new wow64 mode" to run 32-bit Windows programs inside 64-bit Linux processes. In this case, you do not need any 32-bit Linux system libraries. To use the "new wow64 mode," you must set the environment variable `WINEARCH=wow64` each time you invoke wine.


## Part 4: Choosing a Wine Fork

Many forks of wine exist, giving you many options you could use to run Guild Wars. This section will help you choose.

#### Recommended, Depends on Kernel:

Recent developments make it impossible to offer a good one-size-fits-all recommendation. For the time being, the recommended wine fork depends on your kernel:

- **If you are using your distro's stock kernel, and your kernel version is >=6.14,** then the recommendation is `wine` (or `wine-devel` or `wine-staging`) from the official repo at WineHQ. This is simple to set up, and offers performance on par with any other option, after setting up DXVK (see Part 7) and NTSYNC (see Part 8). Eventually, distros with older kernels will catch up and this recommendation will apply to everyone.

- **If you are using a backports/custom kernel, and your kernel version is >=6.14,** then the recommendation is a TkG or other custom wine build with NTSYNC support, such as Kron4ek's `wine-{version}-staging-tkg-amd64-wow64` [builds](https://github.com/Kron4ek/Wine-Builds/releases). A big set of users to whom this applies is Debian Trixie (stable) with a backported kernel. See below for how to set up unpackaged wine.

- **If your kernel version is \<6.14,** then the recommendation is a TkG or other custom wine build that still has ESYNC or FSYNC support, such as Kron4ek's `wine-{version}-staging-tkg-fsync-amd64-wow64` [builds](https://github.com/Kron4ek/Wine-Builds/releases/tag/10.17), or old versions of wine prior to 10.16. See below for how to set up unpackaged wine.

#### Other Options:

- "Distro" wine. Wine packaged by your Linux distribution. This is almost always an outdated version of official wine. There's pretty much no reason to ever use this. Reconfigure your package manager to use the official repo for wine.
- "TkG" wine. A custom build of wine that usually has the "staging" patches, plus a few other popular patches. For example, [Kron4ek's TkG builds](https://github.com/Kron4ek/Wine-Builds). The main selling point over official `wine-staging` is NTSYNC on distros where the official `wine-staging` doesn't support it (e.g., Debian Trixie with backports kernel), or still being able to use ESYNC/FSYNC with old kernels. (See Part 8.)
- Proton, inside Steam. A version of wine made by Valve for Steam featuring gaming/performance modifications. It is possible to add Guild Wars to Steam as a "non-Steam game." This is not recommended because Steam makes it difficult to run uMod and Toolbox in the same wine prefix, and very painful to install DirectSong. (See Part 16.)
- Proton, outside Steam. It is possible to run Proton, or wine with Proton-like modifications, outside of Steam. In the past, this was recommended for maximum performance. However, Proton no longer offers superior performance, and Proton outside Steam is no longer recommended due to headaches installing DirectSong, and the Guild Wars crash bug noted in Part 1. If you really want to run Guild Wars in Proton outside of Steam, then a fork that does *not* use the Steam runtime is recommended, such as [Kron4ek's Proton builds](https://github.com/Kron4ek/Wine-Builds) (which do not use the Steam runtime), or the outdated [last build of Wine-GE](https://github.com/GloriousEggroll/wine-ge-custom/releases/tag/GE-Proton8-26) from 2/2024. Umu is not recommended. 

#### Installing Packaged Wine

To install Wine and its dependencies, follow [the instructions at WineHQ](https://wiki.winehq.org/Download).

#### Installing Unpackaged Wine

Before installing an unpackaged wine build, first install a packaged version of wine (either WineHQ or distro wine) so that the necessary dependencies are installed.

To install an unpackaged wine build, extract the binaries somewhere, and invoke wine with the environment variables explained below.

It is possible to have more than one version of wine present on your system. By default, whichever version is installed as `/usr/bin/wine` is what will run when the `wine` command is invoked. Usually this will be "official" WineHQ wine (or "distro" wine). If you want to run a version of wine other than the one at `/usr/bin/wine` (for example, an unpackaged TkG build), you can do that via environment variables, like so:
```
export WINEVERPATH={top-level-wine-directory}
export WINELOADER={top-level-wine-directory}/bin/wine
export WINESERVER={top-level-wine-directory}/bin/wineserver
export WINEDLLPATH={top-level-wine-directory}/lib/wine/x86_64-windows/:{top-level-wine-directory}/lib/wine/i386-windows/
export LD_LIBRARY_PATH={top-level-wine-directory}/lib/wine/x86_64-unix/:{top-level-wine-directory}/lib/wine/i386-unix/
export PATH={top-level-wine-directory}/bin:$PATH
# this last one's for winetricks
export WINE={top-level-wine-directory}/bin/wine
```
(Note: Releases of custom wine are not consistent about their directory structures. You may need to make adjustments. WINEDLLPATH should point to directories that contain .dll files. LD_LIBRARY_PATH should point to directories that contain .so files. Neither of these are recursive; you must specify the directory immediately containing the files.)

Additionally, Proton expects the Steam runtime environment. For versions 1.0 and 2.0 of the Steam runtime environment, this could be accomplished through a very complicated configuration for `LD_LIBRARY_PATH`. For Steam runtime 3.0, you pretty much need umu launcher (which, as explained above, is not recommended for Guild Wars). If your system is reasonably similar to whatever version of Ubuntu LTS Steam runtime is based on, you may be able to run Proton without the Steam runtime.


## Part 5: Basic Guild Wars Installation

This is a basic installation of Guild Wars. Do this first to make sure that things are fundamentally working. (Note: These instructions use a 64-bit wine prefix.)

```
export WINEARCH=win64
export WINEPREFIX=~/.wine-gw
winecfg
mkdir ~/.wine-gw/drive_c/temp
```
Download client from [https://www.guildwars.com/en/download](https://www.guildwars.com/en/download) to `~/.wine-gw/drive_c/temp`.
```
wine start /d "C:\temp" "C:\temp\GwSetup.exe"
```
Test that GW runs:
```
wine start /d "C:\Program Files (x86)\Guild Wars" "C:\Program Files (x86)\Guild Wars\Gw.exe"
```
Do not be alarmed if you encounter missing sound/music/graphics. It may not have been downloaded yet.
Run GW with the -image switch to download a full dat file.
```
wine start /d "C:\Program Files (x86)\Guild Wars" "C:\Program Files (x86)\Guild Wars\Gw.exe" -image
```
After downloading a full dat, conduct a more thorough play test to verify GW is working.

**Note:** Guild Wars stores its build templates and screenshots directories in different places depending on the version of Windows. You may want to symlink these locations together so you can switch Windows versions without issue.

Move anything inside `~/.wine-gw/drive_c/Program\ Files/Guild\ Wars/Templates` and `~/.wine-gw/drive_c/Program\ Files/Guild\ Wars/Screens` to the equivalent directories in `~/Documents`, then delete them. Now, make symlinks:
```
ln -s ~/Documents/Guild\ Wars/Templates/ ~/.wine-gw/drive_c/Program\ Files\ \(x86\)/Guild\ Wars/Templates
ln -s ~/Documents/Guild\ Wars/Screens/ ~/.wine-gw/drive_c/Program\ Files\ \(x86\)/Guild\ Wars/Screens
```

## Part 6: FPS Control
Recent Guild Wars updates fixed a serious bug by imposing a conservative fps limit. However, you may wish to override this limit if you have a high-refresh-rate monitor or want to use mailbox present mode (a/k/a "fast vsync") with a 60Hz monitor (see Part 7). To change the FPS limit, run Gw.exe with the `-fps <number>` command line parameter. Like so:
```
wine start /d "C:\Program Files (x86)\Guild Wars" "C:\Program Files (x86)\Guild Wars\Gw.exe" -fps 144
```
When launching Gw.exe via another program, such as uMod, Steam, GW Launcher, or Injectory, there should be an option for passing line parameters to `Gw.exe`.

**Background Information:** Historically Guild Wars has suffered from a bug where, at very high framerates, players/heroes/henchmen/monsters/minipets/NPCs would appear to "teleport" from one place to another without visibly walking through the space in between. This issue is caused in part by threading issues in the client (letting the graphics loop run full tilt starves the network loop of CPU) and in part by the client's game world logic simulation running too far ahead of the server's and going out of sync. A 180 fps limit was added in the 4/15/2025 patch, and, when that proved insufficient, the limit was lowered to 90 fps in the 4/29/2025 patch. The point where problems begin to appear seems to vary with hardware (and probably also geographic distance from the server). Historically many users have reported 144 as the highest "safe" fps, but some users have encounted problems at lower fps, and some users have run (much) higher fps with no problems. 

## Part 7: DXVK

[DXVK](https://github.com/doitsujin/dxvk) is a translation layer from Direct3D 8/9/10/11 to Vulkan. It offers a *tremendous* performance increase over wine's default DirectX-to-OpenGL translation. It also offers some graphical enhancements (see below) and enables/improves compatibility with various Vulkan-related things like [gamescope](https://github.com/ValveSoftware/gamescope), [MangoHUD](https://github.com/flightlessmango/MangoHud), and [vkBasalt](https://github.com/DadSchoorse/vkbasalt). (While DXVK gives a huge performance boost, Guild Wars still runs acceptably well on most systems without it.)

Note that, since DXVK translates into Vulkan, it requires a GPU/drivers with adequate Vulkan support. While every relatively recent GPU (including intergrated graphics) will suffice, some older devices might not be able to run DXVK. If in doubt, see [here](https://github.com/doitsujin/dxvk/wiki/Driver-support). (For older hardware that lacks sufficient Vulkan support, Gallium Nine may serve as an alternative to DXVK. However, this may require running an old version of Mesa, as Gallium Nine support in Mesa will soon be deprecated and removed.)

Download [the latest relase of DXVK](https://github.com/doitsujin/dxvk/releases).

Extract the 32-bit dll files into `~/.wine-gw/drive_c/windows/syswow64`
(Yes, that is correct. On 64-bit Windows, 32-bit libraries go in `syswow64` and 64-bit libraries go in `system32`. Exactly the opposite of what you'd naturally think based on their names.) Optionally, back up or rename the original files before overwriting them.

Open winecfg...
```
export WINEPREFIX=~/.wine-gw
winecfg
```
... go the the "Libraries" tab, and set overrides to "native, builtin" for `d3d8`, `d3d9`, `d3d10core`, `d3d11`, and `dxgi`.

Now test. If it's working, this command should cause the DXVK HUD to appear in the upper left:
```
DXVK_HUD=1 wine start /d "C:\Program Files (x86)\Guild Wars" "C:\Program Files (x86)\Guild Wars\Gw.exe"
```

#### Graphical Enhancements via DXVK

DXVK can override some aspects of Guild Wars' rendering behavior to provide graphical enhancements not otherwise available. Place `dxvk.conf` from the "extras" directory of this repo into your Guild Wars installation directory, and add or remove `#` marks at the start of lines to enable or disable each feature. See the comments in `dxvk.conf` for additional notes.
- Override Guild Wars' default anisotropic sampling with 16x anisotropic sampling.
- Override Guild Wars' maximum 8x MSAA antialiasing with 16x MSAA antialiasing. In-game antialiasing must be set to some MSAA mode. **Note:** Over strenuous objections, this feature was removed in DXVK v2.7. If you want it, use a version of DXVK older than 2.7.
- Override Guild Wars' native per-pixel shading with per-sample shading. This noticeably improves the appearance of foliage, and also player armor with "frills" like several Vabbian sets, eliminating shimmer on the edges of fine details. Note that per-sample shading softens edges that some users might prefer crisply aliased such as in-game fonts. (And this seems to have gotten worse following the 12/3/2025 Guild Wars "Reforged" update.) This feature is *very* demanding on GPU.
- Adjust LOD bias to increase texture detail/sharpness.
- Override Guild Wars' native vsync with mailbox present mode, an alternative implementation of vsync that gives the lowest possible frame latency without tearing. Mailbox present mode is highly recommended if you have a 60Hz monitor and your GPU can reliably exceed 120 fps. (Not recommended for framerate-to-refresh-rate ratios lower than 2x.) You must run Guild Wars with the `-fps <number>` parameter to allow FPS over 90, and you must disable native vsync in Guild Wars' in-game options. **Note:** Not all GPUs/drivers support mailbox present mode. To check if your system supports it, download the [Vulkan Hardware Capability Viewer](https://www.vulkan.gpuinfo.org/download.php) and check if "MAILBOX" is present under "Surface" > "Present Modes".


## Part 8: ESYNC/FSYNC/NTSYNC

ESYNC, FSYNC, and NTSYNC are alternative implementations for simulating Windows' thread synchronization that yield a substantial performance increase for most games. (ESYNC and FSYNC also crash a small minority of games, but Guild Wars is not among them. NTSYNC is a fully correct reproduction of Windows' thread synchronization behavior.) All three have roughly equal performance, with NTSYNC marginally better than FSYNC, and FSYNC marginally better than ESYNC, in most cases.

#### NTSYNC:

NTSYNC is available in official `wine`, `wine-devel`, and `wine-staging` starting from v10.16, and also some custom TkG/Proton builds starting earlier. NTSYNC is enabled by default, with no announcement to the console.

NTSYNC requires kernel support. Kernels >=v6.14 should have NTSYNC support. However, in many cases, this is via a kernel module that is *not* loaded by default. To see if the module is loaded, check if `/dev/ntsync` exists. To load the module for the current session only, run `sudo modprobe ntsync`. To always load the module at boot time (on distros using systemd), create the file `/etc/modules-load.d/ntsync.conf` (owned by root), with text content `ntsync`. To check if the ntsync virtual device is accessible to non-root users, make sure the module is loaded, then run `sudo udevadm info --name=ntsync` and verify that `DEVMODE=0666` (or 0644). If it's not, you need [a udev rule](https://aur.archlinux.org/cgit/aur.git/tree/99-ntsync.rules?h=ntsync) to fix it. Finally, to check if NTSYNC is working, run `lsof /dev/ntsync` while Guild Wars is running, and you should see several wine-related processes listed.

#### ESYNC:

ESYNC is available in the official `wine-staging`, TkG builds, and Proton prior to v10.16. Wine builds starting from v10.16 might not have ESYNC anymore. ESYNC is disabled by default and must be enabled by setting the environment variable `WINEESYNC=1`. (In Proton, it's enabled by default, unless disabled by the environment variable `PROTON_NO_ESYNC=1`.) You only need to set this variable when playing Guild Wars. It does not need to be set for the installation/setup/testing/configuration tasks in this guide.

ESYNC uses a large number of file descriptors. This poses a problem on some Linux distros that set a very low default limit for how many file descriptors one process may create. To check the limit on your system, use `ulimit -Hn`. 1048576 is considered acceptably high for ESYNC in general. (Since Guild Wars doesn't make heavy use of multithreading, 524288 is probably enough too.) To change the default limit on a distro that uses systemd, edit both `/etc/systemd/system.conf` and `/etc/systemd/user.conf`, uncommenting and changing the appropriate line to `DefaultLimitNOFILE=1048576`, then reboot. To change the default limit on a distro that doesn't use systemd, edit `/etc/security/limits.conf`, adding lines
```
{your-username} soft nofile 1048576
{your-username} hard nofile 1048576
```
and then reboot.

Testing: You should see "esync: up and running." the console output when you run wine with ESYNC active.

#### FSYNC:

FSYNC is available in most TkG builds and Proton prior to v10.16. Wine builds starting from v10.16 might not have FSYNC anymore. FSYNC must be enabled by setting the environment variable `WINEFSYNC=1`. (In Proton, it's enabled by default, unless disabled by the environment variable `PROTON_NO_FSYNC=1`.) If FSYNC is enabled (and supported by the kernel), then ESYNC is disabled automatically.  You only need to set this variable when playing Guild Wars. It does not need to be set for the installation/setup/testing/configuration tasks in this guide.

FSYNC does not care about the file descriptor limit, but it does require kernel support. The current iteration of FSYNC (futex_waitv) requires kernel >=5.16.

Testing: You should see "fsync: up and running." the console output when you run wine with FSYNC active.


## Part 9: TexMod/uMod/gMod

TexMod, uMod, and gMod are a family of utilities for replacing in-game textures. This enables graphical mods, such as removing the "frost" overlay from the skillbar, making UI elements translucent, spirit radar, etc. Of particular note is the famous [Cartography Made Easy mod](https://wiki.guildwars.com/wiki/Player-made_Modifications/Cartography_Index) that clearly shows which bits of fog can be removed for progress towards the cartography title. Files for TexMod and uMod can be found in the "extras" directory of this repo. gMod can be downloaded from [its github page](https://github.com/gwdevhub/gMod).

#### TexMod:
TexMod is the original texture-replacing tool from 2006. It is not recommended for playing Guild Wars, as it has occasional display bugs that are fixed in uMod and gMod. However, TexMod is useful for dumping textures if you want to make mods. Since uMod's texture dumping interface doesn't work in Linux, and gMod doesn't do texture dumping at all, TexMod is the only choice. No special installation is required. Simply extract the archive somewhere somewhere in the wine prefix and use TexMod to launch Guild Wars. For instance:
```
WINEPREFIX=~/.wine-gw wine start /d "C:\Program Files (x86)\TexMod" "C:\Program Files (x86)\TexMod\Texmod.exe"
```

#### uMod:
uMod is an improved, open-source rewrite of TexMod from 2011. The version with best compatibility for Guild Wars is v1_r44. uMod is suitable for playing Guild Wars. However, if you want to make mods, its texture dumping interface doesn't work in Linux. No special installation is required. Simply extract the archive somewhere somewhere in the wine prefix. uMod offers two ways to "hook" Guild Wars.
- First, you can simply run uMod, and then start Guild Wars via uMod's "Main -> Start game through uMod" menu option. (Or use "Start game through uMod (with command line)" if you want to change the fps limit.)
- Second, you can copy `d3d9.dll` from uMod's directory to Guild Wars' directory. Now if you start uMod first, and then start Guild Wars normally, uMod should "hook" Guild Wars. Make sure that the Guild Wars directory is the working directory when you invoke wine.

In either event:
```
WINEPREFIX=~/.wine-gw wine start /d "C:\Program Files (x86)\uMod" "C:\Program Files (x86)\uMod\uMod.exe"
```

#### gMod:
gMod is a simplified continuation of uMod with ongoing development since 2023. gMod removes uMod's UI, on-the-fly texture loading/unloading/reloading, texture dumping, etc. in favor of once-at-launch configuration via a simple text file. Consequently, gMod is more performant than either TexMod or uMod. Unless you need uMod's ability to load and unload mods while Guild Wars is running, gMod is probably the best choice. gMod offers two ways to "hook" Guild Wars.
- First, you can rename `gmod.dll` to `d3d9.dll` and place it in Guild Wars' directory. Then start Guild Wars normally. Make sure that the Guild Wars directory is the working directory when you invoke wine.
- Second, you can inject `gmod.dll` into the Guild Wars process before it loads `dxd9.dll`. gMod is integrated into GW Launcher (see Part 15), and also works with simple commandline injectors like [Injectory](https://github.com/blole/injectory). Which, assuming everything is in the Guild Wars directory, would work like this:
```
WINEPREFIX=~/.wine-gw wine start /d "C:\Program Files (x86)\Guild Wars" "C:\Program Files (x86)\Guild Wars\injectory.x86.exe" -l Gw.exe -i gMod.dll
```

Since gMod doesn't have a user interface, you need to use a text file to tell it which mods to load. Create `~/.wine-gw/drive_c/Program Files/Guild Wars/modlist.txt` and populate it with a list of mod files (uMod's tpf or zip format), one per line, by full Windows-style paths.


## Part 10: DirectSong

DirectSong is the official add-on for playing collector's edition and bonus music in Guild Wars. It is now completely defunct, since it depends on ancient Windows libraries that have been obsolete since 2009, and Jeremy Soule has completely abandoned the project.

Recent versions of wine use winegstreamer to decode wma files. However, gstreamer needs the libav (ffmpeg) plugin to do this. On Debian, this package is called `gstreamer1.0-libav`; it might have other names on other distros. You need the 32-bit version, unless you are using the "new wow64 mode" (in which case you need the 64-bit version).

If you're using 32-bit libraries for 32-bit support:
```
sudo apt-get install gstreamer1.0-libav:i386
```
If you're using the "new wow64 mode" in wine >= 10.2 for 32-bit support:
```
sudo apt-get install gstreamer1.0-libav
```

Additionally, you need `wmvcore.dll ` and `wmasf.dll` from Windows Media Player 10 or 11. Copies of these files are available in the "extras" directory of this repo. Place them into Guild Wars' directory, then open winecfg...
```
WINEPREFIX=~/.wine-gw winecfg
```
... go the the "Libraries" tab, and set overrides to "native, builtin" for "wmvcore" and "wmasf".


Finally, you need DirectSong itself, and music to go with it. Download the [DirectSong Revivial Pack](https://mega.nz/#!P2pWGK7C!FLZZOOWE1c5gYSgCqD4MC464m6ZvK1oGTlS08hLpnKw). This contains the DirectSong files along with *all* of the collector's edition and bonus music.

Extract the DirectSong directory to somewhere in your wine prefix. In this example, it's simply in the root of C:\.

Now run `RegisterDirectSongDirectory.exe` *with the DirectSong directory as the working directory*.
```
WINEPREFIX=~/.wine-gw wine start /d "C:\DirectSong" "C:\DirectSong\RegisterDirectSongDirectory.exe"
```

(As an alternative to running `RegisterDirectSongDirectory.exe`, you can create the necessary registry key with regedit. Sample .reg files are provided in the "extras" directory of this repo. Use the "Win32" or "Win64" file that matches your wine prefix (which will be win64 if you've been following this guide), edit it to point to your DirectSong directory, and import it with redegit:
```
WINEPREFIX=~/.wine-gw wine regedit"
```
)

To test that DirectSong is working, start Guild Wars, wait until the login screen music has been playing for a few seconds, press F11, and look for a gold DirectSong icon at the bottom of the sound menu.

Since it may fail silently, you should also test that wma decoding is working. (If it's not working, DirectSong shows the gold icon, but skips wma files.) To test this, edit `~/.wine-gw/drive_c/DirectSong/GuildWars.ds`. Find the line that starts with "loginen" and copy/paste some distinctive wma file to the start of that list. When you start Guild Wars, that wma file should be the first thing played on the login screen.

#### (Painful) Alternative Method for Proton Inside Steam:
See Part 16.

#### (Painful) Alternative Method for Proton Outside Steam:
Proton bundles its own gstreamer that can't decode wma. To work around this, you need to install Windows Media Player 11. This is a *large* pain in the arse. So much so that you should probably strongly consider just using a non-Proton version of wine rather than proceeding with these instructions.
- Use `winecfg` to set the Windows version to WinXP.
- Use `winetricks` to install `wmp11`.
- Use `winecfg` to set the Windows version to Win2003. (This is the only way to pass the validation screen.)
- You must run Windows Media Player to complete installation: `wine start /d "C:\Program Files (x86)\Windows Media Player" "C:\Program Files (x86)\Windows Media Player\wmplayer.exe"`
- The validation screen will hang for a long time, but eventually pass.
- After the EULA screen, Windows Media Player will hang or crash. Force kill it, and make sure to kill any zombie wine processes.
- Use `winecfg` to set the Windows version to WinXP.
- Again: `wine start /d "C:\Program Files (x86)\Windows Media Player" "C:\Program Files (x86)\Windows Media Player\wmplayer.exe"`
- This time, the first-run installation tasks will complete and Windows Media Player will start. The UI is unusable, and you will need to force kill it.
- Use `winecfg` to set the Windows version back to whatever you started with. (WinXP is no longer supported by Guild Wars and may crash.)
- Installing Windows Media Player added a bunch of crap file associations to `~/.local/share/applications`. You probably want to delete them.
- Install DirectSong itself as described above.


## Part 11: DSOAL-GW1 (Deprecated)

DSOAL-GW1 is obselete now that its core functionality has been incorporated into the Guild Wars client in the 12/3/2025 "Reforged" update.

If you previously installed DSOAL-GW1, delete or rename its `dsound.dll` and `dsoal-aldrv.dll` files and remove the override for `dsound`.

(If, for some reason, you want to continue using DSOAL-GW1, it *might* be possible via `Gw.exe`'s `-dsound` parameter. Consult prior versions of this document in github's history.)


## Part 12: Toolbox
[GWToolbox++](https://www.gwtoolbox.com/) is a collection of several tools and QoL enhancements for Guild Wars. Toolbox had long been the subject of sometimes heated debate about its merits versus the risk of getting your account banned, when, in May 2024, A-Net unexpectedly [announced](https://wiki.guildwars.com/wiki/Feedback:Game_updates/20240514) that toolbox is permitted for PvE. Even if you never use its other features, Toolbox is an absolute must-have for the fast travel feature alone.

Download the latest [Toolbox launcher](https://github.com/gwdevhub/GWToolboxpp/releases) to somewhere in the wine prefix and run it. For instance:
```
WINEPREFIX=~/.wine-gw wine start /d "C:\Program Files (x86)\GWToolbox" "C:\Program Files (x86)\GWToolbox\GWToolbox.exe"
```

The launcher will create a directory at `~/Documents/GWToolboxpp/` containing the dll file and configuration data. (If wine prefix isolation is active, this will instead be created inside the prefix in the virtual user's "Documents" directory.)

We now have two options to run Toolbox:

#### Option 1, The Launcher UI:
One option is to use the launcher. When Guild Wars is running, the launcher should show the option to select a running Guild Wars instance by character name. You can start the launcher before or after you start Guild Wars.

#### Option 2, Silent Injection:
The other option is to inject the Toolbox dll silently via a command-line tool. The selling point of this option is that you can attain a zero-click Toolbox startup. Toolbox's launcher has a `/quiet` option that automatically injects if it only sees one `Gw.exe` process:

```
#!/usr/bin/env bash
export WINEPREFIX=~/.wine-gw
{launch Guild Wars, maybe launch uMod first}
sleep 1
wine start /d "C:\Program Files (x86)\GWToolbox" "C:\Program Files (x86)\GWToolbox\GWToolbox.exe" /quiet
```

It's also possible to inject the Toolbox dll with generic injection utilities like [Injectory](https://github.com/blole/injectory) or [Injector](https://github.com/nefarius/Injector). A potentially useful feature of Injectory is the ability to launch `Gw.exe` in a paused state and inject before it starts running:

```
WINEPREFIX=~/.wine-gw wine start /d "C:\Program Files (x86)\Guild Wars" "C:\Program Files (x86)\Guild Wars\injectory.x86.exe" -l Gw.exe -i "C:\users\{your username}\Documents\GWToolboxpp\GWToolboxdll.dll"
```
Injectory supports injecting multiple dlls at once, so you can do both gMod and Toolbox with:
```
WINEPREFIX=~/.wine-gw wine start /d "C:\Program Files (x86)\Guild Wars" "C:\Program Files (x86)\Guild Wars\injectory.x86.exe" -l Gw.exe -i gMod.dll -i "C:\users\{your username}\Documents\GWToolboxpp\GWToolboxdll.dll"
```
Injectory also supports command line paramters, like `-fps <number>` for GW like so:

```
WINEPREFIX=~/.wine-gw wine start /d "C:\Program Files (x86)\Guild Wars" "C:\Program Files (x86)\Guild Wars\injectory.x86.exe" -l Gw.exe -i "C:\users\{your username}\Documents\GWToolboxpp\GWToolboxdll.dll" -a "-fps 144"
```

**Note:** Following Guild Wars' major 4/15/2025 update, Guild Wars will often crash and hang with a black screen at the moment the Toolbox dll is injected, if you are using new wow64 mode for 32-bit support and inject while Guild Wars is already running. If you encounter this problem, you have two options: (1) Use 32-bit system libraries instead of new wow64 mode for 32-bit support; or (2) use Injectory, GW Launcher, or similar to launch `Gw.exe` in a paused state and inject before it starts running.


## Part 13: Chat Filter

Install the community-maintained chat filter list to silence most of the obnoxious RMT spam in Kamadan:

Download `ChatFilter.ini` from [here](https://www.guildwarslegacy.com/ChatFilter.ini) or [here](https://raw.githubusercontent.com/kevinpetit/legacy-chatfilter/master/ChatFilter.ini) (they should be the same file) to `~/Documents/Guild Wars/`.

Symlink it into the GW directory. (We use a symlink so you can update multiple wine prefixes at once.)
```
ln -s ~/Documents/Guild\ Wars/ChatFilter.ini ~/.wine-gw/drive_c/Program\ Files\ \(x86\)/Guild\ Wars/ChatFilter.ini
```

## Part 14: paw\*ned2

Paw\*ned2 is a build manager for Guild Wars.

Download [the installer](https://memorial.redeemer.biz/pawned2/).

Run it:
```
wine {/path to/}pwndSetup_en.exe
```

Now you can run paw\*ned2 with:
```
wine start /d "C:\Program Files (x86)\pawned2" "C:\Program Files (x86)\pawned2\pawned2.exe"
```

Note: The installer is old and installs a version of paw\*ned2 from 2013. You need to use the self-updater in paw\*ned2's help menu to get a newer version that can handle the anniversary skills.

Note: If you are using gamescope for Guild Wars, then install paw\*ned2 to a different wine prefix from Guild Wars. Otherwise it will crash if you try to run them at the same time.

Note: Paw\*ned2 has terrible high dpi support.


## Part 15: Multiboxing


#### Multiple Wine Prefixes

Running multiple instances of Guild Wars at the same time is *much* easier in Linux than Windows. Simply install GW into multiple wine prefixes. Each copy will run isolated from the others. This is the recommended way to multibox Guild Wars on Linux.

Note: Yes, you can copy/paste a whole wine prefix. And, yes, that is the fastest way to do this. Just make sure to correct any symlinks you made so they point to the copies.

Note: Since Toolbox settings/data are shared, it might be possible to clobber one instance by changing settings/data in another. If this turns out to cause problems, try `winetricks sandbox` or disable desktop integration in winecfg.

#### GW Launcher

[GW Launcher](https://github.com/gwdevhub/gwlauncher) is a Windows multiboxing solution, but it can be run in wine. While Linux users have little use for it as a multiboxing solution, you might possibly want to use it for its other features, such as dll injection. To install GW Launcher:

- Use winetricks to install dotnetdesktop8.
- Use the "framework dependent" version of the exe file.
- When creating a profile in GWLauncher, check the box for "run elevated."

GW Launcher will launch `Gw.exe` in a paused state and attempt to inject any dll files you put in its "plugins" directory. This is one way to inject Toolbox. It will also inject its own copy of gMod if you put any tpf or zip files in the "plugins" directory. If you'd rather use uMod than gMod, then don't put any tpf or zip files in GW Launcher's "plugins" directory, and run uMod by renaming its dll as described in Part 9 or putting its dll in GW Launcher's "plugins" directory to be injected.

GW Launcher has an option to pass command line parameters, like `-fps <number>` to `Gw.exe`.


## Part 16: Solving Steam Headaches

As noted in Parts 1 and 4, running Guild Wars inside Steam is ***not*** recommended because it makes it difficult to install and use many of the add-ons covered in this guide. However, in some circumstances (e.g., Steam Deck), you might nevertheless really, really want to do that. This section explains how to work around those difficulties.

#### Adding Guild Wars to Steam
In the lower left corner of Steam's "Library" view, select "Add a Game," and then "Add a Non-Steam Game," then browse for wherever `Gw.exe` is located and select it.

The fields in the "Properties" menu "Shortcut" tab should auto-populate. Change the name to exactly "Guild Wars" to gain access to community controller layouts and such.

In the "Properties" menu "Compatibility" tab, set it to use whatever version of Proton you like.

In the "Properties" menu "Shortcut" tab, you can set "LAUNCH OPTIONS" to include command line parameters like `-fps <number>`. However, if you end up using a script to launch uMod and/or Toolbox (see below), parameters would go inside that script instead.

Something important to note: When you add a non-Steam game to Steam, Steam creates a more-or-less copy of its wine prefix at `{steam directory}/steamapps/compatdata/{random numbers}/pfx`. (`{steam directory`} is probably `~/.steam/steam`, but it varies by distro and when you first installed Steam.) When you launch Guild Wars via Steam, *this* is the wine prefix being used. This has several consequences of note:
- All the add-ons (Toolbox, DirectSong, etc.) need to be installed into this new prefix.
- `winecfg` needs to be invoked for this prefix.
- The original wine prefix isn't used anymore, and you can even delete everything except for the Guild Wars directory.
- When you launch Guild Wars, the working directory from Windows' point of view is way the heck off in the Z:\ drive, several layers deep, likely behind a path name that's a pain to work with. To make life easier, symlink the Guild Wars directory into `Program Files (x86)` in the new prefix.
- Because Steam manages this prefix, and might decide to delete it without warning you, you should symlink anything you care about keeping (e.g., DirectSong music, build templates, Toolbox config files, etc.) rather than actually putting it inside the prefix.

#### Running Arbitrary Commands in Steam
The cause of most Steam-related headaches is that `Gw.exe` is the *only* command Steam wants to run in that wine prefix. You need to bypass this behavior in order to install or use add-ons. You can use bash string manipulation to make Steam run an arbitrary command in place of `Gw.exe`.

To run arbitrary commands in Steam, first download and save `steamarbitrarycommand.sh` from this repo's "extras" directory. Now in the "Properties" menu "Shortcut" tab, set "LAUNCH OPTIONS" to `{path_to_script}/steamarbitrarycommand.sh %command% --run {real_command}` where `{real_command}` is the command you want run instead of `Gw.exe.` (Credit: This script came from [here](https://steamcommunity.com/app/221410/discussions/0/3731826842455660050/#c3731826842456351164).)

This script makes it possible to run `winecfg` to change dll overrides, or run `cmd` for a Windows command prompt for `RegisterDirectSongDirectory.exe`, or `regedit` to edit the registry directly, etc.

#### Running Multiple Commands in Steam
A secondary cause of headaches with Steam is that it only wants to run *one command at a time* in a given wine prefix. This is a problem if you want to run Guild Wars, uMod, and Toolbox's launcher simultaneously, for example. The workaround for this is to use `steamarbitrarycommand.sh` to launch a Windows .bat script in place of `Gw.exe`, having the .bat script run multiple programs. Place your .bat script in the Guild Wars installation directory and invoke `{path_to_script}/steamarbitrarycommand.sh %command% --run example.bat`.

Example .bat script:
```
echo off
cd /D "C:\Program Files (x86)\uMod"
start uMod.exe
ping -n 3 127.0.0.1 > nul
REM need to symlink GW directory so that it exists here in the prefix
cd ..
cd "Guild Wars"
start Gw.exe -fps 144
ping -n 5 127.0.0.1 > nul
cd ..
cd GWToolbox
start GWToolbox.exe
```

What is `ping` doing there? Proton doesn't have `timeout`; `ping` works as a substitute because it sends pings one second apart, so the duration is about `-n` minus 1 seconds. (127.0.0.1 is the local loopback address, i.e., yourself.)

You can download a sample `steamlauncher.bat` from the "extras" directory of this repo.

(As an alternative, [steamtinkerlaunch](https://github.com/sonic2kk/steamtinkerlaunch) might also be able to do some of the arbitrary/multiple command things a "full bells and whistles" Guild Wars needs.)

#### Protontricks
[Protontricks](https://github.com/Matoking/protontricks) is a wrapper around winetricks that makes it easier to install Windows components and such into Steam's wine prefixes. You will need this to get DirectSong working. It also offers an easy way to invoke `winecfg` for the prefix. 

#### DXVK in Steam
Do not install DXVK manually if running Guild Wars under Steam. Steam swaps around symlinks for DirectX dlls at launch time depending on the run options you select. DXVK is used by default. If using a `dxvk.conf` file, place it in the Guild Wars directory. See Part 7 for more information.

#### ESYNC/FSYNC in Steam
Steam enables FSYNC by default, and ESYNC by default if FSYNC is disabled or unsupported by your kernel. If you want to turn them off, set the environment variables `PROTON_NO_FSYNC=1` and/or `PROTON_NO_ESYNC=1`. Mainline Proton does not yet support NTSYNC. See Part 8 for more information.

#### TexMod in Steam
Extract TexMod into Steam's Guild Wars wine prefix at `{steam directory}/steamapps/compatdata/{random numbers}/pfx/drive_c/Program Files (x86)/TexMod`. Use `steamarbitrarycommand.sh` to launch TexMod in place of `Gw.exe`, then launch Guild Wars from inside TexMod.  See Part 9 for more information.

#### uMod in Steam
Extract uMod into Steam's Guild Wars wine prefix at `{steam directory}/steamapps/compatdata/{random numbers}/pfx/drive_c/Program Files (x86)/uMod`.

If you want to launch Guild Wars from inside uMod, use `steamarbitrarycommand.sh` to launch uMod in place of `Gw.exe`. See Part 9 for more information.

If you want to use the dll hook, copy `d3d9.dll` from uMod's directory to Guild Wars' directory, and use `steamarbitrarycommand.sh` to launch a .bat script that starts uMod, sleeps for a moment, then launches Guild Wars. See the example .bat file above.  See Part 9 for more information.

#### gMod in Steam
Just rename `gmod.dll` to `d3d9.dll` and place it in Guild Wars' directory. See Part 9 for more information.

#### DirectSong in Steam
Getting DirectSong working with Steam is a major headache. Proton uses its own bundled gstreamer plugins rather than your system libraries, and they are not able to decode wma files. So you need to install Windows Media Player 11 inside Steam's Guild Wars wine prefix:
- Install [protontricks](https://github.com/Matoking/protontricks). You will need it.
- Use either `protontricks` or `steamarbitrarycommand.sh` to invoke `winecfg` and set the Windows version to WinXP.
- Use `protontricks` to install `wmp11`.
- Use either `protontricks` or `steamarbitrarycommand.sh` to invoke `winecfg` and set the Windows version to Win2003.
- Use `steamarbitrarycommand.sh` to invoke `cmd`. Inside `cmd`, navigate to `C:\Program Files (x86)\Windows Media Player` and run `setup_wm.exe`. It will crash on the third screen; that's OK.
- Use either `protontricks` or `steamarbitrarycommand.sh` to invoke `winecfg` and set the Windows version back to whatever you started with (probably Win10).
- Symlink the DirectSong directory into Steam's Guild Wars wine prefix at `{steam directory}/steamapps/compatdata/{random numbers}/pfx/drive_c/DirectSong`. (Use a symlink so that you don't lose a gigabyte of music files if Steam decides to delete the prefix without warning.)
- Use `steamarbitrarycommand.sh` to invoke `cmd`. Inside `cmd`, navigate to `C:\DirectSong` and run `RegisterDirectSongDirectory.exe`.

See Part 10 for more information.

#### Toolbox in Steam

Installing Toolbox inside Steam entails a few extra headaches:
- Download `GWToolbox.exe` into Steam's Guild Wars wine prefix at `{steam directory}/steamapps/compatdata/{random numbers}/pfx/drive_c/Program Files (x86)/GWToolbox`.
- Use `steamarbitrarycommand.sh` to launch a .bat file that starts Guild Wars, sleeps for a few seconds, then starts Toolbox. See the example above.
- Toolbox will create a directory at `{steam directory}/steamapps/compatdata/{random numbers}/pfx/drive_c/users/steamuser/Documents/GWToolboxpp` and try to download `GWToolboxdll.dll` into it and it will **fail**. You must [manually download the dll file from Toolbox's github](https://github.com/gwdevhub/GWToolboxpp/releases) and put it there. It seems that Toolbox somehow lacks permissions to create that file. Fortunately, once it exists, Toolbox is able to execute it, and also overwrite it when Toolbox updates.
- Try your .bat file again. It should work now.

Toolbox's `/quiet` parameter is a bit flakey inside Steam. It sometimes causes Guild Wars to black screen and hang. If this happens to you, try changing the delay before starting Toolbox, or just don't use `/quiet`.

See Part 12 for more information.
