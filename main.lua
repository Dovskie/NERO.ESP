-- NeroESP Library (Version 0.2)
-- A modular GUI library for Roblox exploits using Drawing API for low detection.
-- Built step by step. Current: Basic window with drag and close button. Updated to config table with subtitle support.

local NeroESP = {}
NeroESP.__index = NeroESP

-- Services (compatible with exploits)
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Helper function to create Drawing objects
local function newDrawing(type)
    return Drawing.new(type)
end

-- Window class
function NeroESP.new(config)
    config = config or {}
    local self = setmetatable({}, NeroESP)
    
    self.Title = config.Title or "Example Usage"
    self.Subtitle = config.Subtitle or ""
    self.Position = config.Position or Vector2.new(100, 100)
    self.Size = config.Size or Vector2.new(500, 500)
    self.Dragging = false
    self.DragOffset = Vector2.new(0, 0)
    self.Visible = true
    self.Closed = false
    
    -- Colors (simple theme, expandable later)
    self.Colors = {
        Background = Color3.fromRGB(30, 30, 30),
        Border = Color3.fromRGB(100, 100, 100),
        TitleBar = Color3.fromRGB(50, 50, 50),
        Text = Color3.fromRGB(255, 255, 255),
        SubtitleText = Color3.fromRGB(200, 200, 200),  -- Lighter gray for subtitle
        CloseButton = Color3.fromRGB(200, 50, 50),
    }
    
    -- Drawing objects
    self.Objects = {}
    
    -- Main background
    self.Objects.Background = newDrawing("Square")
    self.Objects.Background.Size = self.Size
    self.Objects.Background.Position = self.Position
    self.Objects.Background.Color = self.Colors.Background
    self.Objects.Background.Filled = true
    self.Objects.Background.Visible = self.Visible
    self.Objects.Background.Transparency = 1
    self.Objects.Background.ZIndex = 1
    
    -- Border (slightly larger for outline)
    self.Objects.Border = newDrawing("Square")
    self.Objects.Border.Size = self.Size + Vector2.new(2, 2)
    self.Objects.Border.Position = self.Position - Vector2.new(1, 1)
    self.Objects.Border.Color = self.Colors.Border
    self.Objects.Border.Filled = false
    self.Objects.Border.Thickness = 1
    self.Objects.Border.Visible = self.Visible
    self.Objects.Border.ZIndex = 0
    
    -- Title bar
    self.Objects.TitleBar = newDrawing("Square")
    self.Objects.TitleBar.Size = Vector2.new(self.Size.X, 20)
    self.Objects.TitleBar.Position = self.Position
    self.Objects.TitleBar.Color = self.Colors.TitleBar
    self.Objects.TitleBar.Filled = true
    self.Objects.TitleBar.Visible = self.Visible
    self.Objects.TitleBar.ZIndex = 2
    
    -- Title text
    self.Objects.TitleText = newDrawing("Text")
    self.Objects.TitleText.Text = self.Title
    self.Objects.TitleText.Size = 14
    self.Objects.TitleText.Position = self.Position + Vector2.new(5, 3)
    self.Objects.TitleText.Color = self.Colors.Text
    self.Objects.TitleText.Visible = self.Visible
    self.Objects.TitleText.ZIndex = 3
    
    -- Subtitle text (if provided)
    if self.Subtitle ~= "" then
        self.Objects.SubtitleText = newDrawing("Text")
        self.Objects.SubtitleText.Text = self.Subtitle
        self.Objects.SubtitleText.Size = 12
        self.Objects.SubtitleText.Position = self.Position + Vector2.new(5, 25)  -- Below title bar
        self.Objects.SubtitleText.Color = self.Colors.SubtitleText
        self.Objects.SubtitleText.Visible = self.Visible
        self.Objects.SubtitleText.ZIndex = 3
    end
    
    -- Close button background
    self.Objects.CloseButtonBg = newDrawing("Square")
    self.Objects.CloseButtonBg.Size = Vector2.new(16, 16)
    self.Objects.CloseButtonBg.Position = self.Position + Vector2.new(self.Size.X - 18, 2)
    self.Objects.CloseButtonBg.Color = self.Colors.CloseButton
    self.Objects.CloseButtonBg.Filled = true
    self.Objects.CloseButtonBg.Visible = self.Visible
    self.Objects.CloseButtonBg.ZIndex = 2
    
    -- Close button text
    self.Objects.CloseButtonText = newDrawing("Text")
    self.Objects.CloseButtonText.Text = "X"
    self.Objects.CloseButtonText.Size = 12
    self.Objects.CloseButtonText.Position = self.Objects.CloseButtonBg.Position + Vector2.new(4, 2)
    self.Objects.CloseButtonText.Color = self.Colors.Text
    self.Objects.CloseButtonText.Visible = self.Visible
    self.Objects.CloseButtonText.ZIndex = 3
    
    -- Input handling for drag and close
    self.Connections = {}
    
    -- Mouse position helper (exploit compatible)
    local function getMousePosition()
        return UserInputService:GetMouseLocation()
    end
    
    -- Drag logic
    table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input)
        if self.Closed or not self.Visible then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = getMousePosition()
            local titleBarPos = self.Objects.TitleBar.Position
            local titleBarSize = self.Objects.TitleBar.Size
            if mousePos.X >= titleBarPos.X and mousePos.X <= titleBarPos.X + titleBarSize.X and
               mousePos.Y >= titleBarPos.Y and mousePos.Y <= titleBarPos.Y + titleBarSize.Y then
                if mousePos.X >= self.Objects.CloseButtonBg.Position.X and mousePos.X <= self.Objects.CloseButtonBg.Position.X + self.Objects.CloseButtonBg.Size.X and
                   mousePos.Y >= self.Objects.CloseButtonBg.Position.Y and mousePos.Y <= self.Objects.CloseButtonBg.Position.Y + self.Objects.CloseButtonBg.Size.Y then
                    -- Close button clicked
                    self:Close()
                else
                    -- Start drag
                    self.Dragging = true
                    self.DragOffset = mousePos - self.Position
                end
            end
        end
    end))
    
    table.insert(self.Connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = false
        end
    end))
    
    -- Update loop for dragging
    table.insert(self.Connections, RunService.Heartbeat:Connect(function()
        if self.Dragging then
            local mousePos = getMousePosition()
            self.Position = mousePos - self.DragOffset
            self:UpdatePositions()
        end
    end))
    
    return self
end

-- Update all object positions when window moves
function NeroESP:UpdatePositions()
    self.Objects.Background.Position = self.Position
    self.Objects.Border.Position = self.Position - Vector2.new(1, 1)
    self.Objects.TitleBar.Position = self.Position
    self.Objects.TitleText.Position = self.Position + Vector2.new(5, 3)
    if self.Objects.SubtitleText then
        self.Objects.SubtitleText.Position = self.Position + Vector2.new(5, 25)
    end
    self.Objects.CloseButtonBg.Position = self.Position + Vector2.new(self.Size.X - 18, 2)
    self.Objects.CloseButtonText.Position = self.Objects.CloseButtonBg.Position + Vector2.new(4, 2)
end

-- Close the window
function NeroESP:Close()
    self.Closed = true
    self.Visible = false
    for _, obj in pairs(self.Objects) do
        obj.Visible = false
        obj:Remove()  -- Clean up drawings
    end
    for _, conn in pairs(self.Connections) do
        conn:Disconnect()
    end
end

-- To use: local window = NeroESP.new({Title = "My Window", Subtitle = "Description", Position = Vector2.new(100, 100), Size = Vector2.new(300, 200)})

return NeroESP