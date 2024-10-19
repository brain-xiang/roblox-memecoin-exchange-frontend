return function()
    Robi = require(script.Parent.Main)
    describe("create", function()
        it("constructing using the same class multiple times should not inteffere", function()
            local store = {
                object1 = Robi.create({Instance.new("ImageButton")}, {require(script.TestClass)}),
                object2 = Robi.create({Instance.new("ImageButton")}, {require(script.TestClass)})
            }
            Robi:run(store)
            wait() -- waiting for run to complete
            
            store.object1.states.a = 5 
            expect(store.object1.states.mutationCount).to.equal(1)
        end)

        it("Shortcut 1", function()
            expect(function()
                Robi.create(Instance.new("ImageButton"), require(script.TestClass))
            end).never.to.throw()
        end)

        it("Shortcut 2", function()
            expect(function()
                Robi.create(Instance.new("ImageButton"), {
                    require(script.TestClass),
                    require(script.TestClass2),
                })
            end).never.to.throw()
        end)

        it("Should parse properties to the classes", function()
            local store = {
                object1 = Robi.create({Instance.new("ImageButton")}, {
                    [require(script.TestClass)] = {"Properties", "Passed"},
                }),
            }

            expect(store.object1.states.properties[1]).to.equal("Properties")
            expect(store.object1.states.properties[2]).to.equal("Passed")
        end)
    end)

    describe("createGroup", function()
        it("Should return a group(table) of identical objects made from diffrent elements", function()
            local store = {
                group = Robi.createGroup({Instance.new("ImageButton"), Instance.new("ImageLabel")}, {require(script.TestClass)})
            }
            Robi:run(store)
            wait() -- waiting for run to complete

            expect(store.group.ImageButton.states.a).to.equal(store.group.ImageLabel.states.a)
            expect(store.group.ImageButton.element).never.to.equal(store.group.ImageLabel.element)
        end)
    end)

    describe("State changing", function()
        it("state changes should be visible in class code", function()
            local store = {
                object1 = Robi.create({Instance.new("ImageButton")}, {require(script.TestClass)})
            }
            Robi:run(store)
            wait() -- waiting for run to complete

            store.object1.states.a = 5 
            expect(store.object1.states.mutationCount).to.equal(1)
        end)
        it("modify and detect state change within same object", function()
            local store ={
                object1 = Robi.create({Instance.new("ImageButton")}, {require(script.TestClass), require(script.TestClass2)})
            }
            Robi:run(store)
            wait() -- waiting for run to complete

            store.object1.states.c = 5 
            expect(store.object1.states.mutationCount).to.equal(1)
        end)
        it("modify and detect state changes with other objects", function()
            local store = {
                object1 = Robi.create({Instance.new("ImageButton")}, {require(script.TestClass)}),
                object2 = Robi.create({Instance.new("ImageButton")}, {require(script.TestClass2)})
            }
            Robi:run(store)
            wait() -- waiting for run to complete

            expect(store.object1.states.mutationCount).to.equal(1)
            expect(store.object1.states.a).to.equal("Changed by Object2")
        end)
    end)
end