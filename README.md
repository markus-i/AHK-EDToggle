# AHK-EDToggle
AutoHotKey script for handling joystick toggle switches in Elite:Dangerous

This is a WIP - a repository for an AHK (AutoHotKey) script that helps me handle a few joystick inputs for the game Elite:Dangerous.
Elite:Dangerous (or ED) is a space flight game. I use a pair of Virpil Constellation Alpha sticks for it as HOSAS. My reason for writing this script was that ED does not offer the possiblity to configure toggle switches as inputs for all controls, in this case, for switching between Analysis and Combat mode, and for deploying hardpoints (weapons). Instead, though, ED offers a status file in JSON format that is continously updated and has some data about the in-game status.

So, what this script does is to read out the state of the two toggle switches on these joysticks (flip trigger) and compares it against the status reported from the game for cockpit mode and hardpoint status. If they differ, the script sends out the corresponding trigger command to the game.
