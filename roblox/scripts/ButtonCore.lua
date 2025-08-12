-- Services nécessaires
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Fonction pour ajuster la taille de menuSection
-- Fonction pour ajuster la taille de menuSection
local function updateMenuSectionSize(panelContainer, menuSection)
    if not panelContainer or not menuSection then return end
    local numberOfChildren = #panelContainer:GetChildren()
    local correctWidth = numberOfChildren * 44  -- Chaque bouton a une largeur de 44
    menuSection.Size = UDim2.new(0, correctWidth, 0, 44)  -- Mise à jour de la taille de la section
end

-- Surveiller la taille de menuSection en temps réel
local function monitorMenuSectionSize(panelContainer, menuSection)
    RunService.Heartbeat:Connect(function()
        if not panelContainer or not menuSection then return end
        updateMenuSectionSize(panelContainer, menuSection)
    end)
end
-- Fonction principale pour créer un panneau dans la TopBar
local function CreateTopBar(panelName, iconId)
    local topBarApp = CoreGui:FindFirstChild("TopBarApp", true)
    if not topBarApp then
        warn("TopBarApp introuvable dans CoreGui.")
        return
    end

    local unibarLeftFrame = topBarApp:FindFirstChild("UnibarLeftFrame", true)
    if not unibarLeftFrame then
        warn("UnibarLeftFrame introuvable.")
        return
    end

    local unibarMenu = unibarLeftFrame:FindFirstChild("UnibarMenu", true)
    if not unibarMenu then
        warn("UnibarMenu introuvable.")
        return
    end

    local menuSection = unibarMenu:FindFirstChild("2", true)
    if not menuSection then
        warn("Section '2' introuvable dans UnibarMenu.")
        return
    end

    local panelContainer = menuSection:FindFirstChild("3", true)
    if not panelContainer then
        warn("Section '3' introuvable dans Section '2'.")
        return
    end

    -- Création du bouton pour le panneau
    local button = Instance.new("TextButton")
    button.Name = panelName or "Panel"
    button.Position = UDim2.new(0, #panelContainer:GetChildren() * 44, 0, 0)
    button.Size = UDim2.new(0, 44, 0, 44)
    button.Text = ""
    button.BackgroundTransparency = 1
    button.Parent = panelContainer

    -- Ajouter un Highlight
    local highlight = Instance.new("Frame")
    highlight.Name = "Highlight"
    highlight.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
    highlight.BackgroundTransparency = 0.9
    highlight.Size = UDim2.new(0, 36, 0, 36)
    highlight.Position = UDim2.new(0.5, 0, 0.5, 0)
    highlight.AnchorPoint = Vector2.new(0.5, 0.5)
    highlight.Visible = false
    highlight.Parent = button

    -- Coin arrondi pour Highlight
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0.5, 0)
    uiCorner.Parent = highlight

    -- Ajouter une icône
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Image = iconId or "rbxassetid://18111019114"
    icon.Size = UDim2.new(0, 22, 0, 22)
    icon.Position = UDim2.new(0.5, -11, 0.5, -11)
    icon.BackgroundTransparency = 1
    icon.Parent = button

    -- Événements pour interactions
    button.MouseEnter:Connect(function()
        highlight.Visible = true
    end)

    button.MouseLeave:Connect(function()
        highlight.Visible = false
    end)

    button.MouseButton1Click:Connect(function()
        local isSelected = not button.Selected
        button.Selected = isSelected
        icon.ImageColor3 = isSelected and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 255, 255)
    end)

    -- Ajuster la taille de menuSection
    updateMenuSectionSize(panelContainer, menuSection)
    monitorMenuSectionSize(panelContainer, menuSection)
end

-- Fonction pour détruire un panneau spécifique
local function DestroyTopBar(panelName)
    -- Vérifier si le panneau existe dans la hiérarchie
    local topBarApp = CoreGui:FindFirstChild("TopBarApp", true)
    if not topBarApp then
        warn("TopBarApp introuvable dans CoreGui.")
        return
    end

    local unibarLeftFrame = topBarApp:FindFirstChild("UnibarLeftFrame", true)
    if not unibarLeftFrame then
        warn("UnibarLeftFrame introuvable.")
        return
    end

    local unibarMenu = unibarLeftFrame:FindFirstChild("UnibarMenu", true)
    if not unibarMenu then
        warn("UnibarMenu introuvable.")
        return
    end

    local menuSection = unibarMenu:FindFirstChild("2", true)
    if not menuSection then
        warn("Section '2' introuvable dans UnibarMenu.")
        return
    end

    local panelContainer = menuSection:FindFirstChild("3", true)
    if not panelContainer then
        warn("Section '3' introuvable dans Section '2'.")
        return
    end

    -- Trouver et détruire le panneau par son nom
    local panelToDestroy = panelContainer:FindFirstChild(panelName)
    if panelToDestroy then
        panelToDestroy:Destroy()
        print(panelName .. " a été détruit avec succès.")
    else
        warn(panelName .. " introuvable dans la TopBar.")
    end
end

-- Exemple d'utilisation
CreateTopBar("PowerJump", "rbxassetid://18111019114") -- Crée un panneau appelé "PowerJump" avec une icône spécifique
-- DestroyTopBar("PowerJump") -- Supprime le panneau appelé "PowerJump" (décommenter pour tester)
