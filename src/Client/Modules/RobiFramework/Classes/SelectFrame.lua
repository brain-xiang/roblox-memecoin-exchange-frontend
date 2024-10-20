--[[
Class Template - Legenderox
November 30, 2020

Class Description:

]]

--------------------
-- ROBI VARAIBLES --
--------------------

local Class = {}
Class.__index = Class

Class.defaultStates = {
	selected = "", --- set default
	selectedColorVal = 140/255,
	unselectedColorVal = 255/255,
}

Class.TYPE_REQUIREMENT = nil -- should be a frame containing image buttons

--------------
-- VARIABLES--
--------------


---------------
-- FUNCTIONS --
---------------

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

	for i,button in pairs(self.element:GetChildren()) do
		if button:IsA("GuiButton") then
			button.MouseButton1Down:Connect(function()
				self.states.selected = button.Name
			end)
		end
	end

	self.states:GetPropertyChangedSignal("selected"):Connect(function(old, new)
		if new then
			for i,button in pairs(self.element:GetChildren()) do
				if button:IsA("GuiButton") then
					if button.Name == new then
						local hue, sat, val = button.ImageColor3:ToHSV()
						button.ImageColor3 = Color3.fromHSV(hue, sat, self.states.selectedColorVal)
					else
						local hue, sat, val = button.ImageColor3:ToHSV()
						button.ImageColor3 = Color3.fromHSV(hue, sat, self.states.unselectedColorVal)
					end
				end
			end 
		end
	end)
end

function Class.setup(element, states, default)
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
	self.maid = Maid.new()
	self.destroyed = false

	self.states.selected = default or ""

	return self
end

function Class:Init()
    --[[
		Method used for AGF Access 
	]]
	Maid = self.Shared.Maid
end

return Class