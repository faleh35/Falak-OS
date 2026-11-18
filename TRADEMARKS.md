# FalakOS Trademark Policy

The code in this repository is open source under the Apache-2.0 license (see `LICENSE`).
The FalakOS name and logo are not covered by that license. This page explains how you can use them.
Nothing here limits your rights to the code under Apache-2.0.

## The marks

- The name **FalakOS**, and **Falak** / **فلك** when used as the name of an operating system or its editions
- The FalakOS logo (the planet with an orbit and a moon):
  `files/system/usr/share/icons/hicolor/scalable/apps/falak-logo.svg` and
  `files/system/usr/share/pixmaps/falak-logo.svg`

## You can, without asking

- Say that something runs on, works with, or is based on FalakOS, as long as it's true
- Write articles, make videos, tutorials and reviews, and run user groups about FalakOS
- Share the official FalakOS images and ISOs unchanged
- Use the name and logo to link to the official project

## If you change it, rebrand it

If you share a modified version (a fork, a remix, your own build), give it a different name and logo,
so people know it didn't come from the FalakOS project. Change:

- `NAME`, `PRETTY_NAME`, `HOME_URL` and `LOGO` in the `os-release` module of each recipe in `recipes/`
- `files/system/etc/xdg/kcm-about-distrorc`
- the logo files listed above
- the welcome text in `files/system/usr/bin/falak-welcome`

**Exception for companies:** IT teams that build images on top of FalakOS Corporate for use inside their
own organization (as described in the README) don't need to rebrand, as long as those images aren't
shared outside the organization.

## You can't

- Suggest that the FalakOS project made, approves or supports your product when it doesn't
- Use FalakOS, or a confusingly similar name (such as "FalakOS Pro" or "Falak Linux"), for your own
  distribution, app or service
- Use the FalakOS logo, or a changed version of it, as your own logo
- Sell products or services under the FalakOS name

## Questions

To ask about a use that isn't covered here, open an issue in this repository.
