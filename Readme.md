# 🤖 Godot Project Template

* A starting template for Godot projects.
* Includes .gitkeep files so that empty folders can be uploaded to Github.
* Delete them as necessary.


## 📁 Folder Layout

1. Folders are organized around features, not file types
    * Entities/player folder should have player script, scene, sprites and resources
    * Levels should be in another folder, etc
    * This includes art and SFX too
1. Separate assets folder
    * Fonts, music, theme
    * Shared assets are here too
1. Folders for other parts
    * globals
    * scenes for all places of the game such as levels, shop, cave etc
        * Not to be confused with the scenes in Godot, since player is a scene too
    * ui for hud and menus
1. Shared folder for shared scripts and components
1. Tests for testing stuff

## ⅍ Naming Conventions
1. snake_case for folders and files
1. PascalCase for nodes

## 🧑‍💻 Building & Exporting
1. Don't forget to setup/change your export presets
1. Done through: Project → Export 