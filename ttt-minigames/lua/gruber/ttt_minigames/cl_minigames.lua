Gruber = Gruber or {}
Gruber.miniGameMenu = Gruber.miniGameMenu
local function openMiniGameMenu()
    if Gruber.minigameMenu and IsValid(Gruber.minigameMenu) then
        Gruber.minigameMenu:Remove()
    end
    local miniGameMenu = vgui.Create("DFrame")
    miniGameMenu:SetSize(math.max(600, ScrW() * 0.5), math.max(700, ScrH() * 0.5))
    miniGameMenu:SetTitle("Minigames")
    miniGameMenu:Center()
    miniGameMenu:MakePopup()

    Gruber.miniGameMenu = miniGameMenu

    local container = miniGameMenu:Add("Panel")
    container:Dock(FILL)

    local dashboard = miniGameMenu:Add("DScrollPanel")
    dashboard:Dock(LEFT)
    dashboard:DockMargin(0,0,5,0)

    local function openPage(url)
        return function(pnl)
            local html = pnl:Add("DHTML")
            html:Dock(FILL)
            html:InvalidateLayout(true)
            html:InvalidateParent(true)
            html:OpenURL(url)
            html:RequestFocus()
        end
    end
    local games = {
        {
            name = "Snake",
            callback = openPage("http://minigames.instinkt-servers.net/Snake/")
        },
        {
            name = "Tetris",
            callback = openPage("http://minigames.instinkt-servers.net/tetris/")
        },
        {
            name = "Flappy Bird",
            callback = openPage("http://minigames.instinkt-servers.net/floppybird/")
        },
        {
            name = "Tic-Tac-Toe",
            callback = Gruber.TicTacToe.callback
        }
    }

    for k,v in pairs(games) do
        local gameBtn = dashboard:Add("DButton")
        gameBtn:SetText(v.name)
        gameBtn:Dock(TOP)
        function gameBtn:DoClick()
            container:Clear()
            v.callback(container)
        end
    end
end

local function closeMiniGameMenu()
    local miniGameMenu = Gruber.miniGameMenu
--    print(miniGameMenu)
    if miniGameMenu and IsValid(miniGameMenu) then
        miniGameMenu:Remove()
    end
end

concommand.Add("open-minigames", openMiniGameMenu)

hook.Add("OnPlayerChat", "Gruber.MiniGames.OpenMenu", function(ply, text)
    if ply ~= LocalPlayer() then return end
    if text ~= "!minigames" then return end
    if ply:Team() ~= TEAM_SPEC then
        chat.AddText(Color(255,255,255), "Du kannst keine Minigames spielen, wenn Du lebst.")
        return
    end

    openMiniGameMenu()
end)
hook.Add("TTTPrepareRound", "Gruber.MiniGames.CloseMenu", function()
    closeMiniGameMenu()
end)