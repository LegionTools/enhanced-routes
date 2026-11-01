local Routes = LibStub("AceAddon-3.0"):GetAddon("Routes")
local NV = Routes:NewModule("NodeVerification", "AceEvent-3.0")

local db -- Routes.db.global

-- A node within this many yards of the player when a gathering cast starts
-- is considered "being checked" by that cast.
local GATHER_MATCH_RADIUS = 15
-- How long to wait after a gathering cast starts for a matching
-- GatherMate2NodeAdded to arrive before counting the nearby unverified
-- points as a miss.
local MISS_CONFIRM_DELAY = 2.5

-- Same gathering spells GatherMate2's own Collector.lua watches for - a cast
-- of one of these can only start if the player targeted an actual gatherable
-- object, so UNIT_SPELLCAST_SENT firing for one of these is real evidence
-- *something* is there; whether it's the specific stored node we're near is
-- resolved by whether GatherMate2NodeAdded matches that node's coordinate.
local GATHERING_SPELLS = {}
for _, spellID in ipairs({2575, 2366, 7620, 131476, 30427, 3365, 22810, 1804, 73979, 93473, 167895}) do
	local spellName = GetSpellInfo(spellID)
	if spellName then GATHERING_SPELLS[spellName] = true end
end

-- Same world-distance approach as Modules/TomTom.lua's GetDistance()
local function GetDistance(mapID, x, y)
	local xCoord, yCoord, instance = Routes.Dragons:GetWorldCoordinatesFromZone(x, y, mapID, 0)
	if not xCoord then return math.huge end
	local xCoordPlayer, yCoordPlayer, instancePlayer = Routes.Dragons:GetPlayerWorldPosition()
	if not xCoordPlayer or instancePlayer ~= instance then return math.huge end
	return Routes.Dragons:GetWorldDistance(instance, xCoordPlayer, yCoordPlayer, xCoord, yCoord)
end

------------------------------------------------------------------------------------------------------
-- Public API (used by Plugins/GatherMate2.lua and the route-creation UI)

function Routes:GetNodeVerification(mapFile, coord)
	local zoneData = db.nodeVerification[mapFile]
	return zoneData and zoneData[coord]
end

function Routes:IsNodeVerified(mapFile, coord)
	local entry = self:GetNodeVerification(mapFile, coord)
	return entry ~= nil and entry.verified == true
end

-- Called whenever GatherMate2 confirms a node via an actual cast (see
-- Plugins/GatherMate2.lua). Also resolves any pending miss-check for this
-- exact coordinate, so a cast that successfully confirms a node doesn't
-- also get counted as a miss for it a couple seconds later.
function Routes:MarkNodeVerified(mapFile, coord)
	if not mapFile or not coord then return end
	db.nodeVerification[mapFile] = db.nodeVerification[mapFile] or {}
	local entry = db.nodeVerification[mapFile][coord]
	if not entry then
		entry = {}
		db.nodeVerification[mapFile][coord] = entry
	end
	entry.verified = true
	entry.missCount = nil
	entry.lastConfirmed = time()

	local pendingCast = NV.pendingCast
	if pendingCast and pendingCast.mapFile == mapFile then
		for _, pendingCoord in ipairs(pendingCast.coords) do
			if pendingCoord == coord then
				pendingCast.confirmedCoords = pendingCast.confirmedCoords or {}
				pendingCast.confirmedCoords[coord] = true
				break
			end
		end
	end
end

local function RecordMiss(mapFile, coord)
	db.nodeVerification[mapFile] = db.nodeVerification[mapFile] or {}
	local entry = db.nodeVerification[mapFile][coord]
	if entry and entry.verified then return end -- never downgrade an already-confirmed node
	if not entry then
		entry = {}
		db.nodeVerification[mapFile][coord] = entry
	end
	entry.missCount = (entry.missCount or 0) + 1
	entry.lastMiss = time()
end

------------------------------------------------------------------------------------------------------
-- Cast-gated miss detection

-- Every route point in the player's current zone that isn't verified yet and
-- is within GATHER_MATCH_RADIUS of the player right now - these are the
-- points "being checked" by a gathering cast starting this instant.
local function FindNearbyUnverifiedPoints(mapFile, mapID)
	local points = {}
	local zoneRoutes = db.routes[mapFile]
	if not zoneRoutes then return points end
	local seen = {}
	for _, route_data in pairs(zoneRoutes) do
		if type(route_data.route) == "table" then
			for _, coord in ipairs(route_data.route) do
				if not seen[coord] then
					seen[coord] = true
					if not Routes:IsNodeVerified(mapFile, coord) then
						local x, y = Routes:getXY(coord)
						if GetDistance(mapID, x, y) <= GATHER_MATCH_RADIUS then
							points[#points + 1] = coord
						end
					end
				end
			end
		end
	end
	return points
end

function NV:UNIT_SPELLCAST_SENT(event, unit, spellcast)
	if unit ~= "player" or not GATHERING_SPELLS[spellcast] then return end

	local mapID, level, mapFile = Routes.Dragons:GetPlayerZone()
	if not mapFile then return end

	local nearby = FindNearbyUnverifiedPoints(mapFile, mapID)
	if #nearby == 0 then return end

	local pendingCast = { mapFile = mapFile, coords = nearby }
	self.pendingCast = pendingCast

	C_Timer.After(MISS_CONFIRM_DELAY, function()
		if self.pendingCast ~= pendingCast then return end -- superseded by a newer cast
		for _, coord in ipairs(pendingCast.coords) do
			if not (pendingCast.confirmedCoords and pendingCast.confirmedCoords[coord]) then
				RecordMiss(pendingCast.mapFile, coord)
			end
		end
		self.pendingCast = nil
	end)
end

function NV:OnInitialize()
	db = Routes.db.global
	db.nodeVerification = db.nodeVerification or {}
end

function NV:OnEnable()
	self:RegisterEvent("UNIT_SPELLCAST_SENT")
end

-- vim: ts=4 noexpandtab
