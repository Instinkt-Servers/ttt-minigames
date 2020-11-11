Gruber = Gruber or {}
Gruber.TicTacToe = Gruber.TicTacToe or {}

Gruber.TicTacToe.callback = function(pnl)
    local mySide, opponent, currentTurn
    local state = {}

    for i = 1, 3 do
        state[i] = {}
    end

    local title = pnl:Add("DLabel")
    title:SetText("Tic-Tac-Toe!")
    title:SetContentAlignment(5)
    title:SetTextColor(Color(255, 255, 255))
    title:Dock(TOP)
    local status = pnl:Add("DLabel")
    status:SetContentAlignment(5)
    status:Dock(TOP)
    status:SetTextColor(Color(255, 255, 255))
    status:SetText("Auf weiteren Spieler warten...")
    local bg = pnl:Add("Panel")
    bg:Dock(FILL)
    bg:InvalidateParent(true)

    function bg:Paint(w, h)
        surface.SetDrawColor(0, 0, 0)
        surface.DrawRect(0, 0, w, h)
    end

    local total_width = math.min(bg:GetTall(), bg:GetWide())
    local sideMargins = (bg:GetWide() - total_width) / 2
    bg:DockMargin(sideMargins, 0, sideMargins, 0)
    net.Start("TicTacToe.Update")
    net.WriteString("StartedWaiting")
    net.SendToServer()

    local function verifyPositions(pos1, pos2, pos3)
        if pos1 == pos2 and pos2 == pos3 then return pos1 end
    end

    local function checkWin()
--        PrintTable(state)

        -- Rows
        for row = 1, 3 do
            local winner = verifyPositions(state[row][1], state[row][2], state[row][3])
--            print(state[row][1], state[row][2], state[row][3])
 --           print(winner)
            if winner ~= nil then return winner end
        end

        -- Columns
        for col = 1, 3 do
            local winner = verifyPositions(state[1][col], state[2][col], state[3][col])
            if winner ~= nil then return winner end
        end

        -- Left-to-right, top-to-bottom diagonal
        local winner = verifyPositions(state[1][1], state[2][2], state[3][3])
        if winner ~= nil then return winner end
        -- Right-to-left, top-to-bottom diagonal
        local winner = verifyPositions(state[1][3], state[2][2], state[3][1])
        if winner ~= nil then return winner end
    end

    local function chooseWinner(winner)
        if winner == mySide then
            status:SetText("Du hast gewonnen! Herzlichen Glückwunsch!")
        else
            status:SetText("Du hast verloren! :(")
        end

        finished = true
    end

    local function isPlayable()
        for row = 1, 3 do
            for col = 1, 3 do
                if state[row][col] == nil then return true end
            end
        end

        return false
    end

    local function move(row, col)
        if currentTurn == nil then return end
        if state[row][col] ~= nil then return end
        state[row][col] = currentTurn

        if mySide == currentTurn then
            net.Start("TicTacToe.Update")
            net.WriteString("PlayerMoved")
            net.WriteUInt(row, 3)
            net.WriteUInt(col, 3)
            net.SendToServer()
        end

        local winner = checkWin()

        if winner ~= nil then
            chooseWinner(winner)
        elseif not isPlayable() then
            status:SetText("Draw!")
            finished = true
        else
            currentTurn = not currentTurn

            if winner == nil and mySide == currentTurn then
                status:SetText("Dein bist dran!")
            else
                status:SetText("Dein Gegenspieler ist dran")
            end
        end
    end

    local finished = false
    local iconLayout = bg:Add("DIconLayout")
    iconLayout:Dock(FILL)
    local s = 5
    iconLayout:SetSpaceY(s)
    iconLayout:SetSpaceX(s)
    local slotSize = (total_width - s * 2) / 3
    local buttons = {}

    for i = 1, 9 do
        local slot = iconLayout:Add("DButton")
        slot:SetSize(slotSize, slotSize)
        slot:SetText("")
        buttons[i] = slot

        function slot:Paint(w, h)
            local s = state[math.ceil(i / 3)][(i - 1) % 3 + 1]

            if s == nil then
                surface.SetDrawColor(255, 255, 255)
            elseif s == false then
                surface.SetDrawColor(255, 0, 0)
            elseif s == true then
                surface.SetDrawColor(0, 255, 0)
            end

            surface.DrawRect(0, 0, w, h)
        end

        function slot:DoClick(w, h)
            if finished then return end
            local row = math.ceil(i / 3)
            local col = (i - 1) % 3 + 1

            if currentTurn == mySide then
                move(row, col)
            end
        end
    end

    function iconLayout:OnRemove()
        if finished then return end
        net.Start("TicTacToe.Update")
        net.WriteString("PlayerDisconnect")
        net.SendToServer()
    end

    net.Receive("TicTacToe.Update", function(len)
        if not IsValid(pnl) then return end
        local updateType = net.ReadString()

        if updateType == "GameStarted" then
            opponent = net.ReadEntity()
            mySide = net.ReadBool()
            currentTurn = net.ReadBool()
            title:SetText("Du spielst gegen " .. opponent:Name())

            if mySide == currentTurn then
                status:SetText("Du bist dran!")
            else
                status:SetText("Dein Gegenspieler ist dran")
            end
        elseif updateType == "PlayerDisconnect" then
            chooseWinner(mySide)
            status:SetText("Dein Gegenspieler hat das Spiel verlassen.")
            finished = true
        elseif updateType == "PlayerMoved" then
            local row = net.ReadUInt(3)
            local col = net.ReadUInt(3)
            move(row, col)
        else
            ErrorNoHalt("Unkown updateType received: " .. updateType)
        end
    end)
end