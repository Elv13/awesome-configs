# shifty
[Shifty](https://awesome.naquadah.org/wiki/Shifty) is an Awesome 3 extension
that implements dynamic tagging.

It also implements fine client matching configuration allowing _you_ to be
the master of _your_ desktop.

Here are a few ways of how shifty makes awesome awesomer:

* on-the-fly tag creation and disposal
* advanced client matching
* easy moving of clients between tags
* tag add/rename prompt in taglist (with completion)
* reordering tags and configurable positioning
* tag name guessing, automagic no-config client grouping
* customizable keybindings per client and tag
* simple yet powerful configuration

## Use

0. Go to configuration directory, usually `~/.config/awesome`
1. Clone repository:

    `git clone https://bioe007@github.com/bioe007/awesome-shifty.git shifty`

2. Move the example `rc.lua` file into your configuration directory.

    `cp shifty/example.rc.lua rc.lua`

3. Restart awesome and enjoy.

There are many configuration options for shifty, the `example.rc.lua` is
provided merely as a starting point. The most important variables are the
tables:

* `shifty.config.tags = {}`
    - Sets predefined tags, which are not necessarily initialized.
* `shifty.config.apps = {}`
    - How to handle certain applications.
* `shifty.config.defaults = {}`
    - Fallback values used when a preset is not found in the first two
    configuration tables.

But for each of these there are _tons_ of shifty variables and settings, its
easiest to check out the wiki page or the module itself.

In the `example.rc.lua` searching for `shifty` in your editor can also help to
make sense of these.

## Help
Help is best found in this order:

1. Web search, e.g. [Google](http://www.google.com) is your friend...
2. `#awesome` on irc.oftc.net is good for immediate aid, especially with
   configuration questions and such.
3. The [awesome users mailing list](mailto:awesome@naquadah.org)
4. Messaging through github
5. Directly e-mailing the [author](mailto:resixian@gmail.com)
    - _Please_ use this as a last resort, not that I mind, but the other formats
    allow others to benefit as well.

## Development
Report bugs at the [github
repo](https://github.com/bioe007/awesome-shifty/issues). Please include at least
the current versions of awesome and shifty, as well as distribution.

## Credits
* [Perry Hargrave](mailto:resixian@gmail.com)
    - Current maintainer and point of contact.
* [koniu](mailto:gkusnierz@gmail.com)
    - Original author

## License
Current awesome wm license or if thats not defined, GPLv2.
