# Element Master Splash Chemical Bonding Periodic Table Bubble Shooter

## How to TEST

* Make sure the repo is updated with `git pull`
* Open `main.lua`
* Comment (put `--` at the start of the line) line numbers `25` and `26`
* Uncomment (remove `--`) line number `29`
* Open `game.lua`
* Comment lines with variables after the `--TODO remove these`
* method 1 - zipping:
    * Select all files
    * Zip
    * Use `.love` extension instead of `.zip`
    * Double click the `.love` file
* method 2 - direct
    * Run `love .` in the current directory


## How to change Difficulty/Level

* Open `main.lua`
* At line `26`, replace the string (1st parameter) with the desired difficulty. Examples:
    * `StateManager.current = Game("easy", 1)`
    * `StateManager.current = Game("medium", 1)`
    * `StateManager.current = Game("hard", 1)`
* At line `26`, replace the number (2nd parameter) with the desired level number. Examples:
    * `StateManager.current = Game("easy", 2)`
    * `StateManager.current = Game("medium", 5)`
    * `StateManager.current = Game("hard", 10)`
