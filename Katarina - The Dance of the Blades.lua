IncludeFile("Lib\\SDK.lua")

class "DanceKat"

function OnLoad()
    if GetChampName(GetMyChamp()) ~= "Katarina" then return end
    DanceKat:Assasin()
end

function DanceKat:Assasin()
    SetLuaCombo(true)
    SetLuaLaneClear(true)
    SetPrintErrorLog(false)

    myHero = GetMyHero()
  
    self.Q = Spell({Slot = 0, SpellType = Enum.SpellType.Targetted, Range = 625})
    self.W = Spell({Slot = 1, SpellType = Enum.SpellType.Active, Range = 340})
    self.E = Spell({Slot = 2, SpellType = Enum.SpellType.SkillShot, Range = 725, SkillShotType = Enum.SkillShotType.Circle, Collision = false, Width = 160, Delay = 400, Speed = 2000})
    self.R = Spell({Slot = 3, SpellType = Enum.SpellType.Active, Range = 550})

    self:EveMenus()

    self.dgr = 0
    self.RCastTime = 0
    self.Dagger = { }
    self.Active = false 
  

    AddEvent(Enum.Event.OnTick, function(...) self:OnTick(...) end)
    AddEvent(Enum.Event.OnUpdateBuff, function(...) self:OnUpdateBuff(...) end)
    AddEvent(Enum.Event.OnRemoveBuff, function(...) self:OnRemoveBuff(...) end)
    AddEvent(Enum.Event.OnCreateObject, function(...) self:OnCreateObject(...) end)
    AddEvent(Enum.Event.OnDeleteObject, function(...) self:OnDeleteObject(...) end)
    AddEvent(Enum.Event.OnProcessSpell, function(...) self:OnProcessSpell(...) end) 
    AddEvent(Enum.Event.OnDraw, function(...) self:OnDraw(...) end)
    AddEvent(Enum.Event.OnDrawMenu, function(...) self:OnDrawMenu(...) end)
    AddEvent(Enum.Event.OnPlayAnimation, function(...) self:OnPlayAnimation(...) end) 
    AddEvent(Enum.Event.OnWndMsg, function(...) self:OnWndMsg(...) end) 
  
end 

  --SDK {{Toir+}}
function DanceKat:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function DanceKat:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function DanceKat:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function DanceKat:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function DanceKat:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function DanceKat:EveMenus()
    self.menu = "Katarina"
    --Combo [[ DanceKat ]]
    self.CQ = self:MenuBool("Combo Q", true)
    self.CW = self:MenuBool("Combo W", true)
    self.CE = self:MenuBool("Combo E", true)
    self.GE = self:MenuBool("Gap [E]", true)

    --Clear
    self.hQ = self:MenuBool("Last Q", true)
    self.hE = self:MenuBool("Last E", true)

     --Lane
     self.LQ = self:MenuBool("Lane Q", true)
     self.LW = self:MenuBool("Lane W", true)
     self.LE = self:MenuBool("Lane E", true)
     self.IsFa = self:MenuBool("Lane Safe", true)

     self.EonlyD = self:MenuBool("Only on Dagger", true)
     self.FleeW = self:MenuBool("Flee [W]", true)
     self.FleeMousePos = self:MenuBool("Flee [Mouse]", true)
     --Dor
     ---self.Modeself = self:MenuComboBox("Mode Self [R]", 1)
     -- EonlyD 

    --Add R
    self.CR = self:MenuBool("Combo R", true)
    self.RAmount = self:MenuSliderInt("Distance Enemys", 2)
    self.UseRally = self:MenuSliderInt("Distance Ally", 1)

    --KillSteal [[ DanceKat ]]
    self.KQ = self:MenuBool("KillSteal > Q", true)
    self.KR = self:MenuBool("KillSteal > R", true)
    self.KE = self:MenuBool("KillSteal > E", true)

    --Draws [[ DanceKat ]]
    self.DQWER = self:MenuBool("Draw On/Off", false)
    self.DaggerDraw = self:MenuBool("Draw Dagger", true)
    self.DQ = self:MenuBool("Draw Q", true)
    self.DW = self:MenuBool("Draw W", true)
    self.DE = self:MenuBool("Draw E", true)
    self.DR = self:MenuBool("Draw R", true)

    self.Combo = self:MenuKeyBinding("Combo", 32)
    self.LaneClear = self:MenuKeyBinding("Lane Clear", 86)
    self.Last_Hit = self:MenuKeyBinding("Last Hit", 88)
    self.Flee_Kat = self:MenuKeyBinding("Flee", 90)

    --Misc [[ DanceKat ]] -- EonlyD 
    --self.LogicR = self:MenuBool("Use Logic R?", true)]]
end

function DanceKat:OnDrawMenu()
	if not Menu_Begin(self.menu) then return end
		if (Menu_Begin("Combo")) then
            self.CQ = Menu_Bool("Combo Q", self.CQ, self.menu)
            self.CW = Menu_Bool("Combo W", self.CW, self.menu)
            self.CE = Menu_Bool("Combo E", self.CE, self.menu)
            self.EonlyD = Menu_Bool("Only on Dagger", self.EonlyD, self.menu)
            self.CR = Menu_Bool("Combo R", self.CR, self.menu)
			Menu_End()
        end
        if (Menu_Begin("Lane")) then
            self.LQ = Menu_Bool("Lane Q", self.LQ, self.menu)
            self.LW = Menu_Bool("Lane W", self.LW, self.menu)
            self.LE = Menu_Bool("Lane E", self.LE, self.menu)
            self.IsFa = Menu_Bool("Lane Safe", self.IsFa, self.menu)
			Menu_End()
        end
        if (Menu_Begin("Last")) then
            self.hQ = Menu_Bool("Last Q", self.hQ, self.menu)
            self.hE = Menu_Bool("Last E", self.hE, self.menu)
			Menu_End()
        end
        if (Menu_Begin("Draws")) then
            self.DQWER = Menu_Bool("Draw On/Off", self.DQWER, self.menu)
            self.DaggerDraw = Menu_Bool("Draw Dagger", self.DaggerDraw, self.menu)
            self.DQ = Menu_Bool("Draw Q", self.DQ, self.menu)
            self.DW = Menu_Bool("Draw W", self.DW, self.menu)
            self.DE = Menu_Bool("Draw E", self.DE, self.menu)
			self.DR = Menu_Bool("Draw R", self.DR, self.menu)
			Menu_End()
        end
        if (Menu_Begin("KillSteal")) then
            self.KQ = Menu_Bool("KillSteal > Q", self.KQ, self.menu)
            self.KE = Menu_Bool("KillSteal > E", self.KE, self.menu)
            self.KR = Menu_Bool("KillSteal > R", self.KR, self.menu)
			Menu_End()
        end
        if (Menu_Begin("Flee")) then
            self.FleeW = Menu_Bool("Flee [W]", self.FleeW, self.menu)
            self.FleeMousePos = Menu_Bool("Flee [Mouse]", self.FleeMousePos, self.menu)
			Menu_End()
        end
        if (Menu_Begin("Keys")) then
            self.Combo = Menu_KeyBinding("Combo", self.Combo, self.menu)
            self.LaneClear = Menu_KeyBinding("Lane Clear", self.LaneClear, self.menu)
            self.Flee_Kat = Menu_KeyBinding("Flee", self.Flee_Kat, self.menu)
            self.Last_Hit = Menu_KeyBinding("Last Hit", self.Last_Hit, self.menu)
			Menu_End()
        end
	Menu_End()
end

function DanceKat:GetHeroes()
	SearchAllChamp()
	local t = pObjChamp
	return t
end

function DanceKat:GetEnemies(range)
  local t = {}
  local h = self:GetHeroes()
  for k, v in pairs(h) do
    if v ~= 0 then
      local hero = GetAIHero(v)
      if hero.IsEnemy and hero.IsValid and hero.Type == 0 and (not range or range > GetDistance(hero)) then
        table.insert(t, hero)
      end
    end
  end
  return t
end

function DanceKat:OnPlayAnimation(unit, animationName)
    if unit.IsMe then
        if animationName == "Spell4" then 
            self.Active = true
        else
            self.Active = false
        end
    end
end

function DanceKat:OnWndMsg(msg, key)
    if msg == WM_RBUTTONDOWN and self.Active then 
		self.Active = false
	end
end

function DanceKat:OnCreateObject(obj)
    if obj and obj.IsValid and obj.NetworkId and obj.NetworkId ~= 0 then
    if string.find(obj.Name, "Katarina_Base_W_Indicator_Ally") or string.find(obj.Name, "Katarina_Skin01_W_Indicator_Ally") or string.find(obj.Name, "katarina_Skin02_W_Indicator_Ally") or string.find(obj.Name, "Katarina_Skin03_W_Indicator_Ally") or string.find(obj.Name, "katarina_skin04_w_indicator_ally") or string.find(obj.Name, "katarina_skin05_w_indicator_ally") or string.find(obj.Name, "katarina_skin06_w_indicator_ally") or  string.find(obj.Name, "katarina_skin07_w_indicator_ally") or  string.find(obj.Name, "katarina_skin08_w_indicator_ally") or string.find(obj.Name, "Katarina_Skin09_W_Indicator_Ally") or string.find(obj.Name, "katarina_skin10_w_indicator_ally") then
        self.Dagger[obj.NetworkId] = obj
            self.dgr = self.dgr + 1
           -- __PrintTextGame("Ok?")
        end 
    end
end

--Katarina_Base_W_Indicator_Ally.troy

function DanceKat:OnDeleteObject(obj)
    if obj and obj.IsValid and obj.NetworkId and obj.NetworkId ~= 0 then
    if string.find(obj.Name, "Katarina_Base_W_Indicator_Ally") or string.find(obj.Name, "Katarina_Skin01_W_Indicator_Ally") or string.find(obj.Name, "katarina_Skin02_W_Indicator_Ally") or string.find(obj.Name, "Katarina_Skin03_W_Indicator_Ally") or string.find(obj.Name, "Katarina_Skin04_W_Indicator_Ally") or string.find(obj.Name, "katarina_skin05_w_indicator_ally") or string.find(obj.Name, "katarina_skin06_w_indicator_ally") or  string.find(obj.Name, "katarina_skin07_w_indicator_ally") or  string.find(obj.Name, "katarina_skin08_w_indicator_ally") or string.find(obj.Name, "Katarina_Skin09_W_Indicator_Ally") or string.find(obj.Name, "katarina_skin10_w_indicator_ally") then
        self.Dagger[obj.NetworkId] = nil
        self.dgr = self.dgr - 1
        end 
    end
end 

function DanceKat:OnProcessSpell(unit, spell)
    if unit.IsMe and spell.Name:lower():find("KatarinaR") then
        self.Active = true
		self.RCastTime = GetTimeGame()		
	end
end


function DanceKat:OnUpdateBuff(unit, buff)
    if unit.IsMe and buff.Name == "KatarinaR" then
        self.Active = true
        self.RCastTime = GetTimeGame()
        SetLuaMoveOnly(true)
        SetLuaBasicAttackOnly(true)
    end
end

function DanceKat:OnRemoveBuff(unit, buff)
	if unit.IsMe and buff.Name == "KatarinaR" then
        self.Active = false 
        self.RCastTime = 0
        SetLuaMoveOnly(false)
        SetLuaBasicAttackOnly(false)
    end
end

function DanceKat:DisableEOW()
	_G.Orbwalker:AllowAttack(false)
	_G.Orbwalker:AllowMovement(false)
end

function DanceKat:EnableEOW()
	_G.Orbwalker:AllowMovement(true)
	_G.Orbwalker:AllowAttack(true)
end


function DanceKat:OnDraw()
    if self.DQWER then return end

    if self.Q:IsReady() and self.DQ then 
        local posQ = Vector(myHero)
        DrawCircleGame(posQ.x , posQ.y, posQ.z, self.Q.Range, Lua_ARGB(255,255,255,255))
    end
    
    if self.W:IsReady() and self.DW then 
        local posQ = Vector(myHero)
        DrawCircleGame(posQ.x , posQ.y, posQ.z, self.W.Range, Lua_ARGB(255,255,255,255))
    end

    if self.E:IsReady() and self.DE then 
        local posE = Vector(myHero)
        DrawCircleGame(posE.x , posE.y, posE.z, self.E.Range, Lua_ARGB(255,255,255,255))
	end
    if self.R:IsReady() and self.DR then 
        local posR = Vector(myHero)
        DrawCircleGame(posR.x , posR.y, posR.z, self.R.Range, Lua_ARGB(255,255,255,255))
    end 

    if self.DaggerDraw then
        for i, teste in pairs(self.Dagger) do
            if teste.IsValid and not IsDead(teste.Addr) then
            local pos = Vector(teste.x, teste.y, teste.z)
            DrawCircleGame(pos.x, pos.y, pos.z, 350, Lua_ARGB(255, 255, 0, 0))

            local x, y, z = pos.x, pos.y, pos.z
			local p1X, p1Y = WorldToScreen(x, y, z)
	        local p2X, p2Y = WorldToScreen(myHero.x, myHero.y, myHero.z)
	        DrawLineD3DX(p1X, p1Y, p2X, p2Y, 2, Lua_ARGB(255, 255, 0, 0))
            end 
        end 
    end 
end 



function DanceKat:ComboKat()
    for i ,enemys in pairs(self:GetEnemies()) do
        local enemys = GetTargetSelector(2000)
        target = GetAIHero(enemys)
        if target ~= 0 then
        local Distance = GetDistanceSqr(target)
        if self.CQ and self.CW and self.CE and Distance <= self.W.Range * self.W.Range and not self.Active == true then
            self:CastW(target)
			self:CastQ(target)
            self:GetECast(target)
        end 
        if self.CQ and self.CW and self.CE and Distance <= self.Q.Range * self.Q.Range and not self.Active == true then
            self:CastQ(target)
            self:GetECast(target)
        end 
        if self.CQ and self.CW and self.CE and Distance <= self.E.Range * self.E.Range and not self.Active == true then
            self:GetECast(target)
			self:CastW(target)
            self:CastQ(target)
        end
        if self.CR then
            self:CastR(target)
        end
        end 
    end 
end 

function DanceKat:CastQ(unit)
	if IsValidTarget(unit) and isReady(_Q) and GetDistanceSqr(unit) < self.Q.Range * self.Q.Range then
		CastSpellTarget(unit.Addr, _Q)
	end
end

function DanceKat:CastW(unit)
	if isReady(_W) and not self.Active and GetDistanceSqr(unit) < self.W.Range/2 * self.W.Range/2 then
		CastSpellTarget(unit.Addr, _W)
	end
end

function DanceKat:CastR(unit)
    if isReady(_R) and GetDistanceSqr(unit) < self.R.Range * self.R.Range and unit.HP/unit.MaxHP*100 < 35 then
		CastSpellTarget(unit.Addr, _R)
	end 
end 


function DanceKat:CastETarget(unit)
	if IsValidTarget(unit) and isReady(_E) and GetDistanceSqr(unit) < self.E.Range * self.E.Range then
        local CPX, CPZ, UPX, UPZ, hc, AOETarget = GetPredictionCore(unit.Addr, 0, self.E.delay, self.E.width, self.E.Range, self.E.speed, myHero.x, myHero.z, false, false, 10, 5, 5, 5, 5, 5)
		    if hc >= 5 then
            CastSpellToPos(CPX,CPZ, _E)
		end
	end
end

function DanceKat:CastEDagger(unit)
    if IsValidTarget(unit) then
		for _, Daga in pairs(self.Dagger) do
			local spot = Vector(Daga) + (Vector(unit) - Vector(Daga)):Normalized() * 145
			if isReady(_E) and not self.Active == true and GetDistanceSqr(unit, spot) < self.W.Range * self.W.Range then
            CastSpellToPos(spot.x, spot.z, _E)
            end 
		end
	end
end

function DanceKat:GetECast(unit)
	if self.EonlyD and not self.Active then
		self:CastEDagger(unit)
	else
		if self.dgr > 0 then
			self:CastEDagger(unit)
		else
			self:CastETarget(unit)
		end
	end
end

function DanceKat:CheckR()
	local found = false
		if self.Active == true then
            for K, target in pairs(self:GetEnemies()) do
                Enemy = GetAIHero(target)
				if IsValidTarget(Enemy, self.R.Range) then
					found = true
				end
			end
		end
	if found == false and self.Active then
		self:EnableEOW()
		self.Active = false
	end
end

--[[function DanceKat:GapClose()
    for i,enm in pairs(self:GetEnemies()) do
        if enm ~= nil and isReady(_W) then
            local hero = GetAIHero(enm)
            local TargetDashing, CanHitDashing, DashPosition = IsDashing(hero, self.W.delay, self.W.width, self.W.speed, myHero, false)
            if DashPosition ~= nil and GetDistance(DashPosition) <= self.W.Range+ 200 then
                CastSpellTarget(DashPosition.Addr, _W)
            end
        end
    end
end]]

function DanceKat:CastKillSteal()
    for i ,enemys in pairs(self:GetEnemies()) do
        local enemys = GetTargetSelector(1000)
        target = GetAIHero(enemys)
        if target ~= 0 then
            if self.CQ and isReady(_Q) then
				if target ~= nil and target.IsValid and self.Q:GetDamage(target) > target.HP then
					self:CastQ(target)
				end
			end
			-- R
			--[[if self.KR and isReady(_R) then
				if target ~= nil and target.IsValid and self.R:GetDamage(target) > target.HP then
					self:CastR(target)
				end
			end]]
			--E
			if self.KE and isReady(_E) then
				if target ~= nil and target.IsValid and self.E:GetDamage(target) > target.HP then
					self:CastETarget(target)
				end
			end
			-- E on Dagger
			if self.KE and isReady(_E) then
				if self.dgr > 0 then
					for _, D in pairs(self.Dagger) do
						if target ~= nil and target.IsValid and self.E:GetDamage(target) > target.HP then
						if GetDistanceSqr(target, D) < 250 * 250 then
                        self:CastEDagger(target)
                        end 
                    end 
					end
				end
			end
		end
	end
end 

function DanceKat:Flee()
    local mousePos = Vector(GetMousePos())
    MoveToPos(GetMousePosX(), GetMousePosZ())
	if self.FleeW then
		isReady(_W)
	end
	if GetDistance(mousePos) > self.E.Range then
            unit =  Vector(myHero) + (Vector(unit) - Vector(myHero)):Normalized() * self.E.Range
        else
            unit = Vector(myHero) + (Vector(unit) - Vector(myHero))
        end

        if isReady(_E) then
        	UnitValid = false
           	UnitDistance = 9999
               for i ,m in pairs(self:AlyyMinionsTbl()) do
				if GetDistance(m, unit) < 350 and not IsDead(m.Addr) and UnitDistance > GetDistance(mousePos, m) then
                    UnitDistance = GetDistance(mousePos, m)
                    UnitValid = m
                end
			end
			for i ,m in pairs(self:EnemyMinionsTbl()) do
				if GetDistance(m, unit) < 350 and not IsDead(m.Addr) and UnitDistance > GetDistance(mousePos, m) then
                    UnitDistance = GetDistance(mousePos, m)
                    UnitValid = m
                end
			end
			for _, D in pairs(self.Dagger) do
				if GetDistance(D, unit) < 350 and UnitDistance > GetDistance(mousePos, D) then
                    UnitDistance = GetDistance(mousePos, D)
                    UnitValid = D
                end
			end
		end
		if UnitValid then
            unit = UnitValid
        end
        if GetDistance(mousePos) > self.E.Range then
            if UnitValid then
            CastSpellToPos(UnitValid.x, UnitValid.z, _E)
            end
        elseif GetDistance(mousePos) < self.E.Range then
            if UnitValid then
            CastSpellToPos(UnitValid.x, UnitValid.z, _E)
        end
	end
end 

function DanceKat:OnTick()
    if (IsDead(myHero.Addr) or myHero.IsRecall or IsTyping() or IsDodging()) or not IsRiotOnTop() then return end

    --self:ChancelR()
    self:CheckR()
    self:CastKillSteal()

    if myHero.HasBuff("katarinarsound") then
        self:DisableEOW(myHero)
    else
        self:EnableEOW(myHero)
    end 

    if GetKeyPress(self.Combo) > 0 then	
        self:ComboKat()
        self:CastR()
    end
    if GetKeyPress(self.LaneClear) > 0 then	
        self:LaneQE()
    end
    if GetKeyPress(self.Last_Hit) > 0 then	
        self:LastQE()
    end
    if GetKeyPress(self.Flee_Kat) > 0 then	
        self:Flee()
    end
end 

function DanceKat:LastQE()
    for i ,minion in pairs(self:EnemyMinionsTbl()) do
        if minion ~= 0 then
            if self.LQ then 
                self:CastQ(minion) 
             end
        end 
    end
end  

function DanceKat:LaneQE()
    for i ,minion in pairs(self:EnemyMinionsTbl()) do
    if minion ~= 0 then
    if self.LQ then 
        self:CastQ(minion) 
    end
    for _, D in pairs(self.Dagger) do
        if self.dgr > 0 then
            if not self:IsUnderTurretEnemy(D) then
                self:GetECast(minion)
            end
            if self.LW then
                self:CastW(minion) 
            end
            end
        end
    end
end
end 

function DanceKat:IsUnderTurretEnemy(pos)
	GetAllObjectAroundAnObject(myHero.Addr, 2000)
	local objects = pObject
	for k,v in pairs(objects) do
		if IsTurret(v) and not IsDead(v) and IsEnemy(v) and GetTargetableToTeam(v) == 4 then
			local turretPos = Vector(GetPosX(v), GetPosY(v), GetPosZ(v))
			if GetDistanceSqr(turretPos,pos) < (915+475)*(915+475) then
				return true
			end
		end
	end
	return false
end

function DanceKat:EnemyMinionsTbl() --SDK Toir+
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

function DanceKat:AlyyMinionsTbl() --SDK Toir+
    GetAllUnitAroundAnObject(myHero.Addr, 2000)
    local result = {}
    for i, obj in pairs(pUnit) do
        if obj ~= 0  then
            local minions = GetUnit(obj)
            if IsAlly(minions.Addr) and not IsDead(minions.Addr) and not IsInFog(minions.Addr) and GetType(minions.Addr) == 1 then
                table.insert(result, minions)
            end
        end
    end
    return result
end

function isReady(slot)
    return CanCast(slot)
end

function isLevel(slot)
	if GetSpellNameByIndex(slot).Level > 0 then
    	return true
  	else
    	return false
  	end
end

function Level(slot)
	if isLevel(slot) then
		return GetSpellNameByIndex(slot).Level
	end
end




    
