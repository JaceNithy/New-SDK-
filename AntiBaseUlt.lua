IncludeFile("Lib\\SDK.lua")

AntiBaseUltVersion = "0.04"

class "AntiBaseUlt"

function OnLoad()
    AntiBaseUlt:__init()
end

function AntiBaseUlt:__init()
  __PrintTextGame("<b><font color='#EE2EC'> Anti-BaseUlt - </font></b> Loaded v" ..AntiBaseUltVersion)
  --self.cfg = MenuConfig("AntiBaseUlt", "Anti-BaseUlt")
  --self.cfg:Boolean("Enabled", "Enabled", true)

  myHero = GetMyHero()
  self.SpellData = {
    ["Ashe"] = {
      MissileName = "EnchantedCrystalArrow",
      MissileSpeed = 1600,
    },

    ["Draven"] = {
      MissileName = "DravenDoubleShotMissile",
      MissileSpeed = 2000,
    },

    ["Ezreal"] = {
      MissileName = "EzrealTrueshotBarrage",
      MissileSpeed = 2000,
    },

    ["Jinx"] = {
      MissileName = "JinxR",
      MissileSpeed = 1700,
    }
  }
  self:MenuAnti()
  self.missiles = {}
  self.Recalling = {}
  self.objects = {}
  self.maxObjects = 0
  self.RecallingTime = 0
  self.LastPrint = 0
  self.fountain = nil
  self.fountainRange = mapID == SUMMONERS_RIFT and 1050 or 750

  AddEvent(Enum.Event.OnTick, function(...) self:OnTick(...) end)
  AddEvent(Enum.Event.OnCreateObject, function(Object) self:OnCreateObject(Object) end)
  AddEvent(Enum.Event.OnDeleteObject, function(Object) self:OnDeleteObject(Object) end)
  AddEvent(Enum.Event.OnProcessSpell, function(unit, recall) self:OnProcessSpell(unit, recall) end)
  AddEvent(Enum.Event.OnDrawMenu, function(...) self:OnDrawMenu(...) end)
  --Callback.Add("ObjectLoad", function(Object) self:CreateObj(Object) end)
  --Callback.Add("CreateObj", function(Object) self:CreateObj(Object) end)
  --Callback.Add("ProcessRecall", function(unit, recall) self:ProcessRecall(unit, recall) end)
  --Callback.Add("Tick", function() self:Tick() end)
end

--locais
local Obj_AI_SpawnPoint = 6

function GetObjectByNetworkId(NetworkID)
    for i=1, self.maxObjects do
            if self.objects[i].NetworkId == NetworkID then
                return self.objects[i]
        end
    end
end

function AntiBaseUlt:MenuAnti()
    self.menu = "Anti-BaseUlt"
    self.EnabledBase = self:MenuBool("Enabled", true)
  end
  
  function AntiBaseUlt:OnDrawMenu()
    if Menu_Begin(self.menu) then
      self.EnabledBase = Menu_Bool("Auto", self.EnabledBase, self.menu)
      Menu_End()
    end
end

function AntiBaseUlt:OnCreateObject(Object)
  if GetType(Object) == Obj_AI_SpawnPoint and Object.TeamId == myHero.TeamId then
    self.fountain = Object
  end
  if self.SpellData[GetObjectByNetworkId(Object)] and self.SpellData[GetObjectByNetworkId(Object)].MissileName == Object.NetworkId then
    table.insert(self.missiles, Object)
  end
end

function AntiBaseUlt:OnProcessSpell(unit, recall)
  if unit.IsMe and recall.start then
    self.RecallingTime = GetTickCount() 
  end
end

function AntiBaseUlt:OnTick()
  if not myHero.IsRecall or myHero.IsDead then return end

    if myHero.IsRecall then
      table.insert(self.Recalling, {champ = myHero, hp = myHero.HP, name = myHero.CharName, start = GetTimeGame(), duration = 8})
    else
      for i, recall in pairs(self.Recalling) do        
        if (GetIndex(recall.champ) == GetIndex(myHero) and recall.name == myHero.CharName)  then
          table.remove(self.Recalling, i)
      end
    end
  end
  for i, recall in pairs(self.Recalling) do        
    if recall.start + recall.duration < GetTimeGame()  then
      table.remove(self.Recalling, i)
    end
   end
  end

  for i, missile in pairs(self.missiles) do
    if self.R:GetDamage(GetObjectByNetworkId(missile), myHero, 3) > GetCurrentHP(myHero) and self:InFountain(GetObjectByNetworkId(missile)) and self.RecallingTime > (GetDistance(missile, self.fountain) / self.SpellData[GetObjectByNetworkId(missile)].MissileSpeed * 1000) then
      MoveTo(myHero.x+100,myHero.y, myHero.z+100)
      if GetTickCount()-self.LastPrint > 1000 then
        __PrintTextGame("<b><font color='#EE2EC'> Anti-BaseUlt - </font></b> Prevented A Baseult From "..GetObjectName(GetObjectByNetworkId(missile))" ")
        self.LastPrint = GetTickCount()
      end
    end
  end
end

function AntiBaseUlt:InFountain(pos)
  return GetDistance(self.fountain, pos) < self.fountainRange
end

