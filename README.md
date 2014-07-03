# Gyazo for Linux (modded for iQuestria usage)

http://gyazo.iquestria.net/

### Install

Install Ruby and Bundler then run `bundle update` in the `src` directory to get all dependencies.

```
$ sudo apt-get install ruby imagemagick bundler
$ cd src
$ bundle update
```

Then, to make it actually work, you need to get the [command line tool](https://github.com/iQuestria/iquestria-ruby) and use this command:

```
./iquestria.rb login YourUsername YourPassword 5LyCQXSW0c42P8N6
```

What that does is authenticates with iQuestria and stores your token.
