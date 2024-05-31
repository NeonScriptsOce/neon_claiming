Config = {}

-- Duration of the claim in seconds
Config.ClaimDuration = 30

-- Radius of the claim zone in meters
Config.ClaimZoneRadius = 100.0

-- Radius within which the player can claim the ped
Config.ClaimRadius = 0.8

-- Allowed gangs that can interact with the claim zone
Config.AllowedGangs = {
    'gang1',
    'gang2',
    -- Add more gangs here
}

-- Model of the ped to spawn at the claim location
Config.PedModel = 's_m_m_security_01'