# ChatConsole

Add commands to the in-game chat. Since we haven't found a way to get the chat is singleplayer please play multiplayer for this (doesn't change anything else).

# List of commands

Commands look like this : ```/command <Mandatory Field> [Optional Field]```.

* ```/help [command]``` gives you a list of all commands or information on a specified command.
* ```/give ``` gives the specified player any number of one item. Default amount is 1.
* ```/remove ``` remove the any number of one item from the specified player. Default amount is 1.
* ```/gold <amount> [username]``` gives the specified player gold.
* ```/lvl <number> [username]``` gives the specified player levels.
* ```/spawntp``` spawns a teleporter at your location that sends you to the next stage (it cannot make you go to the final stage).
* ```/god [username]``` make the specified player invulnerable (this doesn't make you invulnerable to falldamage, but falldamage can't kill you anyway).
* ```/kill [username or monster name]``` kills the specified player or all monsters from the specified monstertype.
* ```/pvp``` enables pvp mode in multiplayer, setting each player to different teams. You can still be damaged by monsters.
* ```/skill <skillbar slot> <skill name or skill id> [username]``` replace a skill by another in your skillbar. The skillbar slots are numbered 1-4.


Host Only
* ```/kick [username]``` kick the specified user from the game.

* ``` ```

Any command with an optional username targets yourself if not specified. The specified username has to be exact (
