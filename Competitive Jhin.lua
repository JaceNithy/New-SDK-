IncludeFile("Lib\\SDK.lua")

class "VirtuosoJhin"

function OnLoad()
    if GetChampName(GetMyChamp()) ~= "Jhin" then return end
    VirtuosoJhin:Assasin()
end

function VirtuosoJhin:Assasin()
    SetLuaCombo(true)

    myHero = GetMyHero()
  
    self.Q = Spell({Slot = 0, SpellType = Enum.SpellType.Targetted, Range = 550})
    self.W = Spell({Slot = 1, SpellType = Enum.SpellType.SkillShot, Range = 2550, SkillShotType = Enum.SkillShotType.Line, Collision = false, Width = 160, Delay = 400, Speed = 2000})
    self.E = Spell({Slot = 2, SpellType = Enum.SpellType.SkillShot, Range = 725,  SkillShotType = Enum.SkillShotType.Circle, Collision = false, Width = 160, Delay = 400, Speed = 2000})
    self.R = Spell({Slot = 3, SpellType = Enum.SpellType.SkillShot, Range = 3500,  SkillShotType = Enum.SkillShotType.Line, Collision = false, Width = 160, Delay = 400, Speed = 2000})
    ---self.BuffQ3 = function() return myHero.HasBuff("YasuoQ3W") end

    --Shot
    self.Buff4 = false
    self.TimeShot = 0
    self.Reload = false
    self.UtimateOn = false
    self.Passive = {}
    self.Uti1 = { }
    self.Uti2 = { }
    self.Uti3 = { }
    self.Uti4 = { }
    self.A1 = { }
    self.A2 = { }
    self.A3 = { }
    self.A4 = { }
    self.CCType = { [5] = "Stun", [8] = "Taunt", [11] = "Snare", [21] = "Fear", [22] = "Charm", [24] = "Suppression", }

    self:EveMenus()

    AddEvent(Enum.Event.OnTick, function(...) self:OnTick(...) end)
    AddEvent(Enum.Event.OnUpdateBuff, function(...) self:OnUpdateBuff(...) end)
    AddEvent(Enum.Event.OnRemoveBuff, function(...) self:OnRemoveBuff(...) end)
    AddEvent(Enum.Event.OnCreateObject, function(...) self:OnCreateObject(...) end)
    AddEvent(Enum.Event.OnDeleteObject, function(...) self:OnDeleteObject(...) end)
    AddEvent(Enum.Event.OnDraw, function(...) self:OnDraw(...) end)
    AddEvent(Enum.Event.OnDrawMenu, function(...) self:OnDrawMenu(...) end)

    __PrintTextGame("<b><font color=\"#64FE2E\">Competitive Jhin</font></b> <font color=\"##00FFFF\">Good murder</font>")
  
end 

  --SDK {{Toir+}}
function VirtuosoJhin:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function VirtuosoJhin:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function VirtuosoJhin:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function VirtuosoJhin:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function VirtuosoJhin:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function VirtuosoJhin:GetHeroes()
    SearchAllChamp()
    local t = pObjChamp
    return t
end

function VirtuosoJhin:GetEnemies(range)
    local t = {}
    local h = self:GetHeroes()
    for k,v in pairs(h) do
        if v ~= 0 then
            local hero = GetAIHero(v)
            if hero.IsEnemy and hero.IsValid and hero.Type == 0 and (not range or GetDistance(hero) < range) then
                table.insert(t, hero)
            end
        end
    end 
    return t
end

local function MinionsAround(object, range)
    object = object or myHero
    range = range or 1000
    CountEnemyMinionAroundObject(object.Addr, range)
end


local function ManaPercent(target)
    return target.MP/target.MaxMP * 100
end


function VirtuosoJhin:EveMenus()
    self.menu = "C.Jhin"
    --Combo [[ VirtuosoJhin ]]
    self.CQ = self:MenuBool("Combo Q", true)
    self.CDQ = self:MenuBool("Use Q Dash", true)
    self.CANQ = self:MenuBool("Use Q AntDash", true)
    self.CNQ = self:MenuBool("Use Q not Dash", false)

    self.PassiveForcedself = self:MenuBool("Forced [Buff]", true)

    self.CW = self:MenuBool("Combo W", true)
    self.AW = self:MenuBool("Auto W", true)
    self.IscWall = self:MenuBool("W + AA + Q", true) 

    self.CE = self:MenuBool("Combo E", true)
    self.GE = self:MenuBool("Gap [E]", true)

    self.hQ = self:MenuBool("Last Q", true)
    self.hE = self:MenuBool("Last E", true)
    self.hQ = self:MenuBool("Last Q", true)
    --AutoQ
    --self.AutoQ = self:MenuBool("Auto Q", true)
    
    self.UseRmy = self:MenuSliderInt("Auto W %", 45) 

     -- Modes
     self.ModeQ = self:MenuComboBox("Mode [Q]", 1)
     self.ModeW = self:MenuComboBox("Mode [W]", 1)
     self.ModeE = self:MenuComboBox("Mode [E]", 0)
 

     --Lane
     self.LQ = self:MenuBool("Lane Q", true)
     self.LW = self:MenuBool("Lane W", true)
     self.LE = self:MenuBool("Lane E", true)
     self.IsFa = self:MenuBool("Lane Safe", true)

     --Dor
     ---self.Modeself = self:MenuComboBox("Mode Self [R]", 1)

    --Add R
    self.CR = self:MenuBool("Combo R", true)
    self.AutoR = self:MenuBool("Use Logic R", true)
    self.ModeR = self:MenuComboBox("Mode [R]", 1)
    self.CountmINION = self:MenuSliderInt("Count Minions", 3)
    self.CountW = self:MenuSliderInt("Count Minions [W]", 5)
    self.LaneClearMana = self:MenuSliderInt("Mana Clear", 50)
    self.UseRally = self:MenuSliderInt("Distance Ally", 1)

    --KillSteal [[ VirtuosoJhin ]]
    self.KQ = self:MenuBool("KillSteal > Q", true)
    self.KW = self:MenuBool("KillSteal > R", true)

    --Draws [[ VirtuosoJhin ]]
    self.DQWER = self:MenuBool("Draw On/Off", false)
    self.DQ = self:MenuBool("Draw Q", true)
    self.DW = self:MenuBool("Draw W", true)
    self.DE = self:MenuBool("Draw E", true)
    self.DR = self:MenuBool("Draw R", true)

    self.Combo = self:MenuKeyBinding("Combo", 32)
    self.LaneClear = self:MenuKeyBinding("Lane Clear", 86)
    self.Act_Utim = self:MenuKeyBinding("Active ", 65)

    --Misc [[ VirtuosoJhin ]]
    --self.LogicR = self:MenuBool("Use Logic R?", true)]]
end

function VirtuosoJhin:OnDrawMenu()
	if not Menu_Begin(self.menu) then return end
		if (Menu_Begin("[Q] in Combo")) then
            self.CQ = Menu_Bool("Combo Q", self.CQ, self.menu)
            self.CDQ = Menu_Bool("Use Q Count", self.CDQ, self.menu)
			Menu_End()
        end
        if (Menu_Begin("[W] in Combo")) then
            self.CW = Menu_Bool("Combo W", self.CW, self.menu)
            self.AW = Menu_Bool("Auto W", self.AW, self.menu)
            self.IscWall = Menu_Bool("AA + W + Q", self.IscWall, self.menu)
			Menu_End()
        end
        if (Menu_Begin("[E] in Combo")) then
            self.CE = Menu_Bool("Combo E", self.CE, self.menu)
            self.GE = Menu_Bool("Trap [E]", self.GE, self.menu)
			Menu_End()
        end
        if (Menu_Begin("[R] in Combo")) then
            self.CR = Menu_Bool("Combo R", self.CR, self.menu)
            self.AutoR = Menu_Bool("Auto Shot", self.AutoR, self.menu)
			Menu_End()
        end
        if (Menu_Begin("[Passive] in Combo")) then
            self.PassiveForcedself = Menu_Bool("Passive Forced", self.PassiveForcedself, self.menu)
			Menu_End()
        end
        if Menu_Begin("Combo Spell") then
            self.ModeQ = Menu_ComboBox("Mode [Q]", self.ModeQ, "Always\0After Attack\0\0", self.menu)
            self.ModeW = Menu_ComboBox("Mode [W]", self.ModeW, "After Attack\0Only with the brand\0\0", self.menu)
            self.ModeE = Menu_ComboBox("Mode [E]", self.ModeE, "Always\0Stun\0\0", self.menu)
			Menu_End()
        end
        if (Menu_Begin("Lane")) then
            self.LQ = Menu_Bool("Lane Q", self.LQ, self.menu)
            self.LW = Menu_Bool("Lane W", self.LW, self.menu)
            self.LE = Menu_Bool("Lane E", self.LE, self.menu)
            self.CountmINION = Menu_SliderInt("Count Minions", self.CountmINION, 0, 5, self.menu)
            self.CountW = Menu_SliderInt("Count Minions [W]", self.CountW, 0, 5, self.menu)
            self.LaneClearMana = Menu_SliderInt("Lane Mana", self.LaneClearMana, 0, 100, self.menu)
			Menu_End()
        end
        if (Menu_Begin("Draws")) then
            self.DQWER = Menu_Bool("Draw On/Off", self.DQWER, self.menu)
            self.DW = Menu_Bool("Draw W", self.DW, self.menu)
			self.DR = Menu_Bool("Draw R", self.DR, self.menu)
			Menu_End()
        end
        if (Menu_Begin("KillSteal")) then
            self.KQ = Menu_Bool("KillSteal > Q", self.KQ, self.menu)
            self.KW = Menu_Bool("KillSteal > W", self.KW, self.menu)
			Menu_End()
        end
        if (Menu_Begin("Keys")) then
            self.Combo = Menu_KeyBinding("Combo", self.Combo, self.menu)
            self.LaneClear = Menu_KeyBinding("Lane Clear", self.LaneClear, self.menu)
            self.Act_Utim = Menu_KeyBinding("Active Utimate", self.Act_Utim, self.menu)
			Menu_End()
        end
	Menu_End()
end

function VirtuosoJhin:IsAfterAttack()
    if CanMove() and not CanAttack() then
        return true
    else
        return false
    end
end


function VirtuosoJhin:OnUpdateBuff(unit, buff)
    if unit.IsMe and buff.Name == "JhinPassiveReload" then
        self.Reload = true
       -- __PrintTextGame("Passive Reload")
    end
    if unit.IsMe and buff.Name == "jhinpassiveattackbuff" then
        self.Buff4 = true
        self.TimeShot = GetTimeGame()
       -- __PrintTextGame("Passive On")
    end 
end 

function VirtuosoJhin:OnRemoveBuff(unit, buff)
    if unit.isMe and buff.Name == "JhinPassiveReload" then
        self.Reload = false
	end
    if unit.IsMe and buff.Name == "jhinpassiveattackbuff" then
        self.Buff4 = false
        --__PrintTextGame("Passive Off")
        self.TimeShot = 0
    end 
    if not self.UtimateOn and not unit.IsMe and unit.TeamId ~= myHero.TeamId and self.CCType[buff.Type] then
		if self.W:IsReady() and GetDistance(unit) <= self.W.Range then CastSpellToPos(unit.x, unit.z, _W) end
		if self.E:IsReady() and GetDistance(unit) <= self.E.Range then CastSpellToPos(unit.x, unit.z, _E) end
    end
end 

function VirtuosoJhin:OnCreateObject(obj)
 if string.find(obj.Name, "JhinPassiveAttack") and obj.IsValid and not IsDead(obj.Addr) then
        self.Passive[obj.NetworkId] = obj
       -- __PrintTextGame("Passive [4]") --Utimo
    end
    if string.find(obj.Name, "JhinBasicAttack") and obj.IsValid and not IsDead(obj.Addr) then
        self.A1[obj.NetworkId] = obj
       -- __PrintTextGame("Passive [1]")
    end
    if string.find(obj.Name, "JhinBasicAttack2") and obj.IsValid and not IsDead(obj.Addr) then
        self.A2[obj.NetworkId] = obj
        --__PrintTextGame("Passive [2]")
    end
    if string.find(obj.Name, "JhinBasicAttack3") and obj.IsValid and not IsDead(obj.Addr) then
        self.A3[obj.NetworkId] = obj
       -- __PrintTextGame("Passive [3]")
    end
    --Utimate
    if string.find(obj.Name, "JhinRShotMis") and obj.IsValid and not IsDead(obj.Addr) then
        self.Uti1[obj.NetworkId] = obj
        --__PrintTextGame("Passive [1]") --Utimo
    end
    if string.find(obj.Name, "JhinRShotMis4") and obj.IsValid and not IsDead(obj.Addr) then
        self.Uti4[obj.NetworkId] = obj
       -- __PrintTextGame("Passive [4]") --Utimo
    end
end 

function VirtuosoJhin:OnDeleteObject(obj)
    for _, AttackPassive in pairs(self.Passive) do
		if AttackPassive.Addr == obj.Addr then
			table.remove(self.Passive, _)
		end
    end
    for _, Attack1 in pairs(self.A1) do
		if Attack1.Addr == obj.Addr then
			table.remove(self.A1, _)
		end
    end
    for _, Attack2 in pairs(self.A2) do
		if Attack2.Addr == obj.Addr then
			table.remove(self.A2, _)
		end
    end
    for _, Attack3 in pairs(self.A3) do
		if Attack3.Addr == obj.Addr then
			table.remove(self.A3, _)
		end
    end
    for _, Attack4 in pairs(self.A4) do
		if Attack4.Addr == obj.Addr then
			table.remove(self.A4, _)
		end
    end
    --Uti
    for _, Shot1 in pairs(self.Uti1) do
		if Shot1.Addr == obj.Addr then
			table.remove(self.Uti1, _)
		end
    end
    for _, Shot4 in pairs(self.Uti4) do
		if Shot4.Addr == obj.Addr then
			table.remove(self.Uti4, _)
		end
    end
end 

function VirtuosoJhin:IsMarked(target)
    return target.HasBuff("jhinespotteddebuff")
end

function VirtuosoJhin:OnDraw()
    if self.DQWER then return end 

    if self.W:IsReady() and self.DW then 
        local posQ3 = Vector(myHero)
        DrawCircleGame(posQ3.x , posQ3.y, posQ3.z, self.W.Range, Lua_ARGB(255,255,255,255))
    end
    if self.R:IsReady() and self.DR then 
        local posR = Vector(myHero)
        DrawCircleGame(posR.x , posR.y, posR.z, self.R.Range, Lua_ARGB(255,255,255,255))
    end 
end 

function VirtuosoJhin:AutoPassive()
    if self.PassiveForcedself then
		for i,hero in pairs(self:GetEnemies(GetTrueAttackRange())) do
			if IsValidTarget(hero, GetTrueAttackRange()) then
				target = GetAIHero(hero)
				if myHero.HasBuff("jhinpassiveattackbuff") then
					SetForcedTarget(target.Addr)
				end
			end
		end
	end
end 

function VirtuosoJhin:AutoShotUitmate()
    for i ,enemys in pairs(self:GetEnemies()) do
    local enemys = GetTargetSelector(self.R.Range)
    target = GetAIHero(enemys)
    if target ~= 0 then
	if self.UtimateOn and self.CR and sReady(_R) and IsValidTarget(target, self.R.Range) then
        local CPX, CPZ, UPX, UPZ, hc, AOETarget = GetPredictionCore(target.Addr, 0, self.R.delay, self.R.width, self.R.Range, self.R.speed, myHero.x, myHero.z, false, false, 10, 5, 5, 5, 5, 5)
        if hc >= 5 then
            CastSpellToPos(CPX,CPZ, _R)
        end 
    end 
    end 
    end    
end 

function VirtuosoJhin:AtiveUti()
    if GetSpellNameByIndex(myHero.Addr, _R) == "JhinR" then
        for i ,enemys in pairs(self:GetEnemies()) do
            local enemys = GetTargetSelector(self.R.Range)
            target = GetAIHero(enemys)
            if target ~= 0 then
                if self.CR and sReady(_R) and IsValidTarget(target, self.R.Range) then
                    local CPX, CPZ, UPX, UPZ, hc, AOETarget = GetPredictionCore(target.Addr, 0, self.R.delay, self.R.width, self.R.Range, self.R.speed, myHero.x, myHero.z, false, false, 10, 5, 5, 5, 5, 5)
                    if hc >= 5 then
                        CastSpellToPos(CPX,CPZ, _R)
                    end    
                end 
            end 
        end 
    end 
end 

function VirtuosoJhin:AutoW()
    for i ,enemys in pairs(self:GetEnemies()) do
        local enemys = GetTargetSelector(self.W.Range)
        target = GetAIHero(enemys)
        if target ~= 0 then
            if self.CW and sReady(_W) and self:IsMarked(target) and IsValidTarget(target, self.W.Range) then
                local CPX, CPZ, UPX, UPZ, hc, AOETarget = GetPredictionCore(target.Addr, 0, self.W.delay, self.W.width, self.W.Range, self.W.speed, myHero.x, myHero.z, false, false, 10, 5, 5, 5, 5, 5)
                if hc >= 5 then
                    CastSpellToPos(CPX,CPZ, _W)
                end   
            end 
        end 
    end  
end 

function VirtuosoJhin:CastQ()
    for i ,enemys in pairs(self:GetEnemies()) do
        local enemys = GetTargetSelector(self.Q.Range)
        target = GetAIHero(enemys)
        if target ~= 0 then
            if self.CQ and sReady(_Q) and self:IsAfterAttack(target) and IsValidTarget(target, self.Q.Range) then
                CastSpellTarget(target.Addr, _Q)
            end 
        end 
    end  
end 

function VirtuosoJhin:CastW()
    for i ,enemys in pairs(self:GetEnemies()) do
        local enemys = GetTargetSelector(self.W.Range)
        target = GetAIHero(enemys)
        if target ~= 0 then
            if self.CW and sReady(_W) and self:IsAfterAttack(target) and IsValidTarget(target, self.W.Range) then
                local CPX, CPZ, UPX, UPZ, hc, AOETarget = GetPredictionCore(target.Addr, 0, self.W.delay, self.W.width, self.W.Range, self.W.speed, myHero.x, myHero.z, false, false, 10, 5, 5, 5, 5, 5)
                if hc >= 5 then
                    CastSpellToPos(CPX,CPZ, _W)
                end   
            end 
        end 
    end  
end 

function VirtuosoJhin:CastE()
    for i ,enemys in pairs(self:GetEnemies()) do
        local enemys = GetTargetSelector(self.E.Range)
        target = GetAIHero(enemys)
        if target ~= 0 then
            if self.CE and sReady(_E) and IsValidTarget(target, self.E.Range) then
                local CPX, CPZ, UPX, UPZ, hc, AOETarget = GetPredictionCore(target.Addr, 0, self.E.delay, self.E.width, self.E.Range, self.E.speed, myHero.x, myHero.z, false, false, 10, 5, 5, 5, 5, 5)
                if hc >= 5 then
                    CastSpellToPos(CPX,CPZ, _E)
                end   
            end 
        end 
    end  
end 

function VirtuosoJhin:ComboJhin()
    if self.CQ then
        self:CastQ()
    end
    if self.CW then
        self:CastW()
    end 
    if self.CE then
        self:CastE()
    end 
end 

function VirtuosoJhin:KillIni()
    for i ,enemys in pairs(self:GetEnemies()) do
        local enemys = GetTargetSelector(self.W.Range)
        target = GetAIHero(enemys)
        if target ~= 0 then
            if self.KW and sReady(_W) and IsValidTarget(target, self.W.Range) and self.W:GetDamage(target) > target.HP then
                local CPX, CPZ, UPX, UPZ, hc, AOETarget = GetPredictionCore(target.Addr, 0, self.W.delay, self.W.width, self.W.Range, self.W.speed, myHero.x, myHero.z, false, false, 10, 5, 5, 5, 5, 5)
                if hc >= 5 then
                    CastSpellToPos(CPX,CPZ, _W)
                end   
            end 
        end 
    end 
    for i ,enemys in pairs(self:GetEnemies()) do
        local enemys = GetTargetSelector(self.W.Range)
        target = GetAIHero(enemys)
        if target ~= 0 then
            if self.KQ and sReady(_W) and IsValidTarget(target, self.Q.Range) and self.W:GetDamage(target) > target.HP then
                CastSpellTarget(target.Addr, _Q)
            end 
        end 
    end  
end 

function VirtuosoJhin:EnemyMinionsTbl() --SDK Toir+
    GetAllUnitAroundAnObject(myHero.Addr, 2000)
    local result = {}
    for i, obj in pairs(pUnit) do
        if obj ~= 0  then
            local minions = GetUnit(obj)
            if IsEnemy(minions.Addr) and not IsDead(minions.Addr) and not IsInFog(minions.Addr) and GetType(minions.Addr) == 1 then
                table.insert(result, minions)
            end
        end
    end
    return result
end

function VirtuosoJhin:OnTick()
    if (IsDead(myHero.Addr) or myHero.IsRecall or IsTyping() or IsDodging()) or not IsRiotOnTop() then return end
    --self:AutoR()
    self:AutoPassive()
    self:AutoShotUitmate()
    self:AutoW()
    self:KillIni()

    if GetSpellNameByIndex(myHero.Addr, _R) == "JhinRShot" then
        self.UtimateOn = true
    else
        self.UtimateOn = false
    end
  ----__PrintDebug(spell.Name)
    if GetKeyPress(self.Combo) > 0 then	
      self:ComboJhin()
    end
    if GetKeyPress(self.LaneClear) > 0 then	
        self:LaneClearQWE()
      end
    if GetKeyPress(self.Act_Utim) > 0 then	
        self:AtiveUti()
    end
end 

function sReady(slot)
    return CanCast(slot)
end