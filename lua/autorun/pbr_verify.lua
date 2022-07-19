local file_Exists = file.Exists
local vecRed = Vector(255,0,0)
local vecGreen = Vector(0,255,0)
local vecBlue = Vector(0,100,255)

PBR = PBR or {}

if SERVER then
    util.AddNetworkString("PBR_WriteChat")

    PBR.WriteText = function(ply, text, col)
        net.Start("PBR_WriteChat")
            net.WriteString(text)
            net.WriteVector(col or vecRed)
        net.Send(ply)
    end
else
    net.Receive("PBR_WriteChat", function()
        local msg = net.ReadString()
        local col = net.ReadVector()
        chat.AddText(Color(col[1], col[2], col[3]), msg)
    end)
end

PBR.IsInstalled = false

PBR.RequiredFiles = {
    "bin/game_shader_dx9.dll",
    "shaders/fxc/pbr_ps20b.vcs",
    "shaders/fxc/pbr_ps30.vcs",
    "shaders/fxc/pbr_vs20b.vcs",
    "shaders/fxc/pbr_vs30.vcs"
}

PBR.CheckForFiles = function()
    for _, file in pairs(PBR.RequiredFiles) do
        print("[PBR] Checking for file: " .. file)
        if not file_Exists(file,"GAME") then
            print("[PBR] File not found: " .. file)
            return false
        end
    end

    print("[PBR] All files verified!")
    return true
end

hook.Add("Initialize", "!!!!!!!!! PBR.Initialize", function()
    if PBR.CheckForFiles() then -- Let's verify the files...
        PBR.IsInstalled = true -- Files verified!
        print("PBR Modules are successfully installed!")
        timer.Simple(15,function() -- Display a message 15 seconds later to ensure they see it
            print("Displaying PBR message...")
            if SERVER then
                for _,v in pairs(player.GetAll()) do
                    PBR.WriteText(v, "PBR Modules successfully verified!", vecGreen) -- Send the message!
                end
            end
        end)
    else -- They didn't install the files...
        print("PBR Modules are not installed!")
        timer.Simple(15,function()
            print("Displaying PBR message...")
            if SERVER then
                for _,v in pairs(player.GetAll()) do
                    PBR.WriteText(v, "You have a mod that utilizes PBR, but do not have the actual PBR modules installed! Please download the PBR Modules from GitHub!")
                    PBR.WriteText(v, "GitHub Link: https://github.com/Cpt-Hazama/GMod-PBR-Modules", vecBlue)
                end
            end
        end)
    end
end)