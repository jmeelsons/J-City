---@diagnostic disable: inject-field

local TRIP_FORWARD_DISTANCE = 25                                                                                           -- how far ahead to check
local TRIP_COOLDOWN         = CreateConVar("player_trip_cooldown", "4", { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY }) -- trip cooldown (0 is most likely infinite)
local TRIP_DURATION         = CreateConVar("player_trip_duration", "3", { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY }) -- how long should player stay ragdolled (костыли ебейшие)
local TRIP_GETUP_ANYTIME    = CreateConVar("player_trip_getup_anytime", "0",
    { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY })
local TRIP_GETUP_ANY_KEY    = CreateConVar("player_trip_getup_any_key", "0",
    { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY })
local TRIP_GETUP_DELAY      = CreateConVar("player_trip_getup_delay", "2.0",
    { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY })

if SERVER then
    util.AddNetworkString("PlayerTrip_Sync")

    local RequireSprinting = CreateConVar("player_trip_require_sprint", "1",
        { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED })
    local TripOverAnything = CreateConVar("player_trip_on_anything", "0",
        { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED })
    local TripChance = CreateConVar("player_trip_chance", "1.0",
        { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED })
    local RandomTripEnabled = CreateConVar("player_randomtrip_enabled", "0",
        { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED })
    local RandomTripChance = CreateConVar("player_randomtrip_chance", "0.02",
        { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED })
    local RandomTripMinSpeed = CreateConVar("player_randomtrip_minspeed", "300",
        { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED })

    local coolDowns = {}
    local randomTripCooldowns = {}
    local getupCooldowns = {}
    local activeTrips = {} -- храним игрока в деревяном гробу

    local function UnragdollPlayer(ply)
        if not IsValid(ply) or not ply:Alive() then return end

        if activeTrips[ply] and activeTrips[ply] > CurTime() then
            return
        end

        if hg.FakeUp and ply:GetNWBool("IsTrippedRagdoll") then
            local ragdoll = ply.FakeRagdoll
            if IsValid(ragdoll) and ragdoll.TripSavedWeapons then
                ply.TripSavedWeapons = ragdoll.TripSavedWeapons
                ragdoll.TripSavedWeapons = nil
            end
            
            hg.FakeUp(ply, true, false) -- true = forced, false = не мгновенно
        end
        
        activeTrips[ply] = nil
        ply:SetNWBool("IsTrippedRagdoll", false)
        ply:SetNWEntity("TripRagdollEnt", NULL)
    end

    --- @param ply Player
    local function TripPlayer(ply, velocity)
        if coolDowns[ply] and coolDowns[ply] > CurTime() then return end
        if ply:GetNWBool("IsTrippedRagdoll") then return end
        if IsValid(ply.FakeRagdoll) then return end

        getupCooldowns[ply] = CurTime() + TRIP_GETUP_DELAY:GetFloat()
        coolDowns[ply] = CurTime() + TRIP_COOLDOWN:GetFloat()

        if hg.Fake then
            local savedWeps = {}
            for _, wep in ipairs(ply:GetWeapons()) do
                if IsValid(wep) then
                    table.insert(savedWeps, {
                        class = wep:GetClass(),
                        clip1 = wep:Clip1(),
                        clip2 = wep:Clip2()
                    })
                end
            end

            hg.Fake(ply, nil, false, true)
            
            local ragdoll = ply.FakeRagdoll
            if IsValid(ragdoll) then
                ragdoll.TripSavedWeapons = savedWeps
            end
        end

        ply:SetNWBool("IsTrippedRagdoll", true)
        
        local ragdoll = ply.FakeRagdoll
        if IsValid(ragdoll) then
            ply:SetNWEntity("TripRagdollEnt", ragdoll)

            local physCount = ragdoll:GetPhysicsObjectCount()
            for i = 0, physCount - 1 do
                local phys = ragdoll:GetPhysicsObjectNum(i)
                if IsValid(phys) then
                    phys:SetVelocity(velocity * 1.2 + Vector(0, 0, 50))
                    phys:Wake()
                end
            end
        end

        activeTrips[ply] = CurTime() + TRIP_DURATION:GetFloat()
    end

    local function CheckAndUnragdoll(ply)
        if not IsValid(ply) then return end
        if not ply:GetNWBool("IsTrippedRagdoll") then return end
        
        local ragdoll = ply.FakeRagdoll
        if not IsValid(ragdoll) then
            UnragdollPlayer(ply)
            return
        end
        

        if not activeTrips[ply] or activeTrips[ply] > CurTime() then
            return
        end

        local pelvisPhys = ragdoll:GetPhysicsObjectNum(0)
        if IsValid(pelvisPhys) then
            local isSettled = pelvisPhys:GetVelocity():Length() < 15
            local inWater = ragdoll:WaterLevel() > 0
            
            local groundCheck = util.TraceLine({
                start = ragdoll:WorldSpaceCenter(),
                endpos = ragdoll:WorldSpaceCenter() - Vector(0, 0, 30),
                filter = ragdoll
            })
            
            if (isSettled or inWater) and groundCheck.Hit then
                UnragdollPlayer(ply)
            end
        end
    end

    hook.Add("KeyPress", "TripGetupKey", function(ply, key)
        if not ply:IsPlayer() or not ply:Alive() then return end
        if not ply:GetNWBool("IsTrippedRagdoll") then return end
        
        if TRIP_GETUP_ANYTIME:GetBool() then
            if key == IN_JUMP or TRIP_GETUP_ANY_KEY:GetBool() then
                local readyTime = getupCooldowns[ply] or 0
                if CurTime() >= readyTime then
                    UnragdollPlayer(ply)
                end
            end
        end
    end)

    local checkTimer = 0
    hook.Add("Tick", "TripRagdollGroundCheck", function()
        checkTimer = checkTimer + 1
        if checkTimer < 5 then return end
        checkTimer = 0
        
        for ply, _ in pairs(activeTrips) do
            if IsValid(ply) then
                CheckAndUnragdoll(ply)
            else
                activeTrips[ply] = nil
            end
        end
    end)

    hook.Add("PlayerTick", "PlayerTripCheck", function(ply, mv)
        if not ply:Alive() or ply:InVehicle() or ply:GetMoveType() == MOVETYPE_NOCLIP then return end
        if ply:GetNWBool("IsTrippedRagdoll") then return end

        local vel = ply:GetVelocity()
        local speed = vel:Length()

        if speed > 400 then
            local eyeAngles = ply:EyeAngles()
            eyeAngles.p = 0
            local forward = eyeAngles:Forward()

            local startPos = ply:GetPos() + Vector(0, 0, 5)
            local endPos = startPos + (forward * (TRIP_FORWARD_DISTANCE + 5))

            local tr = util.TraceHull({
                start = startPos,
                endpos = endPos,
                mins = Vector(-10, -10, -5),
                maxs = Vector(10, 10, 5),
                filter = ply
            })

            if tr.Hit and not tr.HitWorld then
                local targetEntity = tr.Entity

                if targetEntity and IsValid(targetEntity) and not targetEntity:IsWorld() then
                    local meetsSprint = not RequireSprinting:GetBool() or ply:IsSprinting()
                    local meetsWhitelist = TripOverAnything:GetBool() or
                        table.HasValue({"prop_physics", "prop_ragdoll"}, targetEntity and targetEntity:GetClass() or "")

                    if meetsSprint and meetsWhitelist then
                        if math.random() < TripChance:GetFloat() then
                            TripPlayer(ply, vel)
                        end
                    end
                end
            end
        end
    end)

    hook.Add("DoPlayerDeath", "TripRagdollDeath", function(ply, attacker, dmg)
        if ply:GetNWBool("IsTrippedRagdoll") then
            activeTrips[ply] = nil
            ply:SetNWBool("IsTrippedRagdoll", false)
            ply:SetNWEntity("TripRagdollEnt", NULL)
        end
    end)

    hook.Add("PlayerDisconnected", "TripCleanup", function(ply)
        activeTrips[ply] = nil
        coolDowns[ply] = nil
        randomTripCooldowns[ply] = nil
        getupCooldowns[ply] = nil
    end)

    hook.Add("Move", "PlayerRandomTripCheck", function(ply, mv)
        if not ply:Alive() or ply:InVehicle() or ply:GetMoveType() == MOVETYPE_NOCLIP then return end
        if ply:GetNWBool("IsTrippedRagdoll") then return end
        if not ply:IsSprinting() then return end
        if not RandomTripEnabled:GetBool() then return end

        local vel = ply:GetVelocity()
        local speed = vel:Length2D()
        local minSpeed = RandomTripMinSpeed:GetFloat()

        if speed > minSpeed then
            if randomTripCooldowns[ply] and randomTripCooldowns[ply] > CurTime() then return end
            
            if math.random() < RandomTripChance:GetFloat() then
                TripPlayer(ply, vel)
            end

            randomTripCooldowns[ply] = CurTime() + TRIP_COOLDOWN:GetFloat() + 5
        end
    end)

    hook.Add("PlayerJump", "TripJumpGetup", function(ply)
        if not ply:GetNWBool("IsTrippedRagdoll") then return end
        if not TRIP_GETUP_ANYTIME:GetBool() then return end
        
        local readyTime = getupCooldowns[ply] or 0
        if CurTime() >= readyTime then
            UnragdollPlayer(ply)
        end
    end)
end
