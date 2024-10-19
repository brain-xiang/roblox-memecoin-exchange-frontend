-- 

--[[
Class Template - Legenderox
November 30, 2020

Class Description:

	Executes diffrent hover effects on the element.HoverFrame. 
	Effect can be specified in states.hoverEffect using another acompanying class (default: "FadeFrame")

	FadeFrame:

		requirements: HoverFrame = Frame
		
		Fades HoverFrame and its descendants' BackgroundTransparency

	HoverSize:

		requirements: HoverFrame = have Size property*

		Increases the HoverFrame's size when hovered
]]

			

local Class = {}
Class.__index = Class

Class.defaultStates = {
	hovered = false, 
	hoverActive = true, -- is the button.MouseHovered event active
	hoverEffect = "FadeFrame",
}

Class.TYPE_REQUIREMENT = "GuiButton" -- Required elment type, nil = all*

local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

function Class.FadeFrame(self, bool)
	if bool then
		local tween = TweenService:Create(self.HoverFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0})
		tween:Play()
	else
		local tween = TweenService:Create(self.HoverFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1})
		tween:Play()
	end
end

function Class.HoverSize(self, bool)
	if bool then
		local newSize = UDim2.new(self.hoverFrameProperties.Size.X.Scale * 1.2, 0, self.hoverFrameProperties.Size.Y.Scale * 1.2, 0)
		local tween = TweenService:Create(self.HoverFrame, TweenInfo.new(0.25), {Size = newSize})
		tween:Play()
	else
		local tween = TweenService:Create(self.HoverFrame, TweenInfo.new(0.25), {Size = self.hoverFrameProperties.Size})
		tween:Play()
	end
end

-------------
-- METHODS --
-------------

function Class:run(store)
	--[[
		input: element = GuiObject, states = Robi objects state, store = Robi store where object is located

		Method invoked asynchronously (at the same time)
		Used to run evetns and main functionalities, access to all states and store

		returns: self
	]]
	self.store = store
	
	self.states:GetPropertyChangedSignal("hovered"):Connect(function(old, new)
		self[self.states.hoverEffect](self, new)
	end)
	self.element.MouseEnter:Connect(function(x,y)
		if self.states.hoverActive then
			self.states.hovered = true
		end
	end)
	self.element.MouseLeave:Connect(function(x,y)
		if self.states.hoverActive then
			self.states.hovered = false
		end
	end)

	self.states:GetPropertyChangedSignal("hoverActive"):Connect(function(old, new)
		if new then
			local currentlyHovvering = player.PlayerGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y)
			local elementFound = false
			for i,gui in pairs(currentlyHovvering) do
				if gui == self.element then
					elementFound = true
					break
				end
			end
			self.states.hovered = elementFound
		end
	end)
end

function Class.setup(element, states)
	--[[
		input: element = GuiObject, states = Robi objects state

		Method invoked one-by-one synchronously
		Used to setup gui, states and object, Only access to local states

		returns: self
	]]
	local self = setmetatable({}, Class)
	if self.TYPE_REQUIREMENT and not element:IsA(self.TYPE_REQUIREMENT) then error(element.Name.. "(Element) does not match this class's TYPE_REQUIREMENT") end

	self.element = element
	self.states = states
	self.HoverFrame = element.HoverFrame
	if not self.HoverFrame then error("[Robi] HoverButton Class was applied on: ".. element.Name.. "(Element) which did not have element.HoverFrame") end
	self.hoverFrameProperties = { -- Saving default hover Frame properties for easier tweening
		Size = self.HoverFrame.Size,
	}

	return self
end

function Class:Init()
	 --[[
		Method used for AGF Access 
	]]
	GuiUtil = self.Modules.GuiUtil
end

return Class