Chirpy is an audio text messaging app.

Chirpy is a fun demonstration of chirp modulation.


## Install

Download the latest Android Package (APK):
https://github.com/eliteraspberries/chirpy/releases/tag/v0.4


## Usage

On screen you will see three buttons (①, ②, ③), text input or received (④),
and plots of the decoding process (⑤, ⑥).

![Example usage](chirpy.gif)

 1. The 'debug' button toggles the information displayed in the background.
 2. The 'mic' button toggles the decoding process.
    Turn this off when not in use because it consumes battery.
 3. The 'keyboard' button toggles keyboard input.
 4. Text sent or received is displayed at the top of the screen.
 5. and 6 are plots of the cross-correlation of the audio received and
    the zero and one chirps.
    A peak indicates the presence of a chirp.


## Requirements

The Chirpy app requires:

  - a 32-bit ARM CPU (ARMv7-A) and Android 4.4 (KitKat) or later; or
  - a 64-bit ARM CPU (ARMv8-A) and Android 5.0 (Lollipop) or later.

That means most Android smartphones.

Building Chirpy requires:

  - a [Unix shell and utilities][unix] including [make][];
  - [GNU Autotools][autotools] (Autoconf, Automake, and Libtool);
  - [Python][] and [SCons][];
  - the awesome [LÖVE][] framework;
  - the [FFTW][] library and [lua-libfftw][];
  - the [Nu][] library and [lua-libnu][]; and
  - the [DejaVu][] Sans font.


## Build

Fetch this repository and change into its directory:

    $ git clone https://github.com/eliteraspberries/chirpy.git
    $ cd chirpy

Download, extract, and patch FFTW version 3.3.8:

    $ curl -L -O http://www.fftw.org/fftw-3.3.8.tar.gz
    $ gunzip < fftw-3.3.8.tar.gz | tar -f - -x
    $ patch -b -p0 < patches/patch-fftw-3.3.8

Download and extract Nu version 0.7:

    $ curl -L -O https://github.com/eliteraspberries/nu/releases/download/v0.7/nu-0.7.tar.gz
    $ gunzip < nu-0.7.tar.gz | tar -f - -x

Download lua-libfftw:

    $ git clone https://github.com/eliteraspberries/lua-libfftw.git
    $ cp -R lua-libfftw/libfftw .

Download lua-libnu:

    $ git clone https://github.com/eliteraspberries/lua-libnu.git
    $ cp lua-libnu/libnu.lua .

Download the latest version of the DejaVu Sans font:

    $ curl -L -O https://github.com/dejavu-fonts/dejavu-fonts/releases/download/version_2_37/dejavu-fonts-ttf-2.37.zip
    $ unzip -j dejavu-fonts-ttf-2.37.zip dejavu-fonts-ttf-2.37/ttf/DejaVuSans.ttf -d fonts

Then read [chirpy-android/README.md](chirpy-android/README.md).


[DejaVu]: <https://dejavu-fonts.github.io/>
[FFTW]: <http://www.fftw.org/>
[LÖVE]: <https://love2d.org/>
[Nu]: <https://github.com/eliteraspberries/nu>
[Python]: <https://www.python.org/>
[SCons]: <https://scons.org/>
[autotools]: <https://www.gnu.org/software/automake/>
[lua-libfftw]: <https://github.com/eliteraspberries/lua-libfftw>
[lua-libnu]: <https://github.com/eliteraspberries/lua-libnu>
[make]: <http://pubs.opengroup.org/onlinepubs/9699919799/utilities/make.html>
[unix]: <http://pubs.opengroup.org/onlinepubs/9699919799/utilities/contents.html>
