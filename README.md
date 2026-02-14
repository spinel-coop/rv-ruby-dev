# rv ruby binaries

Tools to build versions of Ruby that can be installed and run from anywhere on the filesystem.

## How do I use these rubies

First, [install `rv`](https://github.com/spinel-coop/rv), and then run `rv ruby install`.

## Local development

### macOS and glibc Linux (Homebrew)

- Run `bin/setup` to tap your checkout of this repo as `spinel-coop/rv-ruby`.
- Run e.g. `brew rv-package --no-uninstall-deps --debug --verbose rv-ruby@3.4.5` to build Ruby 3.4.5 locally with YJIT.

### Alpine Linux (musl)

Homebrew can't run on Alpine (musl libc), so Alpine builds compile Ruby from
source using system packages. Run inside an Alpine container:

```sh
docker run -it --rm -v .:/src -w /src alpine:3.21 sh
apk add autoconf bzip2 bzip2-dev ca-certificates coreutils dpkg-dev \
  g++ gcc gdbm-dev glib-dev gmp-dev libc-dev libffi-dev libxml2-dev \
  libxslt-dev linux-headers make ncurses-dev openssl-dev patch procps \
  readline-dev yaml-dev zlib-dev tar xz curl rust git patchelf
bin/alpine 3.4.8 URL SHA256
```

See `bin/alpine` for details. Patches applied during Alpine builds are
documented in [`patches/README.md`](patches/README.md).

## How do I issue a new release

[An automated release workflow is available to use](https://github.com/spinel-coop/rv-ruby/actions/workflows/release.yml).
Dispatch the workflow and all steps of building, tagging and uploading should be handled automatically.

<details>
<summary>Manual steps are documented below.</summary>

### Build

Run `brew portable-package ruby`. For macOS, this should ideally be inside an OS X 10.11 VM (so it is compatible with all working Homebrew macOS versions).

### Upload

Copy the bottle `bottle*.tar.gz` and `bottle*.json` files into a directory on your local machine.

Upload these files to GitHub Packages with:

```sh
brew pr-upload --upload-only --root-url=https://ghcr.io/v2/spinel-coop/rv-ruby
```

And to GitHub releases:

```sh
brew pr-upload --upload-only --root-url=https://github.com/spinel-coop/rv-ruby/releases/download/$VERSION
```

where `$VERSION` is the new package version.
</details>

## Thanks

Thanks to the [Homebrew](https://brew.sh) team for the [portable-ruby](https://github.com/Homebrew/homebrew-portable-ruby) code we used as a starting point.

## License

Code is under the [BSD 2-Clause "Simplified" License](/LICENSE.txt).
