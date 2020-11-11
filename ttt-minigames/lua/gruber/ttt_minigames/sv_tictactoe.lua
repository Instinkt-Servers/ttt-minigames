util.AddNetworkString("TicTacToe.Update")

local waiting_ply = nil
local function playerDisconnected(ply)
    local tic_game = ply.TicTacToeGame
    if tic_game then
        for k,v in pairs(tic_game.sides) do
            if v ~= ply and v.TicTacToeGame == tic_game then
                net.Start("TicTacToe.Update")
                    net.WriteString("PlayerDisconnect")
                net.Send(v)
                v.TicTacToeGame = nil
            end
        end
        ply.TicTacToeGame = nil
    elseif ply == waiting_ply then
        waiting_ply = nil
    end
end

hook.Add("PlayerDisconnected", "TicTacToe-Quit", function(ply)
    playerDisconnected(ply)
end)

net.Receive("TicTacToe.Update", function(len, ply)
    local cmd = net.ReadString()
--    print(cmd)
    if cmd == "StartedWaiting" then
        if waiting_ply ~= nil and waiting_ply ~= ply then
--            print("Starting Game")
            local randomBool = math.random(0,1) >= 0.5
            local newGame = {
                currentTurn = math.random(0,1) >= 0.5,
                sides = {
                    [randomBool] = waiting_ply,
                    [not randomBool] = ply
                },
                inverseSides = {
                    [waiting_ply] = randomBool,
                    [ply] = not randomBool
                }
            }
            ply.TicTacToeGame = newGame
            waiting_ply.TicTacToeGame = newGame

            for side,side_ply in pairs(newGame.sides) do
                side_ply.TicTacToeGame = newGame
                net.Start("TicTacToe.Update")
                    net.WriteString("GameStarted")
                    net.WriteEntity(newGame.sides[not side])
                    net.WriteBool(side)
                    net.WriteBool(newGame.currentTurn)
                net.Send(side_ply)
            end
            waiting_ply = nil
        else
            print("Joined as waiting")
            waiting_ply = ply
        end
    elseif cmd == "PlayerMoved" then
        local tic_game = ply.TicTacToeGame
        if tic_game.sides[tic_game.currentTurn] ~= ply then return end

        local row = net.ReadUInt(3)
        local col = net.ReadUInt(3)
        tic_game.currentTurn = not tic_game.currentTurn

        net.Start("TicTacToe.Update")
            net.WriteString("PlayerMoved")
            net.WriteUInt(row, 3)
            net.WriteUInt(col, 3)
        net.Send(tic_game.sides[tic_game.currentTurn])
    elseif cmd == "PlayerDisconnect" then
        playerDisconnected(ply)
    else
        Error("Unknown command " .. cmd .. " from " .. ply:Name() .. "(" .. ply:SteamID() .. ")")
    end
end)

return