# Chirpy for Android

## Requirements

Building Chirpy for Android requires:

  - the [android-env][] script; and
  - [Android Studio][].


## Build

First follow the steps in the top level [README.md](README.md).

Then install [Android Studio][].

Change into the `chirpy-android` directory:

    $ cd chirpy-android

Download, extract, and patch LÖVE for Android version 11.1:

    $ curl -L -O https://bitbucket.org/rude/love/downloads/love-11.1-android-source.tgz
    $ gunzip < love-11.1-android-source.tgz | tar -f - -x
    $ patch -b -p0 < patches/patch-love-11.1-android-source

Copy everything in the `love-11.1-android-source` directory into this
directory, without overwriting files:

    $ cp -R -n love-11.1-android-source/ ./

Note the trailing slashes in the command above.

Download the android-env script:

    $ git clone https://github.com/eliteraspberries/android-env.git
    $ cp android-env/android-env.sh .

Download, extract, and patch LuaJIT version 2.1.0-beta3:

    $ curl -L -O http://luajit.org/download/LuaJIT-2.1.0-beta3.tar.gz
    $ gunzip < LuaJIT-2.1.0-beta3.tar.gz | tar -f - -x
    $ patch -b -p0 < patches/patch-LuaJIT-2.1.0-beta3

Build everything:

    $ make apk

Finally, open the project directory `chirpy-android` in Android Studio,
and select 'Make Project' from the 'Build' menu.


[Android Studio]: <https://developer.android.com/studio/>
[android-env]: <https://github.com/eliteraspberries/android-env>
