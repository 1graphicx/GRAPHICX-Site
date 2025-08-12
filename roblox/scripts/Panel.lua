-- Charger la bibliothèque Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Créer la fenêtre principale de Rayfield
local Window = Rayfield:CreateWindow({
	Name = "Hyrax's Executor",
	LoadingTitle = "Executor en cours...",
	LoadingSubtitle = "By Hyrax",
	ConfigurationSaving = {
		Enabled = false,
		FolderName = nil,
		FileName = "Example Hub"
	},
	Discord = {
		Enabled = false,
		Invite = " ",
		RememberJoins = true
	},
	KeySystem = false,
	KeySettings = {
		Title = "Key",
		Subtitle = "Key System",
		Note = "Key In Discord Server",
		FileName = "YoutubeHubKey1",
		SaveKey = false,
		GrabKeyFromSite = true,
		Key = {"1234Hyrax"}
	}
})

-------------------------------------------------------------------------- Main

-- Créer un onglet et une section dans la fenêtre
local MainTab = Window:CreateTab("Main", nil)
local MainSection = MainTab:CreateSection("Main")

------------------------------------- No Clip

-- Variables pour No Clip
local noclipEnabled = false
local NoclipConnection = nil

-- Fonction pour activer le noclip
local function noclip()
	noclipEnabled = true
	local function Nocl()
		if noclipEnabled and game.Players.LocalPlayer.Character then
			for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
				if part:IsA('BasePart') and part.CanCollide then
					part.CanCollide = false
				end
			end
		end
	end
	NoclipConnection = game:GetService('RunService').Stepped:Connect(Nocl)
end

-- Fonction pour désactiver le noclip
local function clip()
	if NoclipConnection then
		NoclipConnection:Disconnect()
	end
	noclipEnabled = false
	local character = game.Players.LocalPlayer.Character
	if character then
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA('BasePart') then
				part.CanCollide = true
			end
		end
	end
end

-- Toggle pour No Clip
local noclipToggle = MainTab:CreateToggle({
	Name = "Noclip",
	Description = "Active ou désactive le mode noclip",
	CurrentValue = false,
	Flag = "noclipToggle", -- Identifiant unique pour ce toggle
	Callback = function(state)
		if state then
			noclip()
		else
			clip()
		end
	end
})

------------------------------------- Click TP

-- Variables pour la téléportation
local teleportEnabled = false
local preTeleportOrientation = nil  -- Pour stocker l'orientation avant la téléportation

-- Fonction pour activer/désactiver la téléportation
local function toggleTeleport(state)
    teleportEnabled = state
end

-- Fonction pour gérer la téléportation
local function teleportToMouse()
    local UIS = game:GetService("UserInputService")
    local Player = game.Players.LocalPlayer
    local Mouse = Player:GetMouse()

    UIS.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and UIS:IsKeyDown(Enum.KeyCode.LeftControl) and teleportEnabled then
            local targetPosition = Mouse.Hit.Position
            local character = Player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                -- Conserver l'orientation actuelle du joueur
                preTeleportOrientation = character.HumanoidRootPart.CFrame - character.HumanoidRootPart.Position

                -- Déplacer le joueur à la position ciblée tout en conservant l'orientation
                character.HumanoidRootPart.CFrame = CFrame.new(targetPosition) * preTeleportOrientation
            end
        end
    end)
end

-- Initialiser la fonction de téléportation
teleportToMouse()

-- Toggle pour Click TP
local clickTpToggle = MainTab:CreateToggle({
    Name = "Teleportation Ctrl + Click",
    Description = "Active ou désactive la téléportation avec Ctrl + clic gauche",
    CurrentValue = false,
    Flag = "clickTpToggle", -- Identifiant unique pour ce toggle
    Callback = function(state)
        toggleTeleport(state)
    end
})



------------------------------------- Supprimer des blocs


-- Variable pour gérer la connexion de l'événement de clic
local deleteBlocksConnection

-- Toggle pour supprimer les blocs
local DeleteBlocksToggle = MainTab:CreateToggle({
	Name = "Delete Blocks Ctrl + Click",
	CurrentValue = false,
	Flag = "Toggle2",
	Callback = function(State)
		local Plr = game:GetService("Players").LocalPlayer
		local Mouse = Plr:GetMouse()
		local UserInputService = game:GetService("UserInputService")

		-- Déconnecter la connexion existante si elle existe
		if deleteBlocksConnection then
			deleteBlocksConnection:Disconnect()
		end

		-- Connexion pour détecter les clics de souris
		deleteBlocksConnection = Mouse.Button1Down:Connect(function()
			if State and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				local target = Mouse.Target
				if target and target:IsA("BasePart") then
					-- Debugging
					print("Bloc ciblé pour suppression :", target.Name)
					-- Supprimer le bloc
					target:Destroy()
				else
					print("Aucun bloc cible détecté ou le bloc cible n'est pas un BasePart")
				end
			end
		end)
	end,
})

------------------------------------- God Walk

-- Variables pour gérer le verrouillage de la position Y avec un sol invisible
local lockYEnabled = false
local lockedYPosition = nil
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Créer le "sol invisible" sous le joueur
local invisibleFloor = Instance.new("Part")
invisibleFloor.Size = Vector3.new(10, 1, 10) -- Largeur du sol
invisibleFloor.Transparency = 1 -- Rendre le sol invisible
invisibleFloor.Anchored = true
invisibleFloor.CanCollide = true
invisibleFloor.Parent = workspace

-- Variables pour détecter si une touche est maintenue enfoncée
local isSpaceHeld = false
local isCtrlHeld = false

-- Créer un toggle pour activer/désactiver le sol invisible
MainTab:CreateToggle({
    Name = "God Walk",
    Description = "Permet au joueur de marcher dans le vide.",
    CurrentValue = false,
    Flag = "toggleWalkInAir",
    Callback = function(state)
        lockYEnabled = state  -- Mise à jour de l'état de verrouillage de la position Y
        
        if lockYEnabled then
            -- Calculer la position de verrouillage Y pour que le socle soit juste sous les pieds
            lockedYPosition = humanoidRootPart.Position.Y - (humanoid.HipHeight + humanoidRootPart.Size.Y / 2 + 0.5)
            invisibleFloor.Position = Vector3.new(humanoidRootPart.Position.X, lockedYPosition, humanoidRootPart.Position.Z)
            humanoid.JumpPower = 0  -- Désactiver le saut
            
            -- Met à jour la position du sol invisible pour suivre le joueur
            game:GetService("RunService").Heartbeat:Connect(function()
                if lockYEnabled then
                    invisibleFloor.Position = Vector3.new(humanoidRootPart.Position.X, lockedYPosition, humanoidRootPart.Position.Z)
                end
            end)
            
            print("Air walk enabled.")
        else
            -- Si désactivé, rend le sol invisible inutilisable
            invisibleFloor.Position = Vector3.new(0, -1000, 0) -- Cache le sol loin du joueur
            humanoid.JumpPower = 50  -- Réactiver le saut
            print("Air walk disabled.")
        end
    end
})

-- Réinitialiser le personnage et le sol invisible si le joueur respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    if lockYEnabled then
        -- Replacer le sol invisible sous le nouveau personnage
        wait(1)  -- Donne un petit délai pour éviter les erreurs
        lockedYPosition = humanoidRootPart.Position.Y - (humanoid.HipHeight + humanoidRootPart.Size.Y / 2 + 0.5)
        invisibleFloor.Position = Vector3.new(humanoidRootPart.Position.X, lockedYPosition, humanoidRootPart.Position.Z)
        humanoid.JumpPower = 0  -- Désactiver le saut
    end
end)

-- Gestion des touches pour monter et descendre le socle en continu
local UserInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end  -- Ne pas traiter si le joueur est dans une interface de chat ou autre

    if lockYEnabled then
        -- Détecter si Espace est maintenu pour monter le socle
        if input.KeyCode == Enum.KeyCode.Space then
            isSpaceHeld = true
        -- Détecter si Ctrl est maintenu pour descendre le socle
        elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
            isCtrlHeld = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        isSpaceHeld = false
    elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        isCtrlHeld = false
    end
end)

-- Met à jour la position du socle pendant que les touches sont maintenues
runService.Heartbeat:Connect(function()
    if lockYEnabled then
        if isSpaceHeld then
            lockedYPosition = lockedYPosition + 0.5  -- Incrémenter pour monter progressivement
        elseif isCtrlHeld then
            lockedYPosition = lockedYPosition - 0.5  -- Décrémenter pour descendre progressivement
        end
        invisibleFloor.Position = Vector3.new(humanoidRootPart.Position.X, lockedYPosition, humanoidRootPart.Position.Z)
    end
end)

------------------------------------- Infinite Jump

local Button = MainTab:CreateToggle({
	Name = "Infinite Jump",
	Callback = function()
		--Toggles the infinite jump between on or off on every script run
		_G.infinjump = not _G.infinjump

		if _G.infinJumpStarted == nil then
			--Ensures this only runs once to save resources
			_G.infinJumpStarted = true

			--The actual infinite jump
			local plr = game:GetService('Players').LocalPlayer
			local m = plr:GetMouse()
			m.KeyDown:connect(function(k)
				if _G.infinjump then
					if k:byte() == 32 then
						humanoid = game:GetService'Players'.LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
						humanoid:ChangeState('Jumping')
						wait()
						humanoid:ChangeState('Seated')
					end
				end
			end)
		end
	end,
})

------------------------------------- Fly


-- Variables pour Fly
local flyEnabled = false
local flySpeed = 50
local flyConnections = {}
local isLanding = false

-- Fonction pour activer le vol
local function startFlying()
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local torso = character:FindFirstChild("HumanoidRootPart")

	if not torso then return end

	-- Création du BodyGyro pour stabiliser le personnage
	local flyBG = Instance.new("BodyGyro", torso)
	flyBG.P = 9e4
	flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	flyBG.CFrame = torso.CFrame

	-- Création du BodyVelocity pour le mouvement
	local flyBV = Instance.new("BodyVelocity", torso)
	flyBV.Velocity = Vector3.new(0, 0.1, 0)
	flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)

	local flyCtrl = {f = 0, b = 0, l = 0, r = 0}

	local function fly()
		while flyEnabled do
			wait(0.1)
			local camera = game.Workspace.CurrentCamera
			if flyCtrl.l + flyCtrl.r ~= 0 or flyCtrl.f + flyCtrl.b ~= 0 then
				flyBV.Velocity = ((camera.CFrame.LookVector * (flyCtrl.f + flyCtrl.b)) + ((camera.CFrame * CFrame.new(flyCtrl.l + flyCtrl.r, (flyCtrl.f + flyCtrl.b) * .2, 0).p) - camera.CFrame.p)) * flySpeed
			else
				flyBV.Velocity = Vector3.new(0, 0.1, 0)
			end
			if not isLanding then
				-- Permet de tourner librement en vol
				flyBG.CFrame = CFrame.new(torso.Position, torso.Position + camera.CFrame.LookVector)
			end
		end

		-- Préparation pour l'atterrissage
		if flyEnabled == false then
			flyBG:Destroy()
			flyBV:Destroy()
			-- Assurer que le personnage tombe au sol en réactivant la gravité
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.PlatformStand = false
				-- Attendre que le personnage touche le sol
				while torso.Velocity.Y > 0 do
					wait(0.5)
				end
			end
		end
	end

	local function onInputChanged(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.W then
			flyCtrl.f = 1
		elseif input.KeyCode == Enum.KeyCode.S then
			flyCtrl.b = -1
		elseif input.KeyCode == Enum.KeyCode.A then
			flyCtrl.l = -1
		elseif input.KeyCode == Enum.KeyCode.D then
			flyCtrl.r = 1
		end
	end

	local function onInputEnded(input)
		if input.KeyCode == Enum.KeyCode.W then
			flyCtrl.f = 0
		elseif input.KeyCode == Enum.KeyCode.S then
			flyCtrl.b = 0
		elseif input.KeyCode == Enum.KeyCode.A then
			flyCtrl.l = 0
		elseif input.KeyCode == Enum.KeyCode.D then
			flyCtrl.r = 0
		end
	end

	table.insert(flyConnections, game:GetService("UserInputService").InputBegan:Connect(onInputChanged))
	table.insert(flyConnections, game:GetService("UserInputService").InputEnded:Connect(onInputEnded))

	flyEnabled = true
	fly()
end

-- Fonction pour désactiver le vol
local function stopFlying()
	if flyEnabled then
		flyEnabled = false
		for _, conn in ipairs(flyConnections) do
			conn:Disconnect()
		end
		flyConnections = {}
	end
end

-- Création du Slider pour ajuster la vitesse du vol
local flySpeedSlider = MainTab:CreateSlider({
	Name = "Fly Speed",
	Range = {0, 1000},
	Increment = 1,
	Suffix = "Speed",
	CurrentValue = 0,
	Flag = "flySpeedSlider", -- Identifiant unique pour ce slider
	Callback = function(Value)
		flySpeed = Value
		if Value > 0 then
			if not flyEnabled then
				startFlying()
			end
		else
			stopFlying()
		end
	end,
})

------------------------------------- Speed

-- Sauvegarder la valeur de la vitesse par défaut du serveur
local player = game.Players.LocalPlayer
local defaultServerWalkSpeed = player.Character.Humanoid.WalkSpeed

-- Variable pour stocker la vitesse choisie par le joueur via le slider
local savedWalkSpeed = defaultServerWalkSpeed -- Initialiser à la vitesse par défaut du serveur

-- Variable pour contrôler l'actualisation de la vitesse
local isUpdatingSpeed = false

-- Créer le slider pour la vitesse de marche
local Slider = MainTab:CreateSlider({
    Name = "Walk Speed",
    Range = {0, 350},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 0, -- Mettre la valeur par défaut à 0 pour le slider
    Flag = "sliderws", -- Identifiant unique pour ce slider
    Callback = function(Value)
        if Value == 0 then
            -- Lorsque le slider est à 0, remettre la vitesse par défaut du serveur
            savedWalkSpeed = defaultServerWalkSpeed
        else
            -- Définir la nouvelle valeur de la vitesse de marche
            savedWalkSpeed = Value
        end
        -- Appliquer la vitesse uniquement si elle est différente de la vitesse actuelle
        if not isUpdatingSpeed and player.Character.Humanoid.WalkSpeed ~= savedWalkSpeed then
            isUpdatingSpeed = true
            player.Character.Humanoid.WalkSpeed = savedWalkSpeed
            isUpdatingSpeed = false
        end
    end,
})

-- Fonction pour appliquer la vitesse de marche après la mort et surveiller les modifications
local function onCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = savedWalkSpeed -- Appliquer la vitesse sauvegardée au respawn

    -- Surveiller et corriger les modifications de WalkSpeed
    humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        -- Appliquer la vitesse uniquement si elle est différente de la vitesse actuelle
        if not isUpdatingSpeed and humanoid.WalkSpeed ~= savedWalkSpeed then
            isUpdatingSpeed = true
            humanoid.WalkSpeed = savedWalkSpeed
            isUpdatingSpeed = false
        end
    end)
end

-- Connecter la fonction au changement de personnage
player.CharacterAdded:Connect(onCharacterAdded)

-- Vérifier si le personnage est déjà présent au moment du script
if player.Character then
    onCharacterAdded(player.Character)
end

------------------------------------- Jump

-- Sauvegarder la valeur initiale de la puissance de saut
local player = game.Players.LocalPlayer
local initialJumpPower = player.Character.Humanoid.JumpPower

-- Créer une table pour stocker la puissance de saut
local savedJumpPower = initialJumpPower -- Initialiser à la puissance de saut initiale du joueur

-- Créer le slider pour la puissance de saut
local JumpPowerSlider = MainTab:CreateSlider({
    Name = "Jump Power",
    Range = {0, 500},
    Increment = 1,
    Suffix = "Power",
    CurrentValue = 0, -- Mettre la valeur par défaut à 0 pour le slider
    Flag = "sliderjp", -- Identifiant unique pour ce slider
    Callback = function(Value)
        if Value == 0 then
            -- Lorsque le slider est à 0, on conserve la puissance de saut initiale
            player.Character.Humanoid.JumpPower = initialJumpPower -- Maintenir la puissance de saut initiale
        else
            -- Définir la nouvelle valeur de la puissance de saut
            savedJumpPower = Value
            player.Character.Humanoid.JumpPower = Value
        end
    end,
})

-- Fonction pour appliquer la puissance de saut après la mort
local function onCharacterAdded(character)
    -- Appliquer la puissance de saut sauvegardée lorsque le personnage respawn
    character:WaitForChild("Humanoid").JumpPower = savedJumpPower
end

-- Connecter la fonction au changement de personnage
player.CharacterAdded:Connect(onCharacterAdded)

-- Vérifier si le personnage est déjà présent au moment du script
if player.Character then
    onCharacterAdded(player.Character)
end



-------------------------------------------------------------------------- Infos

-- Créer un onglet et une section dans la fenêtre
local InfoTab = Window:CreateTab("Infos", nil)
local InfoSection = InfoTab:CreateSection("Infos")

------------------------------------- Dex

-- Variable pour suivre l'état du bouton (activé/désactivé)
local dexEnabled = false

-- Fonction pour ouvrir le script Dex depuis le lien GitHub
local function openDexScript()
    pcall(function()
        -- Charger le script Dex depuis le lien GitHub
        local dexScriptSource = game:HttpGet("https://raw.githubusercontent.com/scriptrobloxxx/Dex/main/DexScript")
        local dexScriptFunction = loadstring(dexScriptSource)
        
        -- Exécuter le script Dex
        if dexScriptFunction then
            dexScriptFunction()
        end
    end)
end

-- Fonction pour gérer l'affichage du GUI Dex
local function handleDexGUI(player, enable)
    local playerGui = player:WaitForChild("PlayerGui")
    local dexGui = playerGui:FindFirstChild("Dex")
    
    if enable then
        -- Si le GUI Dex n'existe pas encore, on le crée
        if not dexGui then
            local dexClone = Instance.new("ScreenGui")
            dexClone.Name = "Dex"
            dexClone.Parent = playerGui
        end
        
        -- Rendre le GUI visible
        dexGui.Enabled = true
    else
        -- Supprimer le GUI Dex seulement si le bouton est désactivé
        if dexGui then
            dexGui:Destroy()
        end
    end
end

-- Fonction pour réactiver le Dex et le GUI lors du respawn
local function resetDexAfterRespawn(player)
    player.CharacterAdded:Connect(function(character)
        -- Attendre que le PlayerGui soit chargé après le respawn
        local playerGui = player:WaitForChild("PlayerGui")
        
        -- Charger à nouveau le script Dex lors du respawn si le bouton est activé
        if dexEnabled then
            openDexScript()
            -- S'assurer que le GUI Dex est affiché si le bouton est activé
            handleDexGUI(player, true)
        end
    end)
end

-- Assurez-vous que le script Dex et le GUI soient réactivés lors du respawn, uniquement si le bouton est activé
resetDexAfterRespawn(game.Players.LocalPlayer)

-- Bouton pour ouvrir/fermer le script Dex
local dexButton = InfoTab:CreateToggle({
    Name = "Dex Explorer",
    Callback = function(isEnabled)
        -- Met à jour l'état du bouton
        dexEnabled = isEnabled
        
        if isEnabled then
            openDexScript()
            -- Activer le GUI Dex
            handleDexGUI(game.Players.LocalPlayer, true)
        else
            -- Désactiver le GUI Dex
            handleDexGUI(game.Players.LocalPlayer, false)
        end
    end
})



-------------------------------------

-- Fonction pour créer les éléments d'affichage
local function createUI()
	local function createTextLabel(parent, position, text)
		local textLabel = Instance.new("TextLabel")
		textLabel.Parent = parent
		textLabel.Size = UDim2.new(0, 500, 0, 50)
		textLabel.Position = position
		textLabel.BackgroundTransparency = 1
		textLabel.BorderSizePixel = 0
		textLabel.TextColor3 = Color3.new(1, 1, 1)
		textLabel.TextSize = 14
		textLabel.TextStrokeTransparency = 0.5
		textLabel.Text = text
		return textLabel
	end

	local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	-- Utilisation de CoreGui pour s'afficher au-dessus de tout
	local coreGui = game:GetService("CoreGui")
	local screenGui = Instance.new("ScreenGui", coreGui)  -- Changer PlayerGui à CoreGui
	return {
		pathLabel = createTextLabel(screenGui, UDim2.new(0.5, -250, 0, 10), ""),
		blockPositionLabel = createTextLabel(screenGui, UDim2.new(0.5, -250, 0, 70), ""),
		positionLabel = createTextLabel(screenGui, UDim2.new(0.5, -250, 0, 130), ""),
		bodyAngleLabel = createTextLabel(screenGui, UDim2.new(0.5, -250, 0, 190), ""),
		angleLabel = createTextLabel(screenGui, UDim2.new(0.5, -250, 0, 250), ""),
		guiPathLabel = createTextLabel(screenGui, UDim2.new(0.5, -250, 0, 310), "")
	}
end

-- Fonction pour filtrer "Ugc." du chemin
local function filterUgcPath(path)
	-- Enlever "Ugc." de tous les chemins
	return path:gsub("Ugc%.", "")
end

-- Initialisation UI et Variables d'affichage
local ui, showPath, showPosition, showAngle, showBodyAngle, showBlockPosition, showGuiPath = createUI(), false, false, false, false, false, false

-- Fonction pour mettre à jour les labels
local function updateLabels()
	local player = game.Players.LocalPlayer
	local camera = game.Workspace.CurrentCamera
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")

	while true do
		wait(0.01)
		if showPath then
			local mouse = player:GetMouse()
			local target = mouse.Target
			ui.pathLabel.Text = target and target:IsA("BasePart") and "Chemin du bloc visé : " .. filterUgcPath(table.concat((function()
				local path, current = {}, target
				while current do
					table.insert(path, 1, current.Name)
					current = current.Parent
				end
				return path
			end)(), ".")) or "Aucun bloc visé ou le bloc n'est pas une BasePart"
		end
		if showBlockPosition then
			local mouse = player:GetMouse()
			local target = mouse.Target
			ui.blockPositionLabel.Text = target and target:IsA("BasePart") and string.format("Position du bloc visé : X: %.2f, Y: %.2f, Z: %.2f", target.Position.X, target.Position.Y, target.Position.Z) or "Aucun bloc visé ou le bloc n'est pas une BasePart"
		end
		if showPosition then
			local position = hrp.Position
			ui.positionLabel.Text = string.format("Position actuelle : X: %.2f, Y: %.2f, Z: %.2f", position.X, position.Y, position.Z)
		end
		if showBodyAngle then
			local bodyOrientation = hrp.CFrame - hrp.Position
			local angle = math.deg(math.atan2(bodyOrientation.LookVector.X, bodyOrientation.LookVector.Z))
			ui.bodyAngleLabel.Text = string.format("Angle du corps : %.2f°", angle)
		end
		if showAngle then
			local viewDirection = camera.CFrame.LookVector
			local playerDirection = (camera.CFrame.Position - hrp.Position).unit
			ui.angleLabel.Text = string.format("Angle de vue : %.2f°", math.deg(math.acos(viewDirection:Dot(playerDirection))))
		end
		if showGuiPath then
			local mouse = player:GetMouse()
			local guiElementUnderMouse = nil
			for _, element in ipairs(player.PlayerGui:GetDescendants()) do
				if element:IsA("GuiObject") and element.Visible then
					local elementPosition = element.AbsolutePosition
					local elementSize = element.AbsoluteSize
					local mouseLocation = mouse.Hit.p
					if mouseLocation.X >= elementPosition.X and mouseLocation.X <= elementPosition.X + elementSize.X and
					   mouseLocation.Y >= elementPosition.Y and mouseLocation.Y <= elementPosition.Y + elementSize.Y then
						guiElementUnderMouse = element
						break
					end
				end
			end
			if guiElementUnderMouse then
				local path = {}
				local current = guiElementUnderMouse
				while current do
					table.insert(path, 1, current.Name)
					current = current.Parent
				end
				ui.guiPathLabel.Text = "Chemin du GUI visé : " .. filterUgcPath(table.concat(path, "."))
			else
				ui.guiPathLabel.Text = "Aucun élément GUI visé."
			end
		end
	end
end

-- Fonction pour gérer les événements de réapparition
local function onCharacterAdded(character)
	ui = createUI()
	spawn(updateLabels)
end

game.Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
if game.Players.LocalPlayer.Character then onCharacterAdded(game.Players.LocalPlayer.Character) end

-- Fonctions de Toggle
local function createToggle(name, description, flag, callback)
	return InfoTab:CreateToggle({ Name = name, Description = description, CurrentValue = false, Flag = flag, Callback = callback })
end

createToggle("Afficher le chemin du bloc", "Affiche le chemin du bloc visé dans le TextLabel", "pathToggle", function(state) showPath = state ui.pathLabel.Visible = state end)
createToggle("Afficher la position du bloc visé", "Affiche la position actuelle du bloc visé dans le TextLabel", "blockPositionToggle", function(state) showBlockPosition = state ui.blockPositionLabel.Visible = state end)
createToggle("Afficher la position du joueur", "Affiche la position actuelle du joueur dans le TextLabel", "positionToggle", function(state) showPosition = state ui.positionLabel.Visible = state end)
createToggle("Afficher l'angle du corps", "Affiche l'angle du corps du joueur en degrés dans le TextLabel", "bodyAngleToggle", function(state) showBodyAngle = state ui.bodyAngleLabel.Visible = state end)
createToggle("Afficher l'angle de vue", "Affiche l'angle de vue du joueur en degrés dans le TextLabel", "angleToggle", function(state) showAngle = state ui.angleLabel.Visible = state end)
createToggle("Afficher le chemin du GUI", "Affiche le chemin du GUI visé dans le TextLabel", "guiPathToggle", function(state) showGuiPath = state ui.guiPathLabel.Visible = state end)

-- Fonctions de copie avec debounce
local function copyToClipboard(text, title)
	setclipboard(text)
	game.StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 5 })
end

local debounce = { path = false, position = false, angle = false, bodyAngle = false, blockPosition = false, guiPath = false }
local function copyPathToClipboard()
	if debounce.path then return end
	debounce.path = true
	local target = game.Players.LocalPlayer:GetMouse().Target
	if target and target:IsA("BasePart") then
		local path = table.concat((function()
			local path, current = {}, target
			while current do
				table.insert(path, 1, current.Name)
				current = current.Parent
			end
			return path
		end)(), ".")
		copyToClipboard(filterUgcPath(path), "Chemin du bloc copié")
	end
	wait(1)
	debounce.path = false
end

local function copyGuiPathToClipboard()
	if debounce.guiPath then return end
	debounce.guiPath = true
	local mouse = game.Players.LocalPlayer:GetMouse()
	local guiElementUnderMouse = nil
	for _, element in ipairs(game.Players.LocalPlayer.PlayerGui:GetDescendants()) do
		if element:IsA("GuiObject") and element.Visible then
			local elementPosition = element.AbsolutePosition
			local elementSize = element.AbsoluteSize
			local mouseLocation = mouse.Hit.p
			if mouseLocation.X >= elementPosition.X and mouseLocation.X <= elementPosition.X + elementSize.X and
			   mouseLocation.Y >= elementPosition.Y and mouseLocation.Y <= elementPosition.Y + elementSize.Y then
				guiElementUnderMouse = element
				break
			end
		end
	end
	if guiElementUnderMouse then
		local path = {}
		local current = guiElementUnderMouse
		while current do
			table.insert(path, 1, current.Name)
			current = current.Parent
		end
		copyToClipboard(filterUgcPath(table.concat(path, ".")), "Chemin du GUI copié")
	else
		copyToClipboard("Aucun élément GUI visé.", "Erreur de copie GUI")
	end
	wait(1)
	debounce.guiPath = false
end

-- Écouter les entrées clavier
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then return end
	if input.KeyCode == Enum.KeyCode.KeypadOne and showPath then copyPathToClipboard()
	elseif input.KeyCode == Enum.KeyCode.KeypadTwo and showBlockPosition then copyBlockPositionToClipboard()
	elseif input.KeyCode == Enum.KeyCode.KeypadThree then copyPositionToClipboard()
	elseif input.KeyCode == Enum.KeyCode.KeypadFour and showBodyAngle then copyBodyAngleToClipboard()
	elseif input.KeyCode == Enum.KeyCode.KeypadFive and showAngle then copyAngleToClipboard()
	elseif input.KeyCode == Enum.KeyCode.KeypadSix and showGuiPath then copyGuiPathToClipboard()
	end
end)


-------------------------------------------------------------------------- Fun

-- Créer l'onglet et la section "Fun"
local FunTab = Window:CreateTab("Fun", nil)
local FunSection = FunTab:CreateSection("Fun")

--[[ Dependencies ]]--

local ca = game:GetService("ContextActionService")
local zeezy = game:GetService("Players").LocalPlayer
local h = 0.0174533
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

--[[ Variables ]]--

local isAnimating = false
local isBackflipEnabled = false
local isFrontflipEnabled = false

--[[ Fonction d'Affichage de Notification ]]--

local function notify(message)
	StarterGui:SetCore("SendNotification", {
		Title = "Notification",
		Text = message,
		Duration = 3 -- Durée de la notification en secondes
	})
end

--[[ Fonction de Backflip ]]--

local function zeezyBackflip()
	if not isAnimating then
		isAnimating = true
		zeezy.Character.Humanoid:ChangeState("Jumping")
		wait()
		zeezy.Character.Humanoid.Sit = true
		for i = 1, 360 do
			delay(i / 720, function()
				zeezy.Character.Humanoid.Sit = true
				zeezy.Character.HumanoidRootPart.CFrame = zeezy.Character.HumanoidRootPart.CFrame * CFrame.Angles(h, 0, 0)
			end)
		end
		wait(0.55)
		zeezy.Character.Humanoid.Sit = false
		isAnimating = false
	end
end

--[[ Fonction de Frontflip ]]--

local function zeezyFrontflip()
	if not isAnimating then
		isAnimating = true
		zeezy.Character.Humanoid:ChangeState("Jumping")
		wait()
		zeezy.Character.Humanoid.Sit = true
		for i = 1, 360 do
			delay(i / 720, function()
				zeezy.Character.Humanoid.Sit = true
				zeezy.Character.HumanoidRootPart.CFrame = zeezy.Character.HumanoidRootPart.CFrame * CFrame.Angles(-h, 0, 0)
			end)
		end
		wait(0.55)
		zeezy.Character.Humanoid.Sit = false
		isAnimating = false
	end
end

--[[ Création du Toggle pour Backflip ]]--

local backflipButton = FunTab:CreateToggle({
	Name = "Backflip",  -- Nom du bouton
	Description = "Active ou désactive le mode backflip",  -- Description affichée
	CurrentValue = false,
	Flag = "backflipButton",  -- Identifiant unique pour ce bouton
	Callback = function(state)
		isBackflipEnabled = state
		if state then
			notify("Backflip activé. Appuyez sur '*' du pavé numérique pour effectuer un backflip.")
		end
	end
})

--[[ Création du Toggle pour Frontflip ]]--

local frontflipButton = FunTab:CreateToggle({
	Name = "Frontflip",  -- Nom du bouton
	Description = "Active ou désactive le mode frontflip",  -- Description affichée
	CurrentValue = false,
	Flag = "frontflipButton",  -- Identifiant unique pour ce bouton
	Callback = function(state)
		isFrontflipEnabled = state
		if state then
			notify("Frontflip activé. Appuyez sur '-' du pavé numérique pour effectuer un frontflip.")
		end
	end
})

--[[ Fonction d'Écoute des Touches du Clavier ]]--

local function onInputBegan(input, gameProcessed)
	if gameProcessed then return end

	if isBackflipEnabled and input.KeyCode == Enum.KeyCode.KeypadMultiply then
		zeezyBackflip()
	elseif isFrontflipEnabled and input.KeyCode == Enum.KeyCode.KeypadMinus then
		zeezyFrontflip()
	end
end

UserInputService.InputBegan:Connect(onInputBegan)

-------------------------------------------------------------------------- Telekinesie

-- Variable pour suivre l'état du Toggle
local telekinesisEnabled = false
local loading = false  -- Indicateur de chargement

-- Fonction pour exécuter le script de télékinésie
local function executeTelekinesisScript()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptrobloxxx/Telekinesis/refs/heads/main/Telekinesis"))()
    end)
end

-- Fonction pour désactiver le script de télékinésie
local function disableTelekinesis()
    local player = game.Players.LocalPlayer

    -- Cherche dans le sac à dos
    local telekinesisTool = player.Backpack:FindFirstChild("Telekinesis")

    -- Cherche dans le personnage si non trouvé dans le sac à dos
    if not telekinesisTool then
        telekinesisTool = player.Character:FindFirstChild("Telekinesis")
    end

    -- Si l'outil de télékinésie est trouvé, le supprimer
    if telekinesisTool then
        telekinesisTool:Destroy()  -- Supprimer l'outil de télékinésie
    end
end

-- Fonction pour restaurer l'outil de télékinésie après le respawn du joueur
local function restoreTelekinesisOnRespawn()
    local player = game.Players.LocalPlayer

    -- Lorsqu'un personnage du joueur est ajouté (ou réapparaît après la mort)
    player.CharacterAdded:Connect(function(character)
        -- Attendre que le personnage et le Humanoid soient prêts
        local humanoid = character:WaitForChild("Humanoid")

        -- Vérifier si l'outil de télékinésie est dans l'inventaire
        local telekinesisTool = player.Backpack:FindFirstChild("Telekinesis")
        
        -- Si l'outil de télékinésie n'est pas trouvé dans l'inventaire, on le rétablit
        if not telekinesisTool and telekinesisEnabled and not loading then
            loading = true
            executeTelekinesisScript()  -- Réexécuter le script pour restaurer l'objet
            wait(2)  -- Attendre un peu pour le chargement
            loading = false
        end
    end)
end

-- Bouton Toggle pour activer/désactiver le script de télékinésie
local telekinesisToggle = FunTab:CreateToggle({
    Name = "Telekinesis",
    Default = false,
    Callback = function(state)
        if state and not loading then
            loading = true  -- Indiquer que le chargement a commencé
            telekinesisEnabled = true
            executeTelekinesisScript()
            wait(2)  -- Délai d'attente pour le chargement (ajustez si nécessaire)
            loading = false  -- Réinitialiser l'état de chargement
        elseif not state and not loading then
            telekinesisEnabled = false
            disableTelekinesis()
        else
            -- Si l'on essaie de désactiver pendant le chargement, informer l'utilisateur
            Rayfield:Notify({
                Title = "Chargement en cours",
                Content = "Veuillez attendre que le script se charge avant de le désactiver.",
                Duration = 5
            })
        end
    end
})

-- Appeler la fonction pour restaurer l'objet de télékinésie après le respawn du joueur
restoreTelekinesisOnRespawn()

--------------------------------------------- Ender Perle

-- Variables globales
local teleportationPearlTool = nil  -- Outil de perle de téléportation
local teleportationActive = false   -- État du toggle pour la perle de téléportation
local activeTeleportationPearl = nil  -- La sphère de téléportation actuellement active
local teleportationTriggered = false  -- Drapeau pour éviter les téléportations multiples
local preTeleportOrientation = nil    -- Pour stocker l'orientation avant la téléportation

-- Fonction pour créer une perle de téléportation
local function createTeleportationObject()
    local teleportationObject = Instance.new("Tool")
    teleportationObject.Name = "EnderPearl"
    teleportationObject.RequiresHandle = true
    teleportationObject.CanBeDropped = false

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1, 1)
    handle.BrickColor = BrickColor.new("Bright blue")
    handle.Material = Enum.Material.Neon
    handle.Shape = Enum.PartType.Ball  -- Définir la forme comme une sphère
    handle.Anchored = false
    handle.CanCollide = false
    handle.Parent = teleportationObject

    return teleportationObject
end

-- Fonction pour supprimer toutes les perles de téléportation existantes
local function removeExistingTeleportationPearls()
    local player = game.Players.LocalPlayer
    local backpack = player.Backpack

    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") and item.Name == "EnderPearl" then
            item:Destroy()
        end
    end
end

-- Fonction pour lancer la sphère et téléporter le joueur
local function throwTeleportationPearl()
    if not teleportationActive then
        return  -- Ne rien faire si la perle de téléportation n'est pas activée
    end

    if activeTeleportationPearl then
        -- Si une perle est déjà en cours, la détruire
        activeTeleportationPearl:Destroy()
    end

    if teleportationTriggered then
        return  -- Empêcher le lancement d'une nouvelle perle si une téléportation est déjà en cours
    end

    local player = game.Players.LocalPlayer
    local mouse = player:GetMouse()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local humanoidRootPart = character.HumanoidRootPart
    local targetPosition = mouse.Hit.Position
    local direction = (targetPosition - humanoidRootPart.Position).unit
    local throwForce = 500  -- Ajustez la force du lancer si nécessaire
    local offsetY = 15  -- Décalage vertical pour apparaître 15 unités au-dessus de la sphère

    -- Conserver l'orientation actuelle du joueur
    preTeleportOrientation = humanoidRootPart.CFrame - humanoidRootPart.Position

    -- Créer et configurer la sphère de téléportation
    local teleportSphere = Instance.new("Part")
    teleportSphere.Name = "TeleportSphere"
    teleportSphere.Size = Vector3.new(1, 1, 1)
    teleportSphere.BrickColor = BrickColor.new("Bright blue")
    teleportSphere.Material = Enum.Material.Neon
    teleportSphere.Shape = Enum.PartType.Ball  -- Définir la forme comme une sphère
    teleportSphere.Anchored = false
    teleportSphere.CanCollide = true
    teleportSphere.CFrame = humanoidRootPart.CFrame
    teleportSphere.Parent = workspace

    -- Ajouter un BodyVelocity pour lancer la sphère
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = direction * throwForce
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = teleportSphere

    -- Ajouter un BodyGyro pour stabiliser la sphère en vol
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.CFrame = teleportSphere.CFrame
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 3000
    bodyGyro.Parent = teleportSphere

    -- Définir la sphère active
    activeTeleportationPearl = teleportSphere

    -- Fonction pour gérer l'impact de la sphère
    local function onTouch(hit)
        if hit:IsA("BasePart") and not hit:IsDescendantOf(character) then
            if not teleportationTriggered then
                teleportationTriggered = true  -- Activer le drapeau de téléportation

                -- Obtenir la position de l'impact
                local touchPosition = teleportSphere.Position

                -- Calculer la nouvelle position du joueur (au-dessus de la sphère)
                local newPosition = CFrame.new(touchPosition + Vector3.new(0, offsetY, 0))

                -- Téléporter le joueur
                character:SetPrimaryPartCFrame(newPosition * preTeleportOrientation)

                -- Assurer que le joueur est bien orienté droit
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    -- Réinitialiser la vitesse et la rotation pour éviter les mouvements imprévus
                    humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                    humanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)

                    -- Temporarily disable gravity to prevent falling
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.PlatformStand = true  -- Disable platform physics
                    end

                    -- Attendre un court instant pour que le joueur soit aligné
                    wait(0.1)

                    -- Réactiver la gravité et permettre le mouvement normal
                    if humanoid then
                        humanoid.PlatformStand = false  -- Re-enable platform physics
                    end
                end

                -- Détruire la sphère après la téléportation
                teleportSphere:Destroy()

                -- Réinitialiser la variable de la sphère active
                activeTeleportationPearl = nil

                -- Réinitialiser le drapeau de téléportation
                teleportationTriggered = false
            end
        end
    end

    teleportSphere.Touched:Connect(onTouch)
end

-- Fonction pour activer ou désactiver la perle de téléportation
local function toggleTeleportation()
    local player = game.Players.LocalPlayer
    local backpack = player.Backpack

    if teleportationActive then
        -- Désactiver la perle de téléportation
        if teleportationPearlTool then
            teleportationPearlTool:Destroy()  -- Retirer l'objet de l'inventaire
            teleportationPearlTool = nil
        end
        teleportationActive = false
    else
        -- Supprimer les anciennes perles de téléportation
        removeExistingTeleportationPearls()

        -- Activer la perle de téléportation
        if not teleportationPearlTool then
            teleportationPearlTool = createTeleportationObject()
            teleportationPearlTool.Parent = backpack
            teleportationPearlTool.Activated:Connect(throwTeleportationPearl)
        end
        teleportationActive = true
    end
end

-- Fonction pour maintenir l'objet dans l'inventaire après la mort
local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        if teleportationActive and not player.Backpack:FindFirstChild("EnderPearl") then
            teleportationPearlTool = createTeleportationObject()
            teleportationPearlTool.Parent = player.Backpack
            teleportationPearlTool.Activated:Connect(throwTeleportationPearl)
        end
    end)
end

-- Connecter la fonction onPlayerAdded aux joueurs existants
for _, player in ipairs(game.Players:GetPlayers()) do
    onPlayerAdded(player)
end

-- Connecter la fonction onPlayerAdded aux nouveaux joueurs
game.Players.PlayerAdded:Connect(onPlayerAdded)

-- Création du bouton pour activer/désactiver la perle de téléportation
local teleportPearlToggle = FunTab:CreateToggle({
    Name = "Ender Pearl",
    Description = "Ender Perle.",
    Callback = function()
        toggleTeleportation()
    end
})


--------------------------------------------- Magnet

local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local MagnetToggle = FunTab:CreateToggle({
    Name = "Magnet",
    Description = "Magnet.",
    Callback = function()
        toggleMagnet()
    end
})

local isMagnetEnabled = false
local targetPlayer = nil
local cowerAnimationId = "http://www.roblox.com/asset/?id=4940563117"
local currentAnimation = nil
local animationCheckCoroutine = nil
local oscillationSpeed = 40 -- Vitesse du va-et-vient
local tweenDuration = 0.1 -- Durée d'interpolation plus rapide pour plus de réactivité
local originalSitAnimationId = nil -- Stocker l'animation originale pour la restaurer
local seatedConnection = nil -- Stocker la connexion de l'événement "Seated"

-- Fonction pour désactiver la possibilité de s'asseoir
local function disableSitAnimation()
    local character = game.Players.LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Désactiver l'animation "sit"
            local animateScript = character:FindFirstChild("Animate")
            if animateScript and animateScript:FindFirstChild("sit") then
                local sitAnimation = animateScript.sit:FindFirstChild("SitAnim")
                if sitAnimation then
                    -- Sauvegarder l'animation originale
                    if not originalSitAnimationId then
                        originalSitAnimationId = sitAnimation.AnimationId
                    end
                    -- Remplacer par une animation vide
                    sitAnimation.AnimationId = ""
                end
            end

            -- Empêcher le joueur de rester assis
            if seatedConnection then
                seatedConnection:Disconnect()
            end
            seatedConnection = humanoid.Seated:Connect(function(active)
                if active then
                    -- Forcer le joueur à se relever
                    humanoid.Jump = true
                end
            end)
        end
    end
end

-- Fonction pour restaurer la possibilité de s'asseoir
local function restoreSitAnimation()
    local character = game.Players.LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Restaurer l'animation "sit"
            local animateScript = character:FindFirstChild("Animate")
            if animateScript and animateScript:FindFirstChild("sit") then
                local sitAnimation = animateScript.sit:FindFirstChild("SitAnim")
                if sitAnimation and originalSitAnimationId then
                    sitAnimation.AnimationId = originalSitAnimationId
                end
            end

            -- Déconnecter l'événement "Seated"
            if seatedConnection then
                seatedConnection:Disconnect()
                seatedConnection = nil
            end
        end
    end
end

-- Fonction pour jouer l'animation "Cower"
local function playCowerAnimation()
    if targetPlayer and isMagnetEnabled then
        local character = game.Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local animation = Instance.new("Animation")
                animation.AnimationId = cowerAnimationId

                if currentAnimation then
                    currentAnimation:Stop()
                end

                currentAnimation = humanoid:LoadAnimation(animation)
                currentAnimation:Play()
            end
        end
    end
end

-- Fonction pour arrêter l'animation "Cower"
local function stopCowerAnimation()
    if currentAnimation then
        currentAnimation:Stop()
        currentAnimation = nil
    end
end

-- Fonction pour vérifier périodiquement que l'animation "Cower" est jouée
local function startAnimationCheck()
    animationCheckCoroutine = coroutine.create(function()
        while isMagnetEnabled and targetPlayer do
            wait(0.1)
            local character = game.Players.LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and (not currentAnimation or not currentAnimation.IsPlaying) then
                    playCowerAnimation()
                end
            end
        end
    end)
    coroutine.resume(animationCheckCoroutine)
end

-- Fonction pour arrêter la vérification de l'animation
local function stopAnimationCheck()
    if animationCheckCoroutine then
        coroutine.close(animationCheckCoroutine)
        animationCheckCoroutine = nil
    end
end

-- Fonction pour activer ou désactiver le "Magnet"
function toggleMagnet()
    isMagnetEnabled = not isMagnetEnabled
    if isMagnetEnabled then
        StarterGui:SetCore("SendNotification", {
            Title = "Magnet Activé",
            Text = "Le script est prêt à être utilisé, cliquez sur un joueur !",
            Icon = "rbxassetid://123456789",
            Duration = 5
        })
        disableSitAnimation()  -- Empêcher de s'asseoir

        if targetPlayer then
            playCowerAnimation()
            startAnimationCheck()
        end
    else
        StarterGui:SetCore("SendNotification", {
            Title = "Magnet Désactivé",
            Text = "Le script est désactivé. Vous pouvez maintenant vous asseoir.",
            Icon = "rbxassetid://123456789",
            Duration = 5
        })
        restoreSitAnimation()  -- Restaurer la capacité de s'asseoir
        stopCowerAnimation()
        stopAnimationCheck()
        targetPlayer = nil
    end
end

-- Fonction pour détecter un clic sur un joueur
function onPlayerClick()
    local mouse = game.Players.LocalPlayer:GetMouse()
    local target = mouse.Target

    -- Vérification pour s'assurer que le joueur est bien cliqué, même s'il porte un chapeau ou un cosmétique
    if target and target.Parent and target.Parent:FindFirstChild("Humanoid") then
        local clickedPlayer = game.Players:GetPlayerFromCharacter(target.Parent)
        if clickedPlayer then
            if targetPlayer == clickedPlayer then
                -- Désactive la cible si on reclique dessus
                targetPlayer = nil
                stopCowerAnimation()
            else
                -- Change la cible
                targetPlayer = clickedPlayer
                if isMagnetEnabled then
                    playCowerAnimation()
                    startAnimationCheck()
                end
            end
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then
        onPlayerClick()
    elseif input.KeyCode == Enum.KeyCode.LeftControl then
        -- Si Ctrl est appuyé, arrête de suivre la cible
        if isMagnetEnabled then
            stopCowerAnimation()
            targetPlayer = nil
            print("Magnet arrêté à cause de la touche Ctrl")
        end
    end
end)

-- Fonction de gestion du respawn pour rejouer l'animation après la mort si nécessaire
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    -- Cette fonction sera appelée chaque fois qu'un joueur respawn

    -- Assurez-vous que l'animation n'est pas jouée avant que le respawn soit complet
    character:WaitForChild("HumanoidRootPart")  -- Attendre la fin de la création du personnage
    wait(0.1)  -- Attendre un peu pour éviter un déclenchement trop rapide

    -- Vérifier si l'animation doit être jouée à ce moment
    if isMagnetEnabled and targetPlayer then
        -- Rejouer l'animation après le respawn
        playCowerAnimation()
        startAnimationCheck()
    end

    -- Gérer la mort et l'arrêt de l'animation à la mort
    character:WaitForChild("Humanoid").Died:Connect(function()
        if isMagnetEnabled and targetPlayer then
            stopCowerAnimation()  -- Arrêter l'animation à la mort
        end
    end)
end)

-- Déplacement du joueur vers la cible avec va-et-vient fluide
game:GetService("RunService").Heartbeat:Connect(function()
    if isMagnetEnabled and targetPlayer then
        local playerToMagnet = game.Players.LocalPlayer
        local playerCharacter = playerToMagnet.Character
        if playerCharacter then
            local playerHRP = playerCharacter:FindFirstChild("HumanoidRootPart")
            local targetHRP = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if playerHRP and targetHRP then
                local backwardDirection = -targetHRP.CFrame.LookVector

                -- Position pour le va-et-vient derrière la cible
                local targetPosition1 = targetHRP.Position + backwardDirection * 0.1
                local targetPosition2 = targetHRP.Position + backwardDirection * 4

                -- Choisir la position X et Z pour le va-et-vient
                local moveToPosition = (math.sin(tick() * oscillationSpeed) > 0) and targetPosition1 or targetPosition2

                -- Synchronisation stricte de la position Y
                moveToPosition = Vector3.new(moveToPosition.X, targetHRP.Position.Y, moveToPosition.Z)

                local tweenInfo = TweenInfo.new(tweenDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                local newCFrame = CFrame.new(moveToPosition, targetHRP.Position)
                local tween = TweenService:Create(playerHRP, tweenInfo, {CFrame = newCFrame})
                tween:Play()
            end
        end
    end
end)

game.Players.PlayerRemoving:Connect(function(player)
    if targetPlayer == player then
        targetPlayer = nil
        stopCowerAnimation()
    end
end)


------------------------------------- Magnet Inversé

-- Variables pour Magnet inversé
local MagnetSettingsInverse = {
    CanMagnet = false,
    Target = nil
}

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local SleepAnimation
local UserInputService = game:GetService("UserInputService")

-- Fonction pour vérifier si une animation est en cours
function PlayingAnimation(Anim)
    for _, Animation in Humanoid:GetPlayingAnimationTracks() do
        if Animation.Name == Anim.Name then
            return true
        end
    end
    return false
end

-- Magnet (Fun) [Inverse]
function MagnetLoopInverse()
    local previousPosition = Character.PrimaryPart.Position  -- Position initiale du personnage
    local oscillationAmplitude = 2  -- Amplitude de l'oscillation (réglable)
    local oscillationSpeed = 20  -- Vitesse de l'oscillation (réglable)
    local maxDistanceFromTarget = 4  -- Limite de distance maximale avant la cible pour éviter l'intersection
    local HeightOffset = 2  -- Décalage de hauteur par rapport à la tête de la cible

    while true do
        if MagnetSettingsInverse.CanMagnet and MagnetSettingsInverse.Target then
            local CharacterFound = workspace:FindFirstChild(MagnetSettingsInverse.Target)
            if CharacterFound and CharacterFound:FindFirstChild("Head") and CharacterFound.PrimaryPart then
                -- Récupérer la position de la tête
                local HeadPosition = CharacterFound.Head.Position
                local TargetHeight = HeadPosition.Y - CharacterFound.PrimaryPart.Position.Y

                -- Calculer la distance entre le personnage et la tête de la cible
                local directionToTarget = (HeadPosition - Character.PrimaryPart.Position).unit
                local distanceToTarget = (HeadPosition - Character.PrimaryPart.Position).magnitude

                -- Ajustement dynamique basé sur la hauteur de la tête
                local DefaultCF = CharacterFound.PrimaryPart.CFrame * CFrame.new(0, TargetHeight + HeightOffset, -2)  -- Déplacer devant la tête avec ajustement de hauteur

                -- Calculer l'oscillation en fonction du temps mais limiter la distance maximale
                local oscillation = math.sin(tick() * oscillationSpeed) * oscillationAmplitude
                local limitedOscillation = math.clamp(oscillation, -maxDistanceFromTarget, maxDistanceFromTarget)

                -- Nouvelle position avec une oscillation limitée et devant la tête de la cible
                local MagnetCF = CFrame.new(directionToTarget * limitedOscillation)  -- Appliquer l'oscillation en fonction de la direction
                local LookOpposite = CFrame.Angles(0, math.rad(180), 0)  -- Rotation inversée de 180 degrés

                -- Appliquer les transformations
                Character:SetPrimaryPartCFrame(DefaultCF * MagnetCF * LookOpposite)

                -- Jouer l'animation Sleep
                if not SleepAnimation or not PlayingAnimation(SleepAnimation) then
                    local Animation = Instance.new("Animation")
                    Animation.AnimationId = "rbxassetid://10714360343" -- ID de l'animation "Sleep"
                    SleepAnimation = Humanoid:LoadAnimation(Animation)
                    SleepAnimation:Play()
                end
            else
                -- Si la cible est perdue ou introuvable, arrêtez l'animation
                if SleepAnimation then
                    SleepAnimation:Stop()
                    SleepAnimation = nil
                end
                MagnetSettingsInverse.Target = nil
            end
        else
            -- Si le magnétisme est désactivé, arrêtez l'animation
            if SleepAnimation then
                SleepAnimation:Stop()
                SleepAnimation = nil
            end
        end
        task.wait(0.03) -- Temps de pause pour un déplacement fluide
    end
end

-- Lancer la boucle pour le magnétisme inversé
spawn(MagnetLoopInverse)

-- Création du bouton "Magnet Inversé"
FunTab:CreateToggle({
    Name = "Magnet Inversé",
    Callback = function(Value)
        MagnetSettingsInverse.CanMagnet = Value
        if not Value then
            MagnetSettingsInverse.Target = nil
        end
    end
})

-- Activer ou désactiver le magnétisme via clic souris
local Mouse = game.Players.LocalPlayer:GetMouse()

-- Variable pour savoir si Ctrl est enfoncé
local isCtrlPressed = false

-- Quand Ctrl est appuyé, suspendre temporairement le magnétisme
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end  -- Ignore les entrées traitées par d'autres systèmes

    -- Vérifier si la touche Ctrl est enfoncée
    if input.UserInputType == Enum.UserInputType.Keyboard and 
       (input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl) then
        -- Suspendre le magnétisme sur la cible actuelle lorsque Ctrl est pressé
        if MagnetSettingsInverse.CanMagnet then
            if MagnetSettingsInverse.Target then
                MagnetSettingsInverse.CanMagnet = false  -- Arrêter le magnétisme sur le joueur ciblé
                if SleepAnimation then
                    SleepAnimation:Stop()  -- Arrêter l'animation si nécessaire
                    SleepAnimation = nil
                end
            end
        end
    end
end)

-- Quand Ctrl est relâché, permettre de réactiver le magnétisme via un clic
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and
       (input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl) then
        -- Après avoir relâché Ctrl, tu peux cliquer sur un joueur pour réactiver le magnétisme
    end
end)

-- Clic sur un joueur pour activer ou réactiver le magnétisme
Mouse.Button1Down:Connect(function()
    -- Si Ctrl est appuyé, ignorer le clic
    if isCtrlPressed then return end

    -- Si le magnétisme est désactivé après avoir appuyé sur Ctrl, réactiver le magnétisme avec un clic
    if not MagnetSettingsInverse.CanMagnet then
        local MouseTarget = Mouse.Target
        if MouseTarget and MouseTarget.Parent:FindFirstChild("Humanoid") then
            local CharacterFound = MouseTarget.Parent

            -- Vérifier si un nouveau joueur est sélectionné
            if CharacterFound.Name ~= MagnetSettingsInverse.Target then
                MagnetSettingsInverse.Target = CharacterFound.Name
                MagnetSettingsInverse.CanMagnet = true  -- Reprendre le magnétisme sur ce joueur
            else
                MagnetSettingsInverse.Target = nil  -- Si le même joueur est cliqué, désactiver le magnétisme
            end
        end
    end
end)



------------------------------------- Emotes

------------------------------------------------------------------
local FunSection = FunTab:CreateSection("Emotes")
------------------------------------------------------------------

-- Définir les données d'émotes (remplace ceci par ton JSON statique si nécessaire)
local emoteData = {
    { id = 13694139364, animationid = "http://www.roblox.com/asset/?id=13694096724", name = "Man City Scorpion Kick (Slowmotion)" },
    { id = 14353423348, animationid = "http://www.roblox.com/asset/?id=14352343065", name = "BabyQueen-BouncyTwirl" },
    { id = 14353421343, animationid = "http://www.roblox.com/asset/?id=14352340648", name = "BabyQueen-FaceFrame" },
    { id = 16553249658, animationid = "http://www.roblox.com/asset/?id=16553163212", name = "MaeStephens-PianoHands" },
    { id = 15610015346, animationid = "http://www.roblox.com/asset/?id=15609995579", name = "YungbludHappierJump" },
    { id = 3360689775, animationid = "http://www.roblox.com/asset/?id=10714389988", name = "Salute" },
    { id = 17746270218, animationid = "http://www.roblox.com/asset/?id=17746180844", name = "SturdyDance-IceSpice" },
    { id = 5915779043, animationid = "http://www.roblox.com/asset/?id=10713966026", name = "Applaud" },
    { id = 14353425085, animationid = "http://www.roblox.com/asset/?id=14352362059", name = "BabyQueen-Strut" },
    { id = 3360692915, animationid = "http://www.roblox.com/asset/?id=10714338461", name = "Tilt" },
    { id = 14548709888, animationid = "http://www.roblox.com/asset/?id=14548619594", name = "BLACKPINKPinkVenom-GetemGetemGetem" },
    { id = 3823158750, animationid = "http://www.roblox.com/asset/?id=10714347256", name = "Godlike" },
    { id = 15698511500, animationid = "http://www.roblox.com/asset/?id=15698404340", name = "Cuco-Levitate" },
    { id = 12507097350, animationid = "http://www.roblox.com/asset/?id=12507085924", name = "AloYogaPose-LotusPosition" },
    { id = 15694504637, animationid = "http://www.roblox.com/asset/?id=15693621070", name = "d4vd-Backflip" },
    { id = 15679955281, animationid = "http://www.roblox.com/asset/?id=15679621440", name = "FestiveDance" },
    { id = 16572756230, animationid = "http://www.roblox.com/asset/?id=16572740012", name = "HIPMOTION-Amaarae" },
    { id = 10214418283, animationid = "http://www.roblox.com/asset/?id=10214319518", name = "VPose-TommyHilfiger" },
    { id = 14900153406, animationid = "http://www.roblox.com/asset/?id=14899980745", name = "TWICEFeelSpecial" },
    { id = 4689362868, animationid = "http://www.roblox.com/asset/?id=10714360343", name = "Sleep" },
    { id = 7466046574, animationid = "http://www.roblox.com/asset/?id=10714390497", name = "QuietWaves" },
    { id = 4646306583, animationid = "http://www.roblox.com/asset/?id=10714061912", name = "Curtsy" },
    { id = 5104377791, animationid = "http://www.roblox.com/asset/?id=10714360164", name = "HeroLanding" },
    { id = 5917570207, animationid = "http://www.roblox.com/asset/?id=10714340543", name = "FlossDance" },
    { id = 3716636630, animationid = "http://www.roblox.com/asset/?id=10714388352", name = "Monkey" },
    { id = 15554010118, animationid = "http://www.roblox.com/asset/?id=15517864808", name = "OliviaRodrigoHeadBop" },
    { id = 14548711723, animationid = "http://www.roblox.com/asset/?id=14548621256", name = "BLACKPINKPinkVenom-StraighttoYaDome" },
    { id = 11309263077, animationid = "http://www.roblox.com/asset/?id=11309255148", name = "EltonJohn-HeartSkip" },
    { id = 5230661597, animationid = "http://www.roblox.com/asset/?id=10713992055", name = "Bored" },
    { id = 10214406616, animationid = "http://www.roblox.com/asset/?id=10214311282", name = "FrostyFlair-TommyHilfiger" },
    { id = 15571540519, animationid = "http://www.roblox.com/asset/?id=15571453761", name = "NickiMinajStarships" },
    { id = 15392927897, animationid = "http://www.roblox.com/asset/?id=15392759696", name = "ParisHilton-SlivingForTheGroove" },
    { id = 14900151704, animationid = "http://www.roblox.com/asset/?id=14899979575", name = "TWICELIKEY" },
    { id = 15392932768, animationid = "http://www.roblox.com/asset/?id=15392756794", name = "ParisHilton-IconicIT-Grrrl" },
    { id = 3576717965, animationid = "http://www.roblox.com/asset/?id=10714369325", name = "Shy" },
    { id = 16276506814, animationid = "http://www.roblox.com/asset/?id=16270690701", name = "SoldeJaneiro-Samba" },
    { id = 15123050663, animationid = "http://www.roblox.com/asset/?id=15122972413", name = "BoneChillin'Bop" },
    { id = 15506503658, animationid = "http://www.roblox.com/asset/?id=15505456446", name = "VictoryDance" },
    { id = 3762654854, animationid = "http://www.roblox.com/asset/?id=10714349037", name = "Greatest" },
    { id = 15571538346, animationid = "http://www.roblox.com/asset/?id=15571448688", name = "NickiMinajBoomBoomBoom" },
    { id = 4940597758, animationid = "http://www.roblox.com/asset/?id=4940563117", name = "Cower" },
    { id = 15554016057, animationid = "http://www.roblox.com/asset/?id=15549124879", name = "OliviaRodrigoFallBacktoFloat" },
    { id = 16303091119, animationid = "http://www.roblox.com/asset/?id=16302968986", name = "BeautyTouchdown" },
    { id = 4849499887, animationid = "http://www.roblox.com/asset/?id=10714352626", name = "Happy" },
    { id = 13823339506, animationid = "http://www.roblox.com/asset/?id=13823324057", name = "Tommy-Archer" },
    { id = 5938365243, animationid = "http://www.roblox.com/asset/?id=10714068222", name = "DolphinDance" },
    { id = 3934986896, animationid = "http://www.roblox.com/asset/?id=10714066964", name = "Dizzy" },
    { id = 4940602656, animationid = "http://www.roblox.com/asset/?id=10714378156", name = "JumpingWave" },
    { id = 4212496830, animationid = "http://www.roblox.com/asset/?id=10714084708", name = "Jumping" },
}

local currentAnimationTrack = nil
local currentButtonName = nil

-- Fonction pour créer les boutons
local function createEmoteButtons()
    for _, emote in ipairs(emoteData) do
        local buttonName = emote.name
        local animationId = emote.animationid

        FunTab:CreateButton({
            Name = buttonName,
            Callback = function()
                local character = game.Players.LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        -- Si une animation est en cours et qu'on appuie sur un autre bouton, arrêter l'animation actuelle
                        if currentAnimationTrack and currentButtonName ~= buttonName then
                            currentAnimationTrack:Stop()
                            currentAnimationTrack = nil
                        end

                        -- Si on appuie sur le même bouton, arrêter l'animation
                        if currentButtonName == buttonName and currentAnimationTrack then
                            currentAnimationTrack:Stop()
                            currentAnimationTrack = nil
                            currentButtonName = nil
                            return
                        end

                        -- Jouer l'animation si elle n'est pas déjà en cours
                        if not currentAnimationTrack or currentAnimationTrack.Animation.AnimationId ~= animationId then
                            local animation = Instance.new("Animation")
                            animation.AnimationId = animationId
                            currentAnimationTrack = humanoid:LoadAnimation(animation)
                            currentAnimationTrack:Play()
                            currentButtonName = buttonName

                            -- Arrêter l'animation automatiquement quand elle est terminée
                            currentAnimationTrack.Stopped:Connect(function()
                                if currentButtonName == buttonName then
                                    currentButtonName = nil
                                    currentAnimationTrack = nil
                                end
                            end)
                        end
                    end
                end
            end,
        })
    end
end

-- Appeler la fonction pour créer les boutons
createEmoteButtons()



-------------------------------------------------------------------------- Utilitaires

-- Créer un onglet et une section dans la fenêtre
local UtilTab = Window:CreateTab("Utilitaires", nil)
local UtilSection = UtilTab:CreateSection("Utilitaires")

------------------------------------- Time

-- Service Lighting pour ajuster l'heure de la journée
local Lighting = game:GetService("Lighting")

-- Stocker le temps de base du serveur au démarrage
-- Utilisez la valeur actuelle comme temps de base
local initialTimeOfDay = Lighting.TimeOfDay

-- Déconnecter l'ancien événement pour éviter les boucles infinies
local connection

-- Fonction pour définir l'heure de la journée
local function setLocalTimeOfDay(timeOfDay)
	Lighting.TimeOfDay = timeOfDay

	-- Assurer que les changements sont permanents pour cette session
	if connection then
		connection:Disconnect()
	end

	connection = Lighting:GetPropertyChangedSignal("TimeOfDay"):Connect(function()
		if Lighting.TimeOfDay ~= timeOfDay then
			Lighting.TimeOfDay = timeOfDay
		end
	end)
end

-- Convertir la valeur du slider en format heure (HH:MM:SS)
local function valueToTimeString(value)
	local hours = math.floor(value)
	local minutes = math.floor((value - hours) * 60)
	return string.format("%02d:%02d:00", hours, minutes)
end

-- Slider pour ajuster l'heure de la journée
local Slider = UtilTab:CreateSlider({
	Name = "Time Of Day",
	Range = {0, 24}, -- Plage de 0 à 24 heures
	Increment = 0.1, -- Incrément de 1 heure
	Suffix = "h", -- Suffixe pour l'affichage des heures
	CurrentValue = 0, -- Valeur initiale du slider (0 heures)
	Flag = "sliderTimeOfDay", -- Identifiant unique pour le slider
	Callback = function(Value)
		if Value < 1 then
			-- Réinitialiser au temps initial
			setLocalTimeOfDay(initialTimeOfDay)
		else
			-- Convertir la valeur du slider en chaîne horaire
			local timeString = valueToTimeString(Value)
			-- Définir l'heure de la journée
			setLocalTimeOfDay(timeString)
		end
	end,
})

-- Initialiser le slider avec la valeur par défaut
Slider:Set(0)



------------------------------------- Afficher Icon

local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Fonction pour activer le curseur libre
local function enableCursor()
    -- Définir la souris en mode libre
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    -- Réglage de la caméra en mode classique
    player.CameraMode = Enum.CameraMode.Classic
end

-- Fonction pour désactiver le curseur libre et revenir au comportement par défaut
local function disableCursor()
    -- Remet la souris dans le mode verrouillé (par défaut du jeu)
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    -- Restaure la caméra en mode normal
    player.CameraMode = Enum.CameraMode.LockFirstPerson
end

-- Gestion de l'activation/désactivation via un bouton
local showCursorToggle = UtilTab:CreateToggle({
    Name = "Afficher Curseur",
    Description = "Permet de rendre la souris visible et déplaçable.",
    CurrentValue = false,
    Flag = "showCursorToggle", -- Identifiant unique pour ce toggle
    Callback = function(state)
        if state then
            enableCursor()
        else
            disableCursor()
        end
    end,
})


------------------------------------- ESP

-- Toggle pour l'ESP
local espTpToggle = UtilTab:CreateToggle({
    Name = "Afficher ESP",
    Description = "Active ou désactive l'ESP",
    CurrentValue = false,
    Flag = "espToggle",  -- Identifiant unique pour ce toggle
    Callback = function(state)
        if state then
            -- Charger le script ESP quand le toggle est activé
            loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptrobloxxx/ESP.lua/refs/heads/main/ESP.lua"))()

            -- Activer les paramètres de l'ESP
            _G.WRDESPEnabled = true
            _G.WRDESPBox = true
            _G.WRDESPGlow = true
            _G.WRDESPNames = true
            _G.WRDESPTracers = true
            _G.WRDESPTeamColors = true

            print("ESP activé")
        else
            -- Désactiver l'ESP quand le toggle est désactivé
            _G.WRDESPEnabled = false -- Désactive l'ESP
            _G.WRDESPBox = false -- Désactive les boîtes autour des joueurs
            _G.WRDESPGlow = false -- Désactive l'effet de glow
            _G.WRDESPNames = false -- Désactive l'affichage des noms
            _G.WRDESPTracers = false -- Désactive les tracers
            _G.WRDESPTeamColors = false -- Désactive les couleurs de l'équipe

            -- Enlever les objets ESP existants
            if RemoveESP then
                RemoveESP()
            else
                print("Fonction RemoveESP non trouvée.")
            end

            print("ESP désactivé")
        end
    end
})

------------------------------------- Anti AFK

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local plr = Players.LocalPlayer

-- Variable pour stocker la connexion afin de la déconnecter
local antiAfkConnection

local afkToggle = UtilTab:CreateToggle({
    Name = "Anti AFK",
    Description = "Désactiver l'AFK",
    CurrentValue = false,
    Flag = "afkToggle",
    Callback = function(state)
        getgenv().afk_toggle = state

        -- Si activé : on empêche l'AFK
        if state then
            -- On désactive les protections AFK déjà présentes
            for _, v in next, getconnections(plr.Idled) do
                pcall(function()
                    v:Disable()
                end)
            end

            -- On connecte le simulateur d'activité
            antiAfkConnection = plr.Idled:Connect(function()
                if getgenv().afk_toggle then
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                    end)
                end
            end)

        -- Si désactivé : on réactive l'AFK normal
        else
            for _, v in next, getconnections(plr.Idled) do
                pcall(function()
                    v:Enable()
                end)
            end

            if antiAfkConnection then
                antiAfkConnection:Disconnect()
                antiAfkConnection = nil
            end
        end
    end
})

-------------------------------------------------------------------------- TP Players

-- Créer un onglet et une section dans la fenêtre
local UtilTab = Window:CreateTab("TP Players", nil)
local UtilSection = UtilTab:CreateSection("Players")

-- Table pour stocker les boutons associés aux joueurs
local playerButtons = {}

-- URL de l'icône pour les amis
local friendIcon = "URL_DE_VOTRE_ICONE"

-- Fonction pour téléporter le joueur local à un autre joueur
local function teleportToPlayer(targetPlayer)
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character
    local targetCharacter = targetPlayer.Character

    if character and targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(targetCharacter.HumanoidRootPart.CFrame)
    end
end

-- Fonction pour créer un bouton pour un joueur
local function createPlayerButton(player)
    -- Si un bouton existe déjà pour ce joueur, on ne fait rien
    if playerButtons[player.Name] then return end

    -- Obtenir le pseudonyme d'affichage et le vrai nom du joueur
    local displayName = player.DisplayName
    local userName = player.Name

    -- Vérifier si le joueur est un ami
    local isFriend = game.Players.LocalPlayer:IsFriendsWith(player.UserId)

    -- Créer un bouton avec une icône si le joueur est un ami
    local tpButton = UtilTab:CreateButton({
        Name = (isFriend and "⭐  " or "") .. displayName .. " (" .. userName .. ")",
        Icon = isFriend and friendIcon or nil, -- Ajouter une icône si c'est un ami
        Callback = function()
            teleportToPlayer(player)
        end
    })

    -- Stocker le bouton dans la table avec le nom du joueur comme clé
    playerButtons[player.Name] = tpButton
end

-- Fonction pour supprimer un bouton associé à un joueur
local function deletePlayerButton(playerName)
    local button = playerButtons[playerName]
    if button then
        button:Destroy()  -- Supprimer le bouton de l'interface
        playerButtons[playerName] = nil  -- Retirer de la table
    end
end

-- Fonction pour initialiser les boutons pour tous les joueurs actuellement présents
local function initializePlayerButtons()
    local localPlayer = game.Players.LocalPlayer
    for _, player in ipairs(game.Players:GetPlayers()) do
        -- Ne pas créer de bouton pour le joueur local
        if player ~= localPlayer then
            createPlayerButton(player)
        end
    end
end

-- Écouter l'ajout d'un nouveau joueur pour créer un bouton
game.Players.PlayerAdded:Connect(function(player)
    if player ~= game.Players.LocalPlayer then
        createPlayerButton(player)
    end
end)

-- Écouter le départ d'un joueur pour supprimer son bouton
game.Players.PlayerRemoving:Connect(function(player)
    deletePlayerButton(player.Name)
end)

-- Initialiser les boutons lors du lancement du script
initializePlayerButtons()
