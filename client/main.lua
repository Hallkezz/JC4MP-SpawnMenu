local TOGGLE_KEY = Key.V

local WV_URL = "resource://" .. Resource.Name .. "/client/window.html"
local WEBVIEW_ID = "spawn_menu_ui"

local WINDOW_POS_REL = vec2(0.5, 0.5)
local WINDOW_SIZE_REL = vec2(0.45, 0.55)

local webview_created = false
local activeWindow = false

function CreateWebView()
    local screenSize = Render.GetSize()

    local size = vec2(WINDOW_SIZE_REL.x * screenSize.x, WINDOW_SIZE_REL.y * screenSize.y)
    local pos = vec2(WINDOW_POS_REL.x * screenSize.x - size.x / 2, WINDOW_POS_REL.y * screenSize.y - size.y / 2)

    local created = WebView.Create(WEBVIEW_ID, {
        url = WV_URL,
        position = pos,
        size = size,
        visible = true,
        input_enabled = false,
        z_order = 100
    })

    if created ~= "" then
        webview_created = true

        WebView.SetMessageHandler(WEBVIEW_ID, function(event, data)
            if event == "ui:ready" then
                WebView.SendMessage(WEBVIEW_ID, "init", {
                    toggle_key = TOGGLE_KEY
                })
            elseif event == "spawn:item" then
                if data and data.id and data.type then
                    local player = Players.LocalPlayer()
                    if player then
                        if data.type == "vehicle" then
                            local spawn_pos = player:GetPosition()
                            local spawn_rot = player:GetRotation()
                            Net.Send("spawn", data.id, spawn_pos, spawn_rot, Players.LocalClient())
                        elseif data.type == "mounted_gun" then
                            local spawn_pos = player:GetAimPosition()
                            Net.Send("spawnMg", data.id, spawn_pos)
                        elseif data.type == "skin" then
                            Local.SetSkin(data.id)
                        elseif data.type == "weapon" then
                            Net.Send("weapon", data.id, data.slot, Players.LocalClient())
                        end
                        SetVisible(false)
                    end
                end
            elseif event == "ui:close" then
                SetVisible(false)
            end
        end)
    end
end

function SetVisible(visible)
    if not webview_created then
        return
    end

    WebView.BlurAll()

    activeWindow = visible
    WebView.SetVisible(WEBVIEW_ID, visible)
    WebView.SetInputEnabled(WEBVIEW_ID, visible)

    UI.SetCursorVisible(visible)

    Timer.Set(function()
        WebView.Focus(WEBVIEW_ID)
    end, 1, 1)
end

function ToggleSpawnMenu()
    if not webview_created then
        CreateWebView()
    end

    activeWindow = not activeWindow
    SetVisible(activeWindow)
end

function OnResourceStop(resourceName)
    if resourceName == Resource.Name then
        if webview_created then
            if activeWindow then
                SetVisible(false)
            end
            WebView.Destroy(WEBVIEW_ID)
        end
    end
end

Event.Add("OnKeyUp", function(key)
    if key == TOGGLE_KEY then
        ToggleSpawnMenu()
    end
end)

Event.Add("OnResourceStop", OnResourceStop)