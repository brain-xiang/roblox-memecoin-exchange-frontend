--[[
Class Template - Legenderox
November 30, 2020

Class Description:

]]


local Class = {}
Class.__index = Class

Class.defaultStates = {
    d = 3,
    c = 3,
}

Class.TYPE_REQUIREMENT = nil -- Required elment type, nil = all*

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

	if self.store.object1 then
		self.store.object1.states.a = "Changed by Object2"
	end
end

function Class.setup(element, states, ...)
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

	return self
end

function Class:Init()
    --[[
		Method used for AGF Access 
	]]
end

return Class