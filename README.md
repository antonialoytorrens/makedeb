## Overview ##
Makedeb takes PKGBUILD files and creates Debian archives installable with APT

## Ideology ##
Makdeb is NOT a clone/fork of `makepkg`. Rather, Makedeb is written from scratch, striving only to be compatible with the PKGBUILD format as described in the [Arch Wiki](https://wiki.archlinux.org/index.php/PKGBUILD).

## Building and Installing Packages ##
1. Obtain the PKGBUILD and other files if necessary, most often with `git clone *URL*`
2. Run `makedeb` in the directory containing the PKGBUILD. After, install the package with `apt install ./*PKGNAME*.deb`

## Updating Packages ##
Obtain the latest PKGBUILD and other files if needed, and follow step 2 listed above.

## Quick Notes ##
 - Dependencies will *probably* need to be changed inside the PKGBUILD [as of now](https://github.com/hwittenborn/makedeb#things-i-want-to-add). Keep the formatting in the PKGBUILD the same though(don't add commas, the script automatically does so).

## Things I Still **Need** to Add ##
 - Chroot support(Nothing is confined ATM!)
 - Fakeroot support
 - url
 - license
 - groups
 - makedepends
 - checkdepends
 - optdepends
 - provides
 - conflicts
 - replaces
 - backup
 - noextract
 - validpgpkeys
 - check function
 - Probably some other stuff I'm forgetting somewhere

## Things I Want to Add ##
 - Dependency substitution system(for converting Arch Linux dependencies to Debian dependencies)

## Contributing ##
The biggest way I can get help is just testing as many PKGBUILDs as possible and reporting bugs on the [Issue Page](https://github.com/hwittenborn/makedeb/issues). Until I can get things fully up to spec, feel free to make feature requests as well if there's something you really need.

Lastly, if you're able and want to, code contributions are always welcome!
