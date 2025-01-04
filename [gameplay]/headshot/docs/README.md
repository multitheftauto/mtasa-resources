# Headshot
Headshot feature for enhanced combat realism and damage effect — Made with 💖 by Multi Theft Developers.

> [!NOTE]
> This resource is a part of the [mtasa-blue](https://github.com/multitheftauto/mtasa-resources) repository, any updates, fixes or patches are only available there.

> [!IMPORTANT]
> The minimum version requirement for the server is 1.6.0. You can always download the latest binaries [here](https://nightly.multitheftauto.com/).

## Settings
| name  | description                                                     | default | accept      |
|-------|-----------------------------------------------------------------|---------|-------------|
| decap | determines whether the player becomes headless after a headshot | true    | false, true |

## Events

### onPlayerHeadshot
This event is called when a player is shot in the head and dies.

#### Parameters
```lua
player attacker, int cause
```
- attacker: a player element who was the attacker
- cause: a number representing the attacker weapon or other damage type

#### Cancel
This event cannot be cancelled.

#### Example
```lua
addEventHandler("onPlayerHeadshot", root,
    function(attacker, cause)
        local name = getPlayerName(source)

        if attacker and isElement(attacker) and getElementType(attacker) == "player" then
            attacker = getPlayerName(attacker)
        else
            attacker = "Unknown"
        end

        if cause and type(cause) == "number" then
            cause = getWeaponNameFromID(cause)
        else
            cause = "Unknown"
        end

        outputServerLog(name .. " was shot in the head by " .. attacker .. " using " .. cause)
    end
)
```

### onPlayerPreHeadshot
This event is called when a player is shot in the head but has not yet been killed by the resource.

#### Parameters
```lua
player attacker, int cause, int damage 
```
- attacker: a player element who was the attacker
- cause: a number representing the attacker weapon or other damage type
- damage: a number representing the health originally lost by the shot

#### Cancel
This event can be cancelled, preventing the player from being killed.

#### Example
```lua
addEventHandler("onPlayerPreHeadshot", root,
    function(_, _, damage)
        if damage < 5 then
            cancelEvent()
        end
    end
)
```