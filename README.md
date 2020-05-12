# Prebuilt releases

Get prebuilt releases from Gitlab CI at https://gitlab.com/chromium-ppc64le/ungoogled-chromium/pipelines

Look for "Download build artifacts" on the latest successful pipeline.

# How to build for ppc64le

1. Create an Ubuntu Bionic build environment

2. `sudo apt install -y build-essential ninja-build clang git vim cmake python libcups2-dev pkg-config libnss3-dev libssl-dev libglib2.0-dev libgnome-keyring-dev libpango1.0-dev libdbus-1-dev libatk1.0-dev libatk-bridge2.0-dev libgtk-3-dev libkrb5-dev libpulse-dev libxss-dev re2c subversion curl libasound2-dev libpci-dev mesa-common-dev gperf bison nodejs uuid-dev clang-format libatspi2.0-dev libva-dev ccache libgbm-dev`

3. `git clone https://github.com/leo-lb/ungoogled-chromium ungoogled-chromium-ppc64le && cd ungoogled-chromium-ppc64le && git submodule update --init`

4. `./ppc64le_build.bash`

## Fedora

If you're running Fedora 30, instead, you can install the dependencies with
```
sudo dnf install git python bzip2 tar pkgconfig atk-devel alsa-lib-devel bison binutils brlapi-devel bluez-libs-devel bzip2-devel cairo-devel cups-devel dbus-devel dbus-glib-devel expat-devel fontconfig-devel freetype-devel gcc-c++ glib2-devel glibc gperf gtk3-devel java-1.*.0-openjdk-devel libatomic libcap-devel libffi-devel libgcc libgnome-keyring-devel libjpeg-devel libstdc++ libX11-devel libXScrnSaver-devel libXtst-devel libxkbcommon-x11-devel ncurses-compat-libs nspr-devel nss-devel pam-devel pango-devel pciutils-devel pulseaudio-libs-devel zlib httpd mod_ssl php php-cli python-psutil wdiff xorg-x11-server-Xvfb clang vim cmake pkg-config krb5-devel re2c subversion curl nodejs libuuid-devel ninja-build libva-devel ccache xz patch diffutils findutils coreutils @development-tools elfutils rpm-devel rpm rpm-build fakeroot 
```

**NOTE:** Fedora 31 and later is not supported because libgnome-keyring-devel has been deprecated for libsecret and Chromium *yet* doesnt support libsecret.

### /!\ You must remove the build folder before running the build script again.

# ungoogled-chromium

*A lightweight approach to removing Google web service dependency*

**Help is welcome!** See the [docs/contributing.md](docs/contributing.md) document for more information.

## Objectives

In descending order of significance (i.e. most important objective first):

1. **ungoogled-chromium is Google Chromium, sans dependency on Google web services**.
2. **ungoogled-chromium retains the default Chromium experience as closely as possible**. Unlike other Chromium forks that have their own visions of a web browser, ungoogled-chromium is essentially a drop-in replacement for Chromium.
3. **ungoogled-chromium features tweaks to enhance privacy, control, and transparency**. However, almost all of these features must be manually activated or enabled. For more details, see [Feature Overview](#feature-overview).

In scenarios where the objectives conflict, the objective of higher significance should take precedence.

## Content Overview

* [Objectives](#objectives)
* [Motivation and Philosophy](#motivation-and-philosophy)
* [Feature Overview](#feature-overview)
* [**Downloads**](#downloads)
* [Source Code](#source-code)
* [**FAQ**](#faq)
* [Building Instructions](#building-instructions)
* [Design Documentation](#design-documentation)
* [**Contributing, Reporting, Contacting**](#contributing-reporting-contacting)
* [Credits](#credits)
* [Related Projects](#related-projects)
* [License](#license)

## Motivation and Philosophy

Without signing in to a Google Account, Chromium does pretty well in terms of security and privacy. However, Chromium still has some dependency on Google web services and binaries. In addition, Google designed Chromium to be easy and intuitive for users, which means they compromise on transparency and control of internal operations.

ungoogled-chromium addresses these issues in the following ways:

1. Remove all remaining background requests to any web services while building and running the browser
2. Remove all code specific to Google web services
3. Remove all uses of pre-made binaries from the source code, and replace them with user-provided alternatives when possible.
4. Disable features that inhibit control and transparency, and add or modify features that promote them (these changes will almost always require manual activation or enabling).

These features are implemented as configuration flags, patches, and custom scripts. For more details, consult the [Design Documentation](docs/design.md).

## Feature Overview

*This section overviews the features of ungoogled-chromium. For more detailed information, it is best to consult the source code.*

Contents of this section:

* [Key Features](#key-features)
* [Enhancing Features](#enhancing-features)
* [Borrowed Features](#borrowed-features)
* [Supported Platforms and Distributions](#supported-platforms-and-distributions)

### Key Features

*These are the core features introduced by ungoogled-chromium.*

* Replace many web domains in the source code with non-existent alternatives ending in `qjz9zk` (known as domain substitution; [see docs/design.md](docs/design.md#source-file-processors) for details)
* Strip binaries from the source code (known as binary pruning; [see docs/design.md](docs/design.md#source-file-processors) for details)
* Disable functionality specific to Google domains (e.g. Google Host Detector, Google URL Tracker, Google Cloud Messaging, Google Hotwording, etc.)
    * This includes disabling [Safe Browsing](//en.wikipedia.org/wiki/Google_Safe_Browsing). Consult [the FAQ for the rationale](//ungoogled-software.github.io/ungoogled-chromium-wiki/faq#why-is-safe-browsing-disabled).
* Add many new command-line switches and `chrome://flags` entries to configure disabled-by-default features. See [docs/flags.md](docs/flags.md) for the exhaustive list.

### Enhancing Features

*These are the non-essential features introduced by ungoogled-chromium.*

* Use HTTPS by default when a URL scheme is not provided (e.g. Omnibox, bookmarks, command-line)
* Add *Suggestions URL* text field in the search engine editor (`chrome://settings/searchEngines`) for customizing search engine suggestions.
* Add more URL schemes allowed to save page schemes.
* Add Omnibox search provider "No Search" to allow disabling of searching
* Add a custom cross-platform build configuration and packaging wrapper for Chromium. It currently supports many Linux distributions, macOS, and Windows. (See [docs/design.md](docs/design.md) for details on the system.)
* Force all pop-ups into tabs
* Disable automatic formatting of URLs in Omnibox (e.g. stripping `http://`, hiding certain parameters)
* Disable intranet redirect detector (extraneous DNS requests)
    * This breaks captive portal detection, but captive portals still work.
* (Iridium Browser feature change) Prevent URLs with the `trk:` scheme from connecting to the Internet
    * Also prevents any URLs with the top-level domain `qjz9zk` (as used in domain substitution) from attempting a connection.
* (Iridium and Inox feature change) Prevent pinging of IPv6 address when detecting the availability of IPv6. See the `--set-ipv6-probe-false` flag above to adjust the behavior instead.
* (Windows-specific) Do not set the Zone Identifier on downloaded files

### Borrowed Features

In addition to the features introduced by ungoogled-chromium, ungoogled-chromium selectively borrows many features from the following projects (in approximate order of significance):

* [Inox patchset](//github.com/gcarq/inox-patchset)
* [Bromite](//github.com/bromite/bromite)
* [Debian](//tracker.debian.org/pkg/chromium-browser)
* [Iridium Browser](//iridiumbrowser.de/)

### Supported Platforms and Distributions

[See docs/platforms.md for a list of supported platforms](docs/platforms.md).

Other platforms are discussed and tracked in this repository's Issue Tracker. Learn more about using the Issue Tracker under the section [Contributing, Reporting, Contacting](#contributing-reporting-contacting).

## Downloads

[**Download binaries from here**](//ungoogled-software.github.io/ungoogled-chromium-binaries/)

*NOTE: These binaries are provided by anyone who are willing to build and submit them. Because these binaries are not necessarily [reproducible](https://reproducible-builds.org/), authenticity cannot be guaranteed; In other words, there is always a non-zero probability that these binaries may have been tampered with. In the unlikely event that this has happened to you, please [report it in a new issue](#contributing-reporting-contacting).*

These binaries are known as **contributor binaries**.

Also, ungoogled-chromium is available in several **software repositories**:

* Arch Linux: [Available in AUR as `ungoogled-chromium`](https://aur.archlinux.org/packages/ungoogled-chromium/)
* Fedora: Available in [RPM Fusion](https://rpmfusion.org) as `chromium-browser-privacy`.
* GNU Guix: Available as `ungoogled-chromium`.
* Gentoo Linux: [`::pf4public`](https://github.com/PF4Public/gentoo-overlay) overlay maintains an *unofficial*  [`ungoogled-chromium`](https://github.com/PF4Public/gentoo-overlay/tree/master/www-client/ungoogled-chromium) ebuild
* NixOS/nixpkgs: Available as `ungoogled-chromium`
* Debian & Ubuntu: [OBS Instructions](https://software.opensuse.org/download/package?package=ungoogled-chromium&project=home:ungoogled_chromium)
* macOS cask: Available as `eloston-chromium`. Install (via [Homebrew](https://brew.sh/)) by running: `brew cask fetch eloston-chromium` and then `brew cask install eloston-chromium`

## Source Code

This repository only contains the common code for all platforms; it does not contain all the configuration and scripts necessary to build ungoogled-chromium. Most users will want to use platform-specific repos, where all the remaining configuration and scripts are provided for specific platforms:

[**Find the repo for a specific platform here**](docs/platforms.md).

If you wish to include ungoogled-chromium code in your own build process, consider using [the tags in this repo](//github.com/Eloston/ungoogled-chromium/tags). These tags follow the format `{chromium_version}-{revision}` where

* `chromium_version` is the version of Chromium used in `x.x.x.x` format, and
* `revision` is a number indicating the version of ungoogled-chromium for the corresponding Chromium version.

Additionally, most platform-specific repos extend their tag scheme upon this one.

**Building the source code**: [See docs/building.md](docs/building.md)

### Mirrors

List of mirrors:

* [Codeberg](https://codeberg.org): [main repo](https://codeberg.org/Eloston/ungoogled-chromium) and [ungoogled-software](https://codeberg.org/ungoogled-software)

## FAQ

[See the frequently-asked questions (FAQ) on the Wiki](//ungoogled-software.github.io/ungoogled-chromium-wiki/faq)

## Building Instructions

[See docs/building.md](docs/building.md)

## Design Documentation

[See docs/design.md](docs/design.md)

## Contributing, Reporting, Contacting

* For reporting and contacting, see [SUPPORT.md](SUPPORT.md)
* For contributing (e.g. how to help, submitting changes, criteria for new features), see [docs/contributing.md](docs/contributing.md)

## Credits

* [The Chromium Project](//www.chromium.org/)
* [Inox patchset](//github.com/gcarq/inox-patchset)
* [Debian](//tracker.debian.org/pkg/chromium-browser)
* [Bromite](//github.com/bromite/bromite)
* [Iridium Browser](//iridiumbrowser.de/)
* The users for testing and debugging, [contributing code](//github.com/Eloston/ungoogled-chromium/graphs/contributors), providing feedback, or simply using ungoogled-chromium in some capacity.

## Related Projects

List of known projects that fork or use changes from ungoogled-chromium:

* [Bromite](//github.com/bromite/bromite) (Borrows some patches. Features builds for Android)
* [ppc64le fork](//github.com/leo-lb/ungoogled-chromium) (Fork with changes to build for ppc64le CPUs)

## License

BSD-3-clause. See [LICENSE](LICENSE)
