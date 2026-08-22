local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local BobDeveloperHub = {}
BobDeveloperHub.__index = BobDeveloperHub

local Theme = {
    Background = Color3.fromRGB(14, 14, 18),
    Secondary = Color3.fromRGB(20, 20, 25),
    Tertiary = Color3.fromRGB(28, 28, 34),
    Hover = Color3.fromRGB(35, 35, 43),
    Border = Color3.fromRGB(47, 47, 56),
    Text = Color3.fromRGB(240, 240, 245),
    SubText = Color3.fromRGB(145, 145, 155),
    Accent = Color3.fromRGB(115, 80, 255),
    Danger = Color3.fromRGB(220, 70, 80)
}

local Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local Normal = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local function Create(class, properties, parent)
    local object = Instance.new(class)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    object.Parent = parent
    return object
end

local function Corner(object, radius)
    Create("UICorner", {
        CornerRadius = UDim.new(0, radius)
    }, object)
end

local function Stroke(object)
    Create("UIStroke", {
        Color = Theme.Border,
        Thickness = 1
    }, object)
end

local function Tween(object, properties, info)
    return TweenService:Create(object, info or Normal, properties)
end

function BobDeveloperHub.new(options)
    options = options or {}

    local self = setmetatable({}, BobDeveloperHub)

    self.Title = options.Title or "BobDeveloperHub"
    self.Subtitle = options.Subtitle or "Universal Script Hub"

    self.Width = options.Width or 560
    self.Height = options.Height or 360

    self.MinWidth = 450
    self.MinHeight = 300

    self.Pages = {}
    self.Tabs = {}
    self.CurrentPage = nil
    self.Minimized = false

    self:_Create()

    return self
end

function BobDeveloperHub:_Create()
    local ScreenGui = Create("ScreenGui", {
        Name = "BobDeveloperHub",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, PlayerGui)

    self.ScreenGui = ScreenGui

    local Main = Create("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(self.Width, self.Height),
        Position = UDim2.new(
            0.5,
            -self.Width / 2,
            0.5,
            -self.Height / 2
        ),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0
    }, ScreenGui)

    Corner(Main, 9)
    Stroke(Main)

    self.Main = Main

    local Topbar = Create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0
    }, Main)

    Corner(Topbar, 9)

    self.Topbar = Topbar

    Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -120, 0, 20),
        Position = UDim2.fromOffset(14, 6),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    }, Topbar)

    Create("TextLabel", {
        Name = "Subtitle",
        Size = UDim2.new(1, -120, 0, 15),
        Position = UDim2.fromOffset(14, 27),
        BackgroundTransparency = 1,
        Text = self.Subtitle,
        TextColor3 = Theme.SubText,
        TextSize = 9,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, Topbar)

    local Minimize = Create("TextButton", {
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.new(1, -65, 0, 10),
        BackgroundColor3 = Theme.Tertiary,
        Text = "—",
        TextColor3 = Theme.Text,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false
    }, Topbar)

    Corner(Minimize, 6)

    local Close = Create("TextButton", {
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.new(1, -33, 0, 10),
        BackgroundColor3 = Theme.Tertiary,
        Text = "×",
        TextColor3 = Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false
    }, Topbar)

    Corner(Close, 6)

    self.Sidebar = Create("Frame", {
        Name = "Categories",
        Size = UDim2.new(0, 125, 1, -58),
        Position = UDim2.fromOffset(8, 54),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0
    }, Main)

    Corner(self.Sidebar, 7)

    Create("UIPadding", {
        PaddingTop = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6)
    }, self.Sidebar)

    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, self.Sidebar)

    self.Content = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -143, 1, -58),
        Position = UDim2.fromOffset(136, 54),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    }, Main)

    self:_SetupDragging(Topbar)
    self:_SetupResize()
    self:_SetupButtons(Minimize, Close)

    self.Main.Size = UDim2.fromOffset(self.Width - 25, self.Height - 25)

    Tween(self.Main, {
        Size = UDim2.fromOffset(self.Width, self.Height)
    }, Normal):Play()
end

function BobDeveloperHub:_SetupButtons(Minimize, Close)
    Minimize.MouseEnter:Connect(function()
        Tween(Minimize, {
            BackgroundColor3 = Theme.Hover
        }, Fast):Play()
    end)

    Minimize.MouseLeave:Connect(function()
        Tween(Minimize, {
            BackgroundColor3 = Theme.Tertiary
        }, Fast):Play()
    end)

    Close.MouseEnter:Connect(function()
        Tween(Close, {
            BackgroundColor3 = Theme.Danger
        }, Fast):Play()
    end)

    Close.MouseLeave:Connect(function()
        Tween(Close, {
            BackgroundColor3 = Theme.Tertiary
        }, Fast):Play()
    end)

    Minimize.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)

    Close.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
end

function BobDeveloperHub:_SetupDragging(Topbar)
    local Dragging = false
    local StartMouse
    local StartPosition

    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            StartMouse = input.Position
            StartPosition = self.Main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta = input.Position - StartMouse

            self.Main.Position = UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset + Delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
end

function BobDeveloperHub:_SetupResize()
    local ResizeHandle = Create("TextButton", {
        Size = UDim2.fromOffset(18, 18),
        Position = UDim2.new(1, -18, 1, -18),
        BackgroundTransparency = 1,
        Text = "⌟",
        TextColor3 = Theme.SubText,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false
    }, self.Main)

    local Resizing = false
    local StartMouse
    local StartSize

    ResizeHandle.MouseButton1Down:Connect(function()
        Resizing = true
        StartMouse = UserInputService:GetMouseLocation()
        StartSize = self.Main.AbsoluteSize
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not Resizing then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end

        local Mouse = UserInputService:GetMouseLocation()
        local Delta = Mouse - StartMouse

        local Width = math.max(
            self.MinWidth,
            StartSize.X + Delta.X
        )

        local Height = math.max(
            self.MinHeight,
            StartSize.Y + Delta.Y
        )

        self.Main.Size = UDim2.fromOffset(Width, Height)
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Resizing = false
        end
    end)

    self.ResizeHandle = ResizeHandle
end

function BobDeveloperHub:ToggleMinimize()
    if self.Minimized then
        self.Minimized = false

        self.Sidebar.Visible = true
        self.Content.Visible = true
        self.ResizeHandle.Visible = true

        Tween(self.Main, {
            Size = UDim2.fromOffset(self.Width, self.Height)
        }, Normal):Play()
    else
        self.Minimized = true

        self.Sidebar.Visible = false
        self.Content.Visible = false
        self.ResizeHandle.Visible = false

        Tween(self.Main, {
            Size = UDim2.fromOffset(self.Main.AbsoluteSize.X, 48)
        }, Normal):Play()
    end
end

function BobDeveloperHub:AddCategory(name)
    local Button = Create("TextButton", {
        Name = name,
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.Tertiary,
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.SubText,
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = false
    }, self.Sidebar)

    Corner(Button, 5)

    local Page = Create("ScrollingFrame", {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        Visible = false
    }, self.Content)

    Create("UIPadding", {
        PaddingTop = UDim.new(0, 3),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4)
    }, Page)

    Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, Page)

    local Category = {}
    Category.Page = Page

    local function Select()
        for _, page in pairs(self.Pages) do
            page.Visible = false
        end

        for _, tab in pairs(self.Tabs) do
            Tween(tab, {
                BackgroundTransparency = 1,
                TextColor3 = Theme.SubText
            }, Fast):Play()
        end

        Page.Visible = true

        Tween(Button, {
            BackgroundTransparency = 0,
            BackgroundColor3 = Theme.Tertiary,
            TextColor3 = Theme.Text
        }, Fast):Play()

        self.CurrentPage = Page
    end

    Button.MouseButton1Click:Connect(Select)

    Button.MouseEnter:Connect(function()
        if self.CurrentPage ~= Page then
            Tween(Button, {
                BackgroundTransparency = 0.6,
                BackgroundColor3 = Theme.Hover
            }, Fast):Play()
        end
    end)

    Button.MouseLeave:Connect(function()
        if self.CurrentPage ~= Page then
            Tween(Button, {
                BackgroundTransparency = 1
            }, Fast):Play()
        end
    end)

    function Category:AddSection(text)
        return Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 21),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.Text,
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left
        }, Page)
    end

    function Category:AddButton(text, callback)
        local ButtonFrame = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Theme.Secondary,
            Text = text,
            TextColor3 = Theme.Text,
            TextSize = 10,
            Font = Enum.Font.GothamMedium,
            AutoButtonColor = false
        }, Page)

        Corner(ButtonFrame, 6)
        Stroke(ButtonFrame)

        ButtonFrame.MouseEnter:Connect(function()
            Tween(ButtonFrame, {
                BackgroundColor3 = Theme.Hover
            }, Fast):Play()
        end)

        ButtonFrame.MouseLeave:Connect(function()
            Tween(ButtonFrame, {
                BackgroundColor3 = Theme.Secondary
            }, Fast):Play()
        end)

        ButtonFrame.MouseButton1Click:Connect(function()
            if callback then
                callback()
            end
        end)

        return ButtonFrame
    end

    function Category:AddToggle(text, default, callback)
        local Value = default == true

        local Frame = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 39),
            BackgroundColor3 = Theme.Secondary,
            BorderSizePixel = 0
        }, Page)

        Corner(Frame, 6)
        Stroke(Frame)

        Create("TextLabel", {
            Size = UDim2.new(1, -65, 1, 0),
            Position = UDim2.fromOffset(11, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.Text,
            TextSize = 10,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left
        }, Frame)

        local Switch = Create("TextButton", {
            Size = UDim2.fromOffset(36, 19),
            Position = UDim2.new(1, -47, 0.5, -9),
            BackgroundColor3 = Value and Theme.Accent or Theme.Tertiary,
            Text = "",
            AutoButtonColor = false
        }, Frame)

        Corner(Switch, 10)

        local Circle = Create("Frame", {
            Size = UDim2.fromOffset(13, 13),
            Position = Value
                and UDim2.new(1, -16, 0.5, -6)
                or UDim2.fromOffset(3, 3),
            BackgroundColor3 = Theme.Text,
            BorderSizePixel = 0
        }, Switch)

        Corner(Circle, 10)

        local function Update(state)
            Value = state

            Tween(Switch, {
                BackgroundColor3 = Value and Theme.Accent or Theme.Tertiary
            }, Fast):Play()

            Tween(Circle, {
                Position = Value
                    and UDim2.new(1, -16, 0.5, -6)
                    or UDim2.fromOffset(3, 3)
            }, Fast):Play()

            if callback then
                callback(Value)
            end
        end

        Switch.MouseButton1Click:Connect(function()
            Update(not Value)
        end)

        return {
            Set = function(_, value)
                Update(value == true)
            end,

            Get = function()
                return Value
            end
        }
    end

    function Category:AddSlider(text, minimum, maximum, default, callback)
        local Value = default or minimum

        local Frame = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 56),
            BackgroundColor3 = Theme.Secondary,
            BorderSizePixel = 0
        }, Page)

        Corner(Frame, 6)
        Stroke(Frame)

        Create("TextLabel", {
            Size = UDim2.new(1, -65, 0, 20),
            Position = UDim2.fromOffset(11, 4),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.Text,
            TextSize = 10,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left
        }, Frame)

        local ValueLabel = Create("TextLabel", {
            Size = UDim2.fromOffset(45, 20),
            Position = UDim2.new(1, -57, 0, 4),
            BackgroundTransparency = 1,
            Text = tostring(Value),
            TextColor3 = Theme.Accent,
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Right
        }, Frame)

        local Bar = Create("Frame", {
            Size = UDim2.new(1, -22, 0, 5),
            Position = UDim2.fromOffset(11, 37),
            BackgroundColor3 = Theme.Tertiary,
            BorderSizePixel = 0
        }, Frame)

        Corner(Bar, 5)

        local Fill = Create("Frame", {
            Size = UDim2.new(
                math.clamp(
                    (Value - minimum) / (maximum - minimum),
                    0,
                    1
                ),
                0,
                1,
                0
            ),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0
        }, Bar)

        Corner(Fill, 5)

        local Dragging = false

        local function Update(input)
            local Alpha = math.clamp(
                (input.Position.X - Bar.AbsolutePosition.X) /
                Bar.AbsoluteSize.X,
                0,
                1
            )

            Value = math.floor(
                minimum + (maximum - minimum) * Alpha + 0.5
            )

            Fill.Size = UDim2.new(Alpha, 0, 1, 0)
            ValueLabel.Text = tostring(Value)

            if callback then
                callback(Value)
            end
        end

        Bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true
                Update(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                Update(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = false
            end
        end)

        return {
            Set = function(_, value)
                Value = math.clamp(value, minimum, maximum)

                local Alpha =
                    (Value - minimum) /
                    (maximum - minimum)

                Fill.Size = UDim2.new(Alpha, 0, 1, 0)
                ValueLabel.Text = tostring(Value)

                if callback then
                    callback(Value)
                end
            end,

            Get = function()
                return Value
            end
        }
    end

    function Category:AddDropdown(text, options, callback, variant)
        variant = variant or "Default"

        local Selected = options[1]
        local Open = false

        local HeaderHeight = variant == "Compact" and 34 or 38

        local Frame = Create("Frame", {
            Size = UDim2.new(1, 0, 0, HeaderHeight),
            BackgroundColor3 = Theme.Secondary,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            ZIndex = 10
        }, Page)

        Corner(Frame, 6)
        Stroke(Frame)

        local Header = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, HeaderHeight),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 11
        }, Frame)

        Create("TextLabel", {
            Size = UDim2.new(0.5, 0, 1, 0),
            Position = UDim2.fromOffset(11, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.Text,
            TextSize = 10,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 12
        }, Header)

        local SelectedLabel = Create("TextLabel", {
            Size = UDim2.new(0.42, 0, 1, 0),
            Position = UDim2.new(0.52, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(Selected),
            TextColor3 = Theme.Accent,
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Right,
            ZIndex = 12
        }, Header)

        Create("TextLabel", {
            Size = UDim2.fromOffset(15, HeaderHeight),
            Position = UDim2.new(1, -19, 0, 0),
            BackgroundTransparency = 1,
            Text = "⌄",
            TextColor3 = Theme.SubText,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            ZIndex = 12
        }, Header)

        local Holder = Create("Frame", {
            Size = UDim2.new(1, -10, 0, #options * 30),
            Position = UDim2.fromOffset(5, HeaderHeight + 4),
            BackgroundTransparency = 1,
            ZIndex = 12
        }, Frame)

        Create("UIListLayout", {
            Padding = UDim.new(0, 3)
        }, Holder)

        for _, option in ipairs(options) do
            local OptionButton = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 27),
                BackgroundColor3 = Theme.Tertiary,
                Text = tostring(option),
                TextColor3 = Theme.Text,
                TextSize = 9,
                Font = Enum.Font.GothamMedium,
                AutoButtonColor = false,
                ZIndex = 13
            }, Holder)

            Corner(OptionButton, 5)

            OptionButton.MouseEnter:Connect(function()
                Tween(OptionButton, {
                    BackgroundColor3 = Theme.Hover
                }, Fast):Play()
            end)

            OptionButton.MouseLeave:Connect(function()
                Tween(OptionButton, {
                    BackgroundColor3 = Theme.Tertiary
                }, Fast):Play()
            end)

            OptionButton.MouseButton1Click:Connect(function()
                Selected = option
                SelectedLabel.Text = tostring(option)

                Open = false

                Tween(Frame, {
                    Size = UDim2.new(1, 0, 0, HeaderHeight)
                }, Normal):Play()

                if callback then
                    callback(option)
                end
            end)
        end

        Header.MouseButton1Click:Connect(function()
            Open = not Open

            local TargetHeight = HeaderHeight

            if Open then
                TargetHeight =
                    HeaderHeight +
                    Holder.AbsoluteSize.Y +
                    8
            end

            Tween(Frame, {
                Size = UDim2.new(1, 0, 0, TargetHeight)
            }, Normal):Play()
        end)

        return {
            Set = function(_, value)
                if table.find(options, value) then
                    Selected = value
                    SelectedLabel.Text = tostring(value)

                    if callback then
                        callback(value)
                    end
                end
            end,

            Get = function()
                return Selected
            end
        }
    end

    table.insert(self.Pages, Page)
    table.insert(self.Tabs, Button)

    if #self.Pages == 1 then
        Select()
    end

    return Category
end

function BobDeveloperHub:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

local Hub = BobDeveloperHub.new({
    Title = "BobDeveloperHub",
    Subtitle = "Universal Script Hub",
    Width = 560,
    Height = 360
})
