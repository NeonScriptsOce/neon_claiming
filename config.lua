Config = {}

-- Duration of the claim in seconds
Config.ClaimDuration = 100

-- Radius of the claim zone in meters
Config.ClaimZoneRadius = 100.0

-- Allowed gangs that can interact with the claim zone
Config.AllowedGangs = {
    'gang1',
    'gang2'
    -- Add more gangs here
}

-- Model of the ped to spawn at the claim location
Config.PedModel = 's_m_m_security_01'

-- Claim radius
Config.ClaimRadius = 5.0

-- Ambulance script setting
Config.Ambulance = 'wasabi' -- options: 'wasabi', 'qb'

-- Interaction method
Config.Interaction = 'ox' -- options: 'target', 'drawtext', 'ox' (if selected ox it will use ox_lib Text UI)

-- Target system setting
Config.Target = 'ox_target' -- options: 'ox_target', 'qb-target'