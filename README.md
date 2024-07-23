# QBcore Claiming Script

## Description

The QBcore Claiming Script allows administrators to create claim zones within the game. Players from specific gangs can interact with these zones to claim them. The script includes features such as timers, chat notifications, and a map blip for the claim zone. Players who do not belong to specified gangs cannot see the blip zone.

## Features

- **Start Claim Command**: Admins can use the `/startclaim` command to initiate a claim zone at their location.
- **Stop Claim Command**: Admins can use the `/stopclaim` command to stop an ongoing claim.
- **Claim Zone Ped**: A ped spawns at the claim location to signify the claim zone.
- **Blip Zone**: A blip is created on the map to mark the claim zone with a radius set in the configuration. Only visible to allowed gangs.
- **Claim Timer**: A UI timer displays at the top of the screen, showing the time remaining for the claim.
- **Chat Notifications**: Notifications are sent to the chat when a claim starts, is claimed by a gang, and when the claim ends or is stopped.
- **Claim Interactions**: Players in allowed gangs can see and interact with the claim zone.
- **Claim Restrictions**: Once a gang claims the zone, they cannot claim it again until another gang claims it.

## Installation

1. **Download and extract the script** into your resources folder.

2. **Add the following line** to your `server.cfg`:
    \`\`\`
    ensure neon_claiming
    \`\`\`

3. **Ensure you have the required dependencies**:
    - `qb-core`
    - `oxmysql`

## Configuration

Edit the `config.lua` file to customize the script settings:

\`\`\`lua
Config = {}

-- Duration of the claim in seconds
Config.ClaimDuration = 600

-- Radius of the claim zone in meters
Config.ClaimZoneRadius = 100.0

-- Allowed gangs that can interact with the claim zone
Config.AllowedGangs = {
    'gang1',
    'gang2',
    -- Add more gangs here
}

-- Model of the ped to spawn at the claim location
Config.PedModel = 's_m_m_security_01'

-- Claim radius
Config.ClaimRadius = 5.0
\`\`\`

## Commands

- `/startclaim`: Starts a claim zone at the admin's location.
- `/stopclaim`: Stops the current claim zone.

## Events

- `neon_claiming:startClaim`: Starts the claim process and displays the UI and notifications.
- `neon_claiming:stopClaim`: Stops the claim process and hides the UI and notifications.
- `neon_claiming:claimZone`: Allows players to claim the zone if they are within the allowed gangs.
- `neon_claiming:notifyClaim`: Notifies players with allowed gangs that the zone has been claimed.
- `neon_claiming:notify`: Sends a chat notification to players with allowed gangs.
- `neon_claiming:notifyAll`: Sends a global notification to all players with allowed gangs.

## Usage

1. **Start the server** and ensure the resource is running.
2. **Admins can use the `/startclaim` command** to create a claim zone.
3. **Allowed players can approach the claim zone** and press `E` to claim it.
4. **Admins can use the `/stopclaim` command** to stop the ongoing claim.

## Contributing

Feel free to fork the repository and submit pull requests. Contributions are always welcome!

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
