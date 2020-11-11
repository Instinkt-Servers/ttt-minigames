if SERVER then
    include("gruber/ttt_minigames/sv_tictactoe.lua")
    AddCSLuaFile("gruber/ttt_minigames/cl_tictactoe.lua")
    AddCSLuaFile("gruber/ttt_minigames/cl_minigames.lua")

    hook.Add("PlayerDeath", "Gruber.MiniGames.ShowMessage", function(ply)
        ply:SendLua([[
            chat.AddText(Color(255,255,255), "Tippe: ", Color(255,255,0), "!minigames ", Color(255,255,255), "um die Minigames zu öffnen!")
        ]])
    end)

else
    include("gruber/ttt_minigames/cl_tictactoe.lua")
    include("gruber/ttt_minigames/cl_minigames.lua")
end