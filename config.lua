Config = {}

-- !!!!!!!!
Config.LocalFilePath = 'D:\\FiveM\\LocalHost\\txData\\default\\data\\playersDB.json'  -- the locak file path to the playersDB.json. Is most likely in \txData\default\data
-- !!!!!!!!

-- Time for New member in minutes
Config.Time = {
    f = 600, -- from when the player has to give feedback
    u = 900       -- until when the player can give feedback
}

-- Outfit for the Admins
-- !!!!! DONT CHANGE THE KEYS OR THE CONPONENTID !!!!!
Config.Components = { 
    ['pants'] = {drawableId = 5, textureId = 0},      
    ['shirt'] = {drawableId = 5, textureId = 0},   
    ['shoes'] = {drawableId = 5, textureId = 0},   
    ['mask'] = {drawableId = 5, textureId = 0},     
    ['bag'] = {drawableId = 5, textureId = 0},       
    ['accessory'] = {drawableId = 5, textureId = 0}, 
    ['undershirt'] = {drawableId = 5, textureId = 0},
    ['bodyArmor'] = {drawableId = 5, textureId = 0},  
    ['decals'] = {drawableId = 5, textureId = 0},    
    ['upperbody'] = {drawableId = 5, textureId = 0}   
}

Config.Props = {
    ['hat'] = {drawableId = 1, textureId = 0},
    ['glasses'] = {drawableId = 1, textureId = 0},
    ['earrings'] = {drawableId = 1, textureId = 0}
}



-- NPC
Config.Npc = {
    Model = 'a_m_y_business_01',
    Coords = vector3(-1008.2666, -2741.1960, 13.7571)
}


-- Discord
Config.DiscordWebhook = {
    Url = 'https://discord.com/api/webhooks/1284852503791407166/3vbNEkXdNSVBdmhVXLqCQ__dVyeXMh0pUg3HDNqY4cIWUtmdZWnzeWD7q60Gc-Q8FXPI',
    Name = 'Feedback',
    Color = 5761720
}
