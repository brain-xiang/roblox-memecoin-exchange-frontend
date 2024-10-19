-- Gui Util
-- Legenderox
-- January 22, 2021



local GuiUtil = {}
local TweenService = game:GetService("TweenService")

GuiUtil.KEYCODE_TO_ICON = {
    [Enum.KeyCode.ButtonX] = "rbxassetid://5566767804",
    [Enum.KeyCode.ButtonY] = "rbxassetid://5566773418",
    [Enum.KeyCode.ButtonA] = "rbxassetid://3202883983",
    [Enum.KeyCode.ButtonB] = "rbxassetid://3202882920",
    [Enum.KeyCode.DPadLeft] = "rbxassetid://469343344",
    [Enum.KeyCode.DPadRight] = "rbxassetid://469343369",
    [Enum.KeyCode.DPadUp] = "rbxassetid://469343399",
    [Enum.KeyCode.DPadDown] = "rbxassetid://469343317",
}

function GuiUtil:getProperty(instance, propertyName)
    local property;
    
    pcall(function()
        if typeof(instance[propertyName]) ~= "Instance" then 
            property = instance[propertyName]
        end
    end)

    return property
end

function GuiUtil:getChildrenOfClass(instance, className)
    --[[
        input: className = string
        returns: tbl, children
    ]]

    local childrenOfClass = {}
    for i,child in pairs(instance:GetChildren()) do
        if child.ClassName == className then
            table.insert(childrenOfClass, child)
        end
    end
    return childrenOfClass
end

function GuiUtil:getDescendantsOfClass(instance, className)
    --[[
        input: className = string
        returns: tbl, children
    ]]

    local children = instance:GetDescendants()
    for i,child in pairs(children) do
        if child.ClassName ~= className then
            table.remove(children, i)
        end
    end
    return children
end

function GuiUtil:fadeInPreset(guis, parentGui, time)
    --[[
        input: gui = table of GuiObjects, parentGui = GuiObject, holds the guis
        Fades the guis in using their presets.
        returns: lastTween, the last activated tween object
    ]]

    table.insert(guis, parentGui)
    local lastTween;
    if self:getProperty(parentGui, "Enabled") ~= nil then
        parentGui.Enabled = true
    elseif self:getProperty(parentGui, "Visible") ~= nil then
        parentGui.Visible = true
    else
        error(parentGui.Name.. " - ParentGui(guis[1]) Does not have Visible or Enabled properties")
        return
    end
    for i,element in pairs(guis) do
        local Properties = {
            BackgroundTransparency = self:getProperty(element, "BackgroundTransparency"),
            ImageTransparency = self:getProperty(element, "ImageTransparency"),
            TextTransparency = self:getProperty(element, "TextTransparency"),
            TextStrokeTransparency = self:getProperty(element, "TextStrokeTransparency"),
        }

        for Transparency, v in pairs(Properties) do
            element[Transparency] = 1
        end
        local tweenInfo = TweenInfo.new(time)
        local tween = TweenService:Create(element, tweenInfo, Properties)
        tween:Play()
        lastTween = tween
    end

    return lastTween
end

function GuiUtil:fadeOutPreset(guis, parentGui, time)
    --[[
        input: gui = table of GuiObjects, parentGui = GuiObject, holds the guis
        Fades the guis out using their presets.
        returns: firstTween, the first activated tween object
    ]]
    
    table.insert(guis, parentGui)
    local firstTween;
    for i,element in pairs(guis) do
        local Properties = {
            BackgroundTransparency = self:getProperty(element, "BackgroundTransparency"),
            ImageTransparency = self:getProperty(element, "ImageTransparency"),
            TextTransparency = self:getProperty(element, "TextTransparency"),
            TextStrokeTransparency = self:getProperty(element, "TextStrokeTransparency"),
        }

        local tweenInfo = TweenInfo.new(time)
        local tween = TweenService:Create(element, tweenInfo, {
            BackgroundTransparency = Properties.BackgroundTransparency and 1 or nil,
            ImageTransparency = Properties.ImageTransparency and 1 or nil,
            TextTransparency = Properties.TextTransparency and 1 or nil,
            TextStrokeTransparency = Properties.TextStrokeTransparency and 1 or nil,
        })
        tween:Play()
        firstTween = firstTween or tween
        
        tween.Completed:Connect(function()
            for Transparency, v in pairs(Properties) do
                element[Transparency] = v
            end
        end)
    end

    firstTween.Completed:Connect(function()
        if self:getProperty(parentGui, "Enabled") ~= nil then
            parentGui.Enabled = false
        elseif self:getProperty(parentGui, "Visible") ~= nil then
            parentGui.Visible = false
         else
            error(parentGui.Name.. " - ParentGui(guis[1]) Does not have Visible or Enabled properties")
            return
        end
    end)
    
    return firstTween
end

function GuiUtil:popInPreset(gui, tweenInfo)
    --[[
        input: gui = GuiObject, tweenInfo = TweenInfo
        pops the gui in using it's presets.
        returns: tween
    ]]

    local preset = gui.Size
    gui.Size = UDim2.new(0,0,0,0)
    gui.Visible = true

    local tween = TweenService:Create(gui, tweenInfo, {Size = preset})
    tween:Play()

    return tween 
end

function GuiUtil:hoverEnlarge(gui, enlargeRatio, originalSize, bool)
    --[[
        input: gui = GuiObject, bool = enlarge or return to normal size, enlargeRatio = float, how much to enlarge gui by
        enlarges gui by enlargeRatio 
    ]]
    local newSize = bool and UDim2.new(originalSize.X.Scale * enlargeRatio, 0, originalSize.Y.Scale * enlargeRatio, 0) or originalSize
	local tween = TweenService:Create(gui, TweenInfo.new(0.1), {Size = newSize})
	tween:Play()
end

function GuiUtil:offsetToScale(size, parent)
    --[[
        input: size = Udim2
        returns: Udim2, size converted to scale in porportion to parent
    ]]

    local absoluteSize = parent and parent.AbsoluteSize or workspace.CurrentCamera.ViewportSize -- Vector2
    return UDim2.new((size.X.Offset / absoluteSize.X) + size.X.Scale, 0, (size.Y.Offset / absoluteSize.Y) + size.Y.Scale, 0)
end

function GuiUtil:scaleToOffset(size, parent)
    --[[
        input: size = Udim2
        returns: Udim2, size converted to offset in porportion to parent
    ]]
    local absoluteSize = parent and parent.AbsoluteSize or workspace.CurrentCamera.ViewportSize -- Vector2
    return UDim2.new(0, (size.X.Scale * absoluteSize.X) + size.X.Offset, 0, (size.Y.Scale * absoluteSize.Y) + size.Y.Offset)
end

function GuiUtil:absoluteToLocalPosition(absolutePosition, localElement)
    --[[
        input: absolutePosition = Vector2, localElement = GuiObject, parent/local element the position will be localised for
        returns: Udim2 offset, An absolute Position on the screen in form of a local position to the element provided
    ]]
    local x = absolutePosition.X - localElement.AbsolutePosition.X
    local y = absolutePosition.Y - localElement.AbsolutePosition.Y
    return UDim2.new(0, x, 0, y)
end

function GuiUtil:getCenter(pos, anchorPoint, absoluteSize)
    --[[
        input: pos = Udim2, anchorPoint, absoluteSize = Vector2
        returns: Udim2 (mixed if pos = scale), relative centerposition, pos + centerOffset (how many pixels the offset is from center)
    ]]
    return pos + UDim2.new(0, (0.5 - anchorPoint.X)*absoluteSize.X, 0, (0.5 - anchorPoint.Y)*absoluteSize.Y)
end

function GuiUtil:getAbsoluteCenter(guiOrPos, absoluteSize)
    --[[
        input: 
            guiOrPos, absoluteSize = vector2
            
            or:

            guiOrPos = GuiObject, absoluteSize = nil
        returns: vector2, Absolute center of the gui
    ]]
    if typeof(guiOrPos) == "Vector2" and typeof(absoluteSize) == "Vector2" then
        return Vector2.new(guiOrPos.X + (absoluteSize.X/2), guiOrPos.Y + (absoluteSize.Y/2))
    elseif guiOrPos:IsA("GuiButton") then
        return Vector2.new(guiOrPos.AbsolutePosition.X + (guiOrPos.AbsoluteSize.X/2), guiOrPos.AbsolutePosition.Y + (guiOrPos.AbsoluteSize.Y/2))
    end
    warn("getAbsoluteCenter got invalid args")
    return nil
end

function GuiUtil:typeWriteByDuration(label, text, duration)
    --[[
        input: label = TextLabel, text = string, duration = int
        Writes out text onto label one character at a time, in the duration provided
    ]]
    if duration / #text < 0.03 then error(tostring(duration).. " seconds is too short to typeWrite ".. tostring(#text).. " characters.") end

    label.Text = ""
    label.Visible = true
    for i = 1, #text do
        label.Text = string.sub(text, 1, i)
        wait(duration/#text)
    end
end

function GuiUtil:typeWriteByDelay(label, text, delay)
    --[[
        input: label = TextLabel, text = string, delay = int, waitFunc = function, specify wait function like RenderStepped
        Writes out text onto label one character at a time, waiting "delay" between each letter
    ]]

    label.Text = ""
    label.Visible = true
    for i = 1, #text do
        label.Text = string.sub(text, 1, i)
        wait(delay)
    end
end

function GuiUtil:disperseRandomlyInArea(guis, center, size, tweenInfo, delay)
    --[[
        input: guis = tbl, center = Vector2, center position of area, size = Vector2, area size, tweenInfo = TweenInfo, secified tweeninfo for tween
        tweens gui to random positions in the area (calculated using center and size)
        returns: tween, Last tween that was played
    ]]
    tweenInfo = tweenInfo or TweenInfo.new()
    local lastTween;
    for i,gui in pairs(guis) do
        local offsetX = math.random(-size.X/2, size.X/2)
        local offsetY = math.random(-size.Y/2, size.Y/2)
        local offset = Vector2.new(offsetX, offsetY)
        local endPos = GuiUtil:absoluteToLocalPosition(center + offset, gui.Parent)

        local tween = TweenService:Create(gui, tweenInfo, {Position = endPos})
        tween:Play()
        lastTween = tween
        if delay then 
            wait(delay)
        end
    end

    return lastTween
end

function GuiUtil:getPropertiesBridgingGap(Point1, Point2)
    --[[
        input: vector2's
        
        calculates the properties a gui Object needs to fill the gap between Point1 and Point2

        returns: position = Udim2, Rotation = int, length = int
    ]]
    local connectingVector = Point2 - Point1
    local flatVector = Vector2.new(connectingVector.X, 0)
    
    local length = connectingVector.Magnitude
    local position = Point1 + (connectingVector * 0.5)
    position = UDim2.new(0, position.X, 0, position.Y) -- converting to Udim

    -- calculating inverse since magnitude gets rid of negatives, 1 or -1
    local inverse = (connectingVector.X / math.abs(connectingVector.X)) * (connectingVector.Y / math.abs(connectingVector.Y)) 
    local rotation = math.deg(math.acos(flatVector.Magnitude/connectingVector.Magnitude)) * inverse

    return position, rotation, length
end

function GuiUtil:absuluteRotation(degrees)
    --[[
        input: int, gui rotation degrees
        returns: degrees converted to 1-360
    ]]
    return degrees%360
end

function GuiUtil:rotateAroundAnchorPoint(gui, endRotation, zeroDegPos, originalAnchorPoint)
    --[[
        input: gui = GuiObject, endRotation = int, desired rotation in degrees zeroDegPos = Udim2, .Position of gui (relative to parent) originalAnchorPoint = Vector2, original anchor point of gui at zero degree
        rotates gui around its anchor point instead of center
        
        NOTE: Anchor point will be changed to 0.5,0.5

        returns: Position = Udim2, Scale, Rotation = int
    ]]

    -- turning into offset but storing as vector 2 to preserve decimals
    zeroDegPos = Vector2.new((zeroDegPos.X.Scale * gui.Parent.AbsoluteSize.X) + zeroDegPos.X.Offset, (zeroDegPos.Y.Scale * gui.Parent.AbsoluteSize.Y) + zeroDegPos.Y.Offset)
    
    -- adding center offset to find innitial vector from parent 0,0 to zerodegPos center pos in offset
    local aVector = Vector2.new((0.5 - originalAnchorPoint.X)*gui.AbsoluteSize.X, (0.5 - originalAnchorPoint.Y)*gui.AbsoluteSize.Y)
    endRotation = self:absuluteRotation(endRotation) -- endRotation converted to 1-360
    endRotation -= endRotation > 180 and 360 or 0 -- converting to -180 to 180
    endRotation = endRotation
    local cosR = math.cos(math.rad(endRotation)) -- cos(endRotation)

    -- no rotation needed
    if endRotation == 0 then
        return gui.Position, gui.Rotation
    end

    -- variables for algebra
    local r = aVector.Magnitude -- radius of circle created by all possible points when rotating around anchorPOint
    local m = aVector.X -- Starting x
    local n = aVector.Y -- starting Y
    local S = r^2 * cosR -- rounded Scalar product
    
    -- graph for equations: https://www.desmos.com/calculator/fhimjcusr4

    -- n>0 and positive rotation, n<0 and negative rotation
    local x1 = (m*S - math.sqrt( n^2*(m^2 * r^2 + n^2 * r^2 - S^2)) ) / (m^2 + n^2) -- rounding since Udim2 offset is automaticly floored
    local y1 = (n^2 * S + m * math.sqrt( n^2 * (m^2 * r^2 + n^2 * r^2 - S^2)) ) / (m^2 * n + n^3)

    -- n>0 and negative rotation, n<0 and positive rotation
    local x2 = (m*S + math.sqrt( n^2*(m^2 * r^2 + n^2 * r^2 - S^2)) ) / (m^2 + n^2)
    local y2 = (n^2 * S - m * math.sqrt( n^2 * (m^2 * r^2 + n^2 * r^2 - S^2)) ) / (m^2 * n + n^3) 

    -- equation for when n = 0 (inverted so it does not devide by 0)

    -- m>0 and positive rotation, m<0 and negative rotation
    local x3 = (m^2 * S - n * math.sqrt( m^2 * (n^2 * r^2 + m^2 * r^2 - S^2)) ) / (n^2 * m + m^3)
    local y3 = (n*S + math.sqrt( m^2*(n^2 * r^2 + m^2 * r^2 - S^2)) ) / (n^2 + m^2)

    -- m>0 and negative rotation, m<0 and positive rotation
    local x4 = (m^2 * S + n * math.sqrt( m^2 * (n^2 * r^2 + m^2 * r^2 - S^2)) ) / (n^2 * m + m^3) 
    local y4 = (n*S - math.sqrt( m^2*(n^2 * r^2 + m^2 * r^2 - S^2)) ) / (n^2 + m^2)

    gui.AnchorPoint = Vector2.new(0.5,0.5)
    if r == 0 then -- Center Pos is on parent pos, only needs to rotate dont need repositioning
        local pos = zeroDegPos
        return UDim2.new((pos.X / gui.Parent.AbsoluteSize.X), 0, (pos.Y / gui.Parent.AbsoluteSize.Y), 0), endRotation        
    end

    -- check if inverted equation needed
    if n == 0 then
        if (m>0 and endRotation > 0) or (m<0 and endRotation<0) then
            -- x3: m>0 and positive rotation, m<0 and negative rotation
            local pos = Vector2.new(x3,y3) + zeroDegPos
            return UDim2.new((pos.X / gui.Parent.AbsoluteSize.X), 0, (pos.Y / gui.Parent.AbsoluteSize.Y), 0), endRotation  
        else
            -- x4: m>0 and negative rotation, m<0 and positive rotation
            local pos = Vector2.new(x4,y4) + zeroDegPos
            return UDim2.new((pos.X / gui.Parent.AbsoluteSize.X), 0, (pos.Y / gui.Parent.AbsoluteSize.Y), 0), endRotation  
        end
    end

    -- normal equations
    if (n>0 and endRotation > 0) or (n<0 and endRotation<0) then
        -- x1: n>0 and positive rotation, n<0 and negative rotation
        local pos = Vector2.new(x1,y1) + zeroDegPos
        return UDim2.new((pos.X / gui.Parent.AbsoluteSize.X), 0, (pos.Y / gui.Parent.AbsoluteSize.Y), 0), endRotation 
    else
        -- x2: n>0 and negative rotation, n<0 and positive rotation
        local pos = Vector2.new(x2,y2) + zeroDegPos
        return UDim2.new((pos.X / gui.Parent.AbsoluteSize.X), 0, (pos.Y / gui.Parent.AbsoluteSize.Y), 0), endRotation 
    end
end

return GuiUtil