# stem-calculator
Calculator application for dahliaOS

## Build With Flutter

Check The Wiki:

[/wiki/Build-Dahlia-Calculator](https://github.com/dahlia-os/dahlia-calculator/wiki/Build-Dahlia-Calculator)

## Important Style guide!
All dahlia applications MUST have a central accent color, that is not #ff5722, or material-deeporange or similar, as that is reserved for the system. Uploaders must upload a theme.txt in the root of their application, that contains the accent color, in preferably hexadecimal, but RGBA is acceptable as well. Uncompliant applications will have their theme colors set to a random color. As my history teacher would say, white, black, and gray are not colors.

## Application Requirements
In order to be compatible with the desktop and mobile pangolin window manager, all applications must be implemented as a flutter materialApp widget. This is so that when the app is opened through pangolin, the app is not loaded through the window manager process.
