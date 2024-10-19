-- Main
-- Username
-- November 30, 2020


local Main = {}
Main.__index = Main
local EventModule = require(game.ReplicatedStorage.Aero.Shared.EventModule)

------------------
-- CONSTRUCTORS --
------------------

function Main.create(elements, classes)
	--[[
		input: elements = Table of or one Gui Element, classes = dictionary, Key: Class Table, Value: tbl, properties

		Example:
			RobiObject = Robi.Create(elements, {
				[Class table] = {properties passed}
			})
		Shortcuts: 
			1. to pass only "one" class without properties -> classes = Class table
			2. to pass classes without properteis just have the class table as value and leave the index numeric
				Example:
					RobiObject = Robi.Create(elements, {
						ClassTable1,
						ClassTable2,
					})

		Object Hiarchy:
			Object = {
				element/elements = GuiObject or {GuiObjects}
				classes = {
					ElementName = {classes}
				}
				states = {Combined States*}
			}
	]]
	if typeof(classes) == "Instance" then error("Robi.create(classes) input does not accept (".. classes.Name..") Instance. Should be: require(Module)") return end
	for i,v in pairs(classes) do
		if typeof(i) == "Instance" then error("Robi.create(classes) input does not accept (".. i.Name..") Instance. Should be: require(Module)") return end
		if typeof(v) == "Instance" then error("Robi.create(classes) input does not accept (".. v.Name..") Instance. Should be: require(Module)") return end
	end

	local self = setmetatable({}, Main)
	
	-- elements or element
	elements = typeof(elements) == "table" and elements or {elements}
	if #elements > 1 then
		self.elements = elements
	else
		self.element = elements[1]
	end
	
	-- Combining states
	self.states = EventModule.new()
	classes = classes.__index and {classes} or classes -- Shortcut 1
	for i,v in pairs(classes) do
		local class = typeof(i) == "number" and v or i -- Shortcut 2

		for k,state in pairs(class.defaultStates) do
			if not self.states[k] then
				state = typeof(state) == "table" and TableUtil.Copy(state) or state
				self.states[k] = state
			else
				error("Passed classes have duplicate state names")
			end
		end
	end
	
	-- invoking classes' setup method
	self.classes = {}
	for k,element in pairs(elements) do
		self.classes[element.name] = {}
		for i,v in pairs(classes) do
			if typeof(i) == "number" then
				local class = v
				table.insert(self.classes[element.name], class.setup(element, self.states)) -- Shortcut 2
			else
				local class = i
				class = class.setup(element, self.states, unpack(v))
				table.insert(self.classes[element.name], class)
			end
			
		end
	end

	return self
end

function Main.createGroup(elements, classes)
	--[[
		input: elements = tbl of "elements" passed into create ("elements" can be instance or table of elements)	
		returns a table of objects created with using the classes for each class
	]]
	local group = {}
	for i,element in pairs(elements) do
		group[element.Name] = Main.create(element, classes)
	end
	return group
end

function Main:run(store, objects)
	--[[
		input: store = tbl of Robi Objects or single Object, objects = objects which are run, if nil then just runns entire store

		Asynchronously invokes the :run() method of the classes in the store
	]]

	objects = self.classes and {self} or (objects or store)
	objects = objects.classes and {objects} or objects
	for i,object in pairs(objects) do
		if object.classes then
			for k,class in pairs(self:getClasses(object)) do
				spawn(function()
					class:run(store)
				end)
			end
		elseif typeof(object) == "table" then
			self:run(store, object)
		else
			error("Error occurred when running this store.")
		end	
	end
end

-------------
-- METHODS --
-------------

function Main:Disconnect()
	--[[
		Disconnects all classes and cleans up connections
		returns: elements
	]]
	local activeClasses = self:getClasses()
	for i,class in pairs(activeClasses) do
		if class.maid then
			class.maid:Destroy()
		end
		class.destroyed = true
	end

	self.states:Destroy()
	return self.element or self.elements
end

function Main:Destroy()
	--[[
		self:Disconnect(), and destroys all elements
		returns: nil
	]]
	
	local elements = self:Disconnect()
	if typeof(elements) == "table" then
		for i,element in pairs(elements) do
			element:Destroy()
		end
		return nil
	end
	elements:Destroy()
	return nil
end

function Main:getClasses(object)
	--[[
		input: Robi Object
		returns: All activated classes in Robi object (including duplicate classes for diffrent elements)
	]]

	object = object or self
	local allClasses = {}
	for elementName, classes in pairs(object.classes) do
		for k, class in pairs(classes) do
			table.insert(allClasses, class)
		end
	end

	return allClasses
end

return Main