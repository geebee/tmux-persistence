###tmux Session Persistence
---

This script was born out of a desire to be able to persist the state of tmux sessions to disk so that they would survive a reboot

It is very much a work in progress, but already quite useful

####Configuration and general need-to-know
---
At the top of the script there is a section of variable definitions that can be modified to suit your needs. Currently, the options are:

   - `sessionStore` - The directory where stored sessions will be saved. The default is `~./sessions`
     - The `sessionStore` directory will be created if it does not exist already.
 - `maxStoredSessions` - The total number of saved sessions that will be stored. The default is `5`
   - Once `maxStoredSessions` total backups exist, the `filesToRoll` parameter comes into play
 - `filesToRoll` - The number of files that will be rotated out once `maxStoredSessions` has been reached. The deafult is `3`
   - What this means is, once `maxStoredSessions` sessions are stored in `sessionStore`, `filesToRoll` files will be deleted from `sessionStore` in order to make room for new saves


####Usage
---
 
 - The simplest usage is to just call `ruby ./tmux-persist.rb` from within the directory where the script exists. This will create a restoreable session script which can be run to re-create the tmux session at the time of execution

 - A more common, and slightly more useful implementation is to add a cron entry like the following: `* * * * *  <username>  ruby <full path to>/tmux-persist.rb`, which will run this script once per minute, creating a constant series of backups of active tmux sessions

####What it can do
---
 - Back up on-demand (or regularly via cron or any scheduler) all active tmux sessions
 - Backups are created as runnable shell scripts, meaning all you have to do is run the appropriate 'backup' script, and your whole tmux session will be appropriately resotred
 

####What it will do
---
 - Have more configurable properties
 - Read from a config file
 - Have command line switches

---
 
 - Please feel free to submit issues or better yet PRs against features you'd like to see or bugs you come across

 Credit goes to [@daveosborne](https://github.com/daveosborne "@daveosborne") for the original implementation of this script