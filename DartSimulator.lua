repeat task.wait() until game:IsLoaded()

--![[Global Vars | Start]]--

getgenv().autoTrain = false
getgenv().autoFarm = false
getgenv().autoRebirth = false
getgenv().autoSuperRebirth = false

getgenv().autoOpenEggs = false
getgenv().selectedEgg = nil
getgenv().addPetName = nil

getgenv().autoSpin = false
getgenv().autoGift = false
getgenv().autoCraftCharms = false
getgenv().charmsToCraft = nil
getgenv().autoMergeCharms = false

getgenv().selectedLocation = "Spawn"
getgenv().machineToOpen = nil

local workspace = game:GetService("Workspace")
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = players.LocalPlayer
local charmsInventory = localPlayer.CharmsInventory
local events = replicatedStorage.Events
local importantParts = workspace:WaitForChild("ImportantParts")
local map = workspace:WaitForChild("Map")

--![[Global Vars | End]]--

--![[Back End | Start]]--

--? Getters | Start --

local function getCurrentWorld()
    return localPlayer:WaitForChild("CurrentWorld").Value
end

local function getSpins()
    return localPlayer:WaitForChild("Spins").Value
end

local function getEggs()
    local eggs = {}
    for _, egg in ipairs(importantParts.Eggs:GetChildren()) do
        table.insert(eggs, egg.Name)
    end
    return eggs
end

local function getMaps()
    local result = {}
    for _, obj in ipairs(map.Worlds:GetChildren()) do
        for _, map in ipairs(obj:GetChildren()) do
            table.insert(result, map)
        end
    end
    return result
end

local function getNameMaps()
    local result = {}
    for _, map in ipairs(getMaps()) do
        table.insert(result, map.Name)
    end
    return result
end

local function getMap(name)
    for _, obj in ipairs(getMaps()) do
        if name == obj.Name then
            return obj
        end
    end
    return nil
end

local function getCharmsCount(name, value)
    local i = 0
    for _, obj in ipairs(charmsInventory:GetChildren()) do
        if tostring(obj.Value) == value and obj.Name == name  then
            i += 1
        end
    end
    return i
end

--? Getters | End --

--? Main | Start --

local function fAutoTrain()
    while getgenv().autoTrain do
        events.Train:FireServer("Normal")
        task.wait()
    end
end

local function fEquipVoidDart()
    events.UseDart:FireServer("Void")
end

local function fAutoFarm()
    while getgenv().autoFarm do 
        local currentWorld = getCurrentWorld()
        local winTouch = currentWorld.Win.Touch
        local hrp = localPlayer.Character.HumanoidRootPart

        firetouchinterest(hrp, winTouch, 0)
        firetouchinterest(hrp, winTouch, 1)
        task.wait(0.125)
    end
end

local function fAutoRebirth()
    while getgenv().autoRebirth do
        events.Rebirth:FireServer()
        task.wait(0.25)
    end
end

local function fAutoSuperRebirth()
    while getgenv().autoSuperRebirth do
        events.SuperRebirth:FireServer()
        fEquipVoidDart()
        task.wait(0.25)
    end
end

local function fAutoOpenEggs()
    while getgenv().autoOpenEggs do
        local eggName = getgenv().selectedEgg
        if eggName then
            events.OpenEgg:FireServer(eggName, 1, {})
        end
        task.wait(0.1)
    end
end

local function fDupePet(name)
    if name then
        events.CraftRainbowPet:FireServer(name, 5)
    end
end

local function fTeleport()
    local selectedLocation = getgenv().selectedLocation
    if selectedLocation then
        local map = getMap(selectedLocation)
        if map then
            local hrp = localPlayer.Character.HumanoidRootPart
            hrp.CFrame = map.Spawn.CFrame
        end
    end
end

local function fOpenMachine()
    local machineToOpen = getgenv().machineToOpen
    if machineToOpen then
        print(machineToOpen)
        local machineTouch = importantParts[machineToOpen].Touch
        print(machineTouch.Name)
        if machineTouch then
            local hrp = localPlayer.Character.HumanoidRootPart
            firetouchinterest(hrp, machineTouch, 0)
            firetouchinterest(hrp, machineTouch, 1)
        end
    end
end

local function fAutoCraftCharms()
    while getgenv().autoCraftCharms do
        local charmsToCraft = getgenv().charmsToCraft
        if charmsToCraft then
            events.CraftCharm:FireServer(charmsToCraft) 
        end
        task.wait(0.1)
    end
end

local function fAutoMergeCharms()
    while getgenv().autoMergeCharms do
        for _, charmToMerge in ipairs({"Power", "Luck", "WalkSpeed", "Wins"}) do
            if getCharmsCount(charmToMerge, "Common") >= 4 then
                events.MergeCharms:FireServer(charmToMerge, "Common")
            elseif getCharmsCount(charmToMerge, "Rare") >= 4 then
                events.MergeCharms:FireServer(charmToMerge, "Rare")
            elseif getCharmsCount(charmToMerge, "Legendary") >= 4 then
                events.MergeCharms:FireServer(charmToMerge, "Legendary")
            elseif getCharmsCount(charmToMerge, "Godly") >= 4 then
                events.MergeCharms:FireServer(charmToMerge, "Godly")
            end
        end
        task.wait(0.1)
    end
end

local function fAutoSpin()
    while getgenv().autoSpin do
        if getSpins() >= 1 then
            events.Spin:FireServer() 
        end
        task.wait(0.1)
    end
end

local function fAutoGift()
    while getgenv().autoGift do
        for i=1, 12 do
            events.ClaimGift:FireServer(tostring(i))
            task.wait(0.1)
        end
        task.wait(1)
    end
end

--? Main | End --

--![[Back End | End]]--

--![[Front End | Start]]--

local Atlas = loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostDuckyy/UI-Libraries/refs/heads/main/Atlas%20UI%20Library/source.lua"))()

local UI = Atlas.new({
    Name = "Dart Simulator";
    Credit = "Made By Wookie1337";
    Color = Color3.fromRGB(255,255,255);
    Bind = "LeftControl";
})

local mainPage = UI:CreatePage("main")

local mainSection = mainPage:CreateSection("Main")
local eggSection = mainPage:CreateSection("Eggs")
local charmSection = mainPage:CreateSection("Charms")
local miscSection = mainPage:CreateSection("Misc")
local uiSection = mainPage:CreateSection("UI")

-- ?Main Section | Start --

mainSection:CreateToggle({
    Name = "Auto Train";
    Flag = "autoToggle";
    Default = false;
    Callback = function(state)
        getgenv().autoTrain = state
        if state then
            task.spawn(fAutoTrain)
        end
    end;
})
mainSection:CreateToggle({
    Name = "Auto Farm";
    Flag = "autoFarm";
    Default = false;
    Callback = function(state)
        getgenv().autoFarm = state
        if state then
            task.spawn(fAutoFarm)
        end
    end;
})
mainSection:CreateToggle({
    Name = "Auto Rebirth";
    Flag = "autoRebirth";
    Default = false;
    Callback = function(state)
        getgenv().autoRebirth = state
        if state then
            task.spawn(fAutoRebirth)
        end
    end;
})
mainSection:CreateToggle({
    Name = "Auto Super Rebirth";
    Flag = "autoSuperRebirth";
    Default = false;
    Callback = function(state)
        getgenv().autoSuperRebirth = state
        if state then
            task.spawn(fAutoSuperRebirth)
        end
    end;
})

-- ?Main Section | End --

-- ?Eggs Section | Start --

eggSection:CreateToggle({
    Name = "Auto Open Eggs";
    Flag = "autoOpenEggs";
    Default = false;
    Callback = function(state)
        getgenv().autoOpenEggs = state
        if state then
            task.spawn(fAutoOpenEggs)
        end
    end;
})
eggSection:CreateDropdown({
    Name = "Selected Egg";
    Callback = function(item)
        getgenv().selectedEgg = item
    end;
    Options = getEggs();
    ItemSelecting = true;
    DefaultItemSelected = "None";
})
eggSection:CreateTextBox({
    Name = "Add Pet Name";
    Flag = "customPetName";
    Callback = function(inputtedText, enterPressed)
        getgenv().addPetName = inputtedText
    end;
})
eggSection:CreateButton({
    Name = "Add Pet";
    Callback = function()
        fDupePet(getgenv().addPetName)
    end;
})
eggSection:CreateButton({
    Name = "Give Rainbow Pet (x90)";
    Callback = function()
        fDupePet("Space Eagle")
    end;
})

-- ?Eggs Section | End --

-- ?Charm Section | Start --

charmSection:CreateToggle({
    Name = "Auto Spin";
    Flag = "autoSpin";
    Default = false;
    Callback = function(state)
        getgenv().autoSpin = state
        if state then
            task.spawn(fAutoSpin)
        end
    end;
})
charmSection:CreateToggle({
    Name = "Auto Gift";
    Flag = "autoGift";
    Default = false;
    Callback = function(state)
        getgenv().autoGift = state
        if state then
            task.spawn(fAutoGift)
        end
    end;
})
charmSection:CreateToggle({
    Name = "Auto Merge Charms";
    Flag = "autoMergeCharms";
    Default = false;
    Callback = function(state)
        getgenv().autoMergeCharms = state
        if state then
            task.spawn(fAutoMergeCharms)
        end
    end;
})
charmSection:CreateToggle({
    Name = "Auto Charm Craft";
    Flag = "autoCharmCraft";
    Default = false;
    Callback = function(state)
        getgenv().autoCraftCharms = state
        if state then
            task.spawn(fAutoCraftCharms)
        end
    end
})
charmSection:CreateDropdown({
    Name = "Charm to craft";
    Callback = function(item)
        getgenv().charmsToCraft = item
    end;
    Options = {"Power", "Luck", "WalkSpeed", "Wins"};
    ItemSelecting = true;
    DefaultItemSelected = "None";
})

-- ?Charm Section | End --

-- ?Misc Section | Start --

miscSection:CreateButton({
    Name = "Equip Void Dart";
    Callback = function()
        fEquipVoidDart()
    end;
})
miscSection:CreateButton({
    Name = "Teleport";
    Callback = function()
        fTeleport()
    end;
})
miscSection:CreateDropdown({
    Name = "Selected Location";
    Callback = function(item)
        getgenv().selectedLocation = item
    end;
    Options = getNameMaps();
    ItemSelecting = true;
    DefaultItemSelected = "Spawn";
})
miscSection:CreateButton({
    Name = "Open Machine";
    Callback = function()
        fOpenMachine()
    end;
})
miscSection:CreateDropdown({
    Name = "Choose machine to open";
    Callback = function(item)
        getgenv().machineToOpen = item
    end;
    Options = {"Gold Machine", "Rainbow Machine", "Charm Machine", "Merge Charms Machine", "Void Machine", "Super Rebirth Machine"};
    ItemSelecting = true;
    DefaultItemSelected = "None";
})

-- ?Misc Section | End  --

-- ?Ui Section | Start  --

uiSection:CreateButton({
    Name = "Destroy UI";
    Callback = function()
        getgenv().autoTrain = false
        getgenv().autoFarm = false
        getgenv().autoRebirth = false
        getgenv().autoSuperRebirth = false
        getgenv().autoOpenEggs = false
        getgenv().selectedEgg = nil
        getgenv().addPetName = nil
        getgenv().autoSpin = false
        getgenv().autoGift = false
        getgenv().autoCraftCharms = false
        getgenv().charmsToCraft = nil
        getgenv().autoMergeCharms = false
        getgenv().selectedLocation = nil
        getgenv().machineToOpen = nil
        UI:Destroy()
    end;
})

-- ?Ui Section | End  --

--![[Front End | End]]--
