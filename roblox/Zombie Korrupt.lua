-- Charger la bibliothèque Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Créer la fenêtre principale de Rayfield
local Window = Rayfield:CreateWindow({
    Name = "Zombie Korrupt",
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

------------------------------------------------------------------------ MAIN ------------------------------------------------------------------------

-- Créer un onglet et une section dans la fenêtre
local MainTab = Window:CreateTab("Main", nil)
local MainSection = MainTab:CreateSection("Main")

-- Variables pour stocker les portes, leur transparence originale et leur état de collision
local originalTransparency = {}
local originalCanCollide = {}
local isToggleActive = false
local mapFolder = game.Workspace:FindFirstChild("MapFolder")
local aimbotEnabled = false  -- Nouvelle variable pour l'état de l'aimbot


------------------------------------- Rendre les portes et les murs brisés invisibles -------------------------------------


MainTab:CreateToggle({
    Name = "Unlock Doors",
    Description = "Rendre invisible toutes les portes et murs brisés.",
    CurrentValue = false,
    Flag = "toggleDoorsAndWalls",
    Callback = function(state)
        if not mapFolder then
            print("MapFolder not found.")
            return
        end
        
        local doors = mapFolder:FindFirstChild("Doors")
        local specialDoor = game.Workspace:FindFirstChild("MapFolder")
                        and mapFolder:FindFirstChild("Map")
                        and mapFolder.Map:FindFirstChild("MapElements")
                        and mapFolder.Map.MapElements:FindFirstChild("NachtPackAPunchDoor")
                        and mapFolder.Map.MapElements.NachtPackAPunchDoor:FindFirstChild("Meshes/Door_low")
        
        local crackedWallFolder = mapFolder:FindFirstChild("Map")
                                and mapFolder.Map:FindFirstChild("MapElements")
                                and mapFolder.Map.MapElements:FindFirstChild("CrackedWall")

        if state then
            -- Rendre les portes transparentes et traversables
            if doors then
                for _, part in ipairs(doors:GetDescendants()) do
                    if part:IsA("BasePart") then
                        originalTransparency[part] = part.Transparency
                        originalCanCollide[part] = part.CanCollide
                        part.Transparency = 1
                        part.CanCollide = false
                    end
                end
            end

            -- Rendre la porte spéciale transparente
            if specialDoor and specialDoor:IsA("BasePart") then
                originalTransparency[specialDoor] = specialDoor.Transparency
                originalCanCollide[specialDoor] = specialDoor.CanCollide
                specialDoor.Transparency = 1
                specialDoor.CanCollide = false
            end

            -- Rendre les murs brisés invisibles
            if crackedWallFolder then
                for _, part in ipairs(crackedWallFolder:GetDescendants()) do
                    if part:IsA("BasePart") then
                        originalTransparency[part] = part.Transparency
                        originalCanCollide[part] = part.CanCollide
                        part.Transparency = 1
                        part.CanCollide = false
                    end
                end
                print("Cracked walls have been made invisible.")
            else
                print("CrackedWall folder not found.")
            end
            
            isToggleActive = true
            print("Doors and cracked walls have been made transparent and traversable.")
        else
            -- Restaurer les portes à leur transparence et état de collision originaux
            if doors then
                for _, part in ipairs(doors:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = originalTransparency[part] or 0
                        part.CanCollide = originalCanCollide[part] or true
                    end
                end
            end

            -- Restaurer aussi la porte spéciale
            if specialDoor and specialDoor:IsA("BasePart") then
                specialDoor.Transparency = originalTransparency[specialDoor] or 0
                specialDoor.CanCollide = originalCanCollide[specialDoor] or true
            end

            -- Restaurer les murs brisés
            if crackedWallFolder then
                for _, part in ipairs(crackedWallFolder:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = originalTransparency[part] or 0
                        part.CanCollide = true
                    end
                end
                print("Cracked walls are now visible again.")
            end

            isToggleActive = false
            print("Doors and cracked walls have been made visible and solid again.")
        end
    end
})


------------------------------------- Aimbot -------------------------------------

-- Fonction pour trouver le zombie le plus proche visible
local function getClosestZombieHead()
    local player = game.Players.LocalPlayer
    local camera = workspace.CurrentCamera
    local closestZombie = nil
    local closestDistance = math.huge  -- Commencer avec une distance infinie

    -- Parcourir tous les zombies dans le dossier
    for _, zombie in ipairs(workspace.Zombies:GetChildren()) do
        local head = zombie:FindFirstChild("Head")
        if head then
            -- Calculer la distance entre la caméra et la tête du zombie
            local distance = (camera.CFrame.Position - head.Position).magnitude

            -- Effectuer un raycast pour vérifier la visibilité
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {workspace.Zombies, player.Character}  -- Ignorer les zombies et le joueur
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist  -- Exclure les objets spécifiés

            local raycastResult = workspace:Raycast(camera.CFrame.Position, (head.Position - camera.CFrame.Position).unit * distance, raycastParams)

            -- Vérifier s'il n'y a pas d'obstacle entre la caméra et la tête du zombie
            if not raycastResult then
                -- Si le zombie est le plus proche jusqu'à présent et visible, on le sélectionne
                if distance < closestDistance then
                    closestDistance = distance
                    closestZombie = head  -- Mettre à jour le zombie le plus proche visible
                end
            end
        end
    end

    return closestZombie  -- Retourner la tête du zombie le plus proche et visible, ou nil si aucun
end

-- Créer un toggle pour activer/désactiver l'aimbot
MainTab:CreateToggle({
    Name = "Enable Aimbot",
    Description = "Activer ou désactiver l'aimbot.",
    CurrentValue = false,
    Flag = "toggleAimbot",
    Callback = function(state)
        aimbotEnabled = state  -- Met à jour l'état de l'aimbot
        if state then
            print("Aimbot is now enabled.")
        else
            print("Aimbot is now disabled.")
        end
    end
})

-- Détecter un clic droit pour exécuter le ciblage si l'aimbot est activé
local UserInputService = game:GetService("UserInputService")

local isRightMouseButtonPressed = false  -- État du clic droit

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and aimbotEnabled then  -- Vérifier si clic droit et aimbot activé
        isRightMouseButtonPressed = true  -- Met à jour l'état du clic droit
        print("Right mouse button pressed. Starting aim tracking...")

        -- Boucle pour suivre le zombie tant que le clic droit est enfoncé
        while isRightMouseButtonPressed and aimbotEnabled do
            local closestZombieHead = getClosestZombieHead()  -- Obtenir la tête du zombie le plus proche visible
            
            if closestZombieHead then
                -- Modifier la caméra pour pointer vers la tête du zombie le plus proche
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, closestZombieHead.Position)
            else
                print("No visible zombies found.")
            end
            wait(0.01)  -- Attendre un peu avant de recalculer (ajuster selon le besoin)
        end

        print("Stopped aim tracking.")
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then  -- Vérifier si le clic droit est relâché
        isRightMouseButtonPressed = false  -- Met à jour l'état du clic droit
    end
end)

-- Écouter les nouvelles apparitions de zombies
workspace.Zombies.ChildAdded:Connect(function(child)
    if aimbotEnabled and isRightMouseButtonPressed then
        print(child.Name .. " has spawned.")
        -- Vérifier et mettre à jour la cible actuelle si l'aimbot est actif
        while isRightMouseButtonPressed and aimbotEnabled do
            local closestZombieHead = getClosestZombieHead()  -- Obtenir la tête du zombie le plus proche visible
            
            if closestZombieHead then
                -- Modifier la caméra pour pointer vers la tête du zombie le plus proche
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, closestZombieHead.Position)
            end
            wait(0.01)  -- Attendre un peu avant de recalculer (ajuster selon le besoin)
        end
    end
end)


------------------------------------- Auto Farm -------------------------------------

-- Variables pour Fly et Aimbot
local flyEnabled = false
local aimbotEnabled = false
local targetZombieHead = nil  -- Tête du zombie actuellement ciblée
local originalPosition = nil   -- Pour stocker la position d'origine du joueur
local KnifeToggleActive = false -- État du toggle
local originalParts = {}       -- Pour stocker les propriétés d'origine

-- Fonction pour activer le vol
local function startFlying()
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local torso = character:FindFirstChild("HumanoidRootPart")

	if not torso then return end

	-- Création du BodyGyro et BodyVelocity pour stabiliser en vol
	local flyBG = Instance.new("BodyGyro", torso)
	flyBG.P = 9e4
	flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)

	local flyBV = Instance.new("BodyVelocity", torso)
	flyBV.Velocity = Vector3.new(0, 0.1, 0)
	flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)

	flyEnabled = true
	spawn(function()
		while flyEnabled do
			wait(0.1)
			-- Stabilisation en vol
			flyBG.CFrame = CFrame.new(torso.Position, torso.Position + (workspace.CurrentCamera.CFrame.LookVector))
		end

		-- Nettoyage des instances à l'arrêt du vol
		flyBG:Destroy()
		flyBV:Destroy()
	end)
end

-- Fonction pour désactiver le vol
local function stopFlying()
	flyEnabled = false
end

-- Fonction pour trouver le zombie le plus proche visible
local function getClosestZombieHead()
	local player = game.Players.LocalPlayer
	local camera = workspace.CurrentCamera
	local closestZombie = nil
	local closestDistance = math.huge

	-- Parcourir tous les zombies
	for _, zombie in ipairs(workspace.Zombies:GetChildren()) do
		local head = zombie:FindFirstChild("Head")
		if head then
			local distance = (camera.CFrame.Position - head.Position).magnitude

			-- Raycast pour vérifier la visibilité
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = {workspace.Zombies, player.Character}
			raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

			local raycastResult = workspace:Raycast(camera.CFrame.Position, (head.Position - camera.CFrame.Position).unit * distance, raycastParams)

			-- Vérifier s'il n'y a pas d'obstacle
			if not raycastResult and distance < closestDistance then
				closestDistance = distance
				closestZombie = head  -- Mettre à jour le zombie le plus proche visible
			end
		end
	end

	return closestZombie
end

-- Fonction pour téléporter au-dessus du zombie ou rester en vol
local function teleportAboveTargetZombie()
	local player = game.Players.LocalPlayer
	local character = player.Character

	if character and character:FindFirstChild("HumanoidRootPart") then
		-- Mettre à jour le zombie cible si le précédent est mort ou inexistant
		if targetZombieHead and targetZombieHead.Parent then
			-- Le zombie est toujours en vie, téléportez le joueur au-dessus
			local targetPosition = targetZombieHead.Position + Vector3.new(0, 6.5, 0)
			character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)

			-- Viser le zombie
			if aimbotEnabled then
				workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, targetZombieHead.Position)
			end
		else
			-- Trouver un nouveau zombie
			targetZombieHead = getClosestZombieHead()

			if targetZombieHead then
				local targetPosition = targetZombieHead.Position + Vector3.new(0, 6.5, 0)
				character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)

				-- Viser le zombie
				if aimbotEnabled then
					workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, targetZombieHead.Position)
				end
			else
				-- Aucun zombie trouvé, rester en vol
				if flyEnabled then
					local currentPosition = character.HumanoidRootPart.Position
					character.HumanoidRootPart.Position = Vector3.new(currentPosition.X, currentPosition.Y, currentPosition.Z)
				else
					startFlying()
				end
			end
		end
	end
end

-- Fonction pour gérer la téléportation rapide et le spam de V
local function teleportAndSpamV()
	while KnifeToggleActive do
		teleportAboveTargetZombie()
		-- Spam de la touche V
		game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.V, false, game)
		wait(0.01)
		game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.V, false, game)
		wait(0.1)
	end
	stopFlying()  -- Désactiver le vol une fois que le toggle est arrêté
end

-- Fonction pour rendre tous les objets invisibles et traversables sauf le joueur et les zombies
local function setGameElementsVisibility(isVisible)
	-- Cibler uniquement les objets de la carte dans le Workspace
	for _, obj in ipairs(workspace.MapFolder:GetDescendants()) do
		-- Cibler uniquement les Parts, MeshParts et UnionOperations
		if (obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("UnionOperation")) then
			-- Si on les rend invisibles, on enregistre leur état d'origine
			if isVisible then
				if not originalParts[obj] then
					originalParts[obj] = {Transparency = obj.Transparency, CanCollide = obj.CanCollide}
				end
			end

			-- Modifier la transparence et la collision
			obj.Transparency = isVisible and 1 or originalParts[obj].Transparency -- 1 pour invisible, état d'origine sinon
			obj.CanCollide = not isVisible -- Traversable si invisible, non traversable sinon
		end
	end
end

-- Fonction pour démarrer/arrêter le mode auto farm
local function toggleKnifeAndTeleport()
	local player = game.Players.LocalPlayer
	local character = player.Character

	KnifeToggleActive = not KnifeToggleActive

	if KnifeToggleActive then
		-- Enregistrer la position d'origine
		if character and character:FindFirstChild("HumanoidRootPart") then
			originalPosition = character.HumanoidRootPart.Position
		end
		startFlying()
		aimbotEnabled = true  -- Activer l'aimbot automatiquement
		setGameElementsVisibility(true)  -- Rendre les objets de la carte invisibles
		teleportAndSpamV()
	else
		wait(0.1)  -- Attendre un moment avant de téléporter
		if character and character:FindFirstChild("HumanoidRootPart") and originalPosition then
			character.HumanoidRootPart.CFrame = CFrame.new(originalPosition)
		end
		stopFlying()
		targetZombieHead = nil
		aimbotEnabled = false  -- Désactiver l'aimbot
		setGameElementsVisibility(false)  -- Rendre les objets de la carte visibles à nouveau
	end
end

-- Création du bouton toggle pour l'auto farm
local KnifeButton = MainTab:CreateToggle({
	Name = "Auto Farm",
	Callback = function(state)
		toggleKnifeAndTeleport()
	end
})

-- Boucle pour le suivi de l'aimbot dès que le toggle est activé
spawn(function()
	while true do
		wait(0.1)
		if KnifeToggleActive then
			targetZombieHead = getClosestZombieHead()  -- Obtenir la tête du zombie le plus proche visible
		end
	end
end)

