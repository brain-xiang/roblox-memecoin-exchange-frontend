return function()
    local GuiUtil = require(script.Parent.GuiUtil)
    
    describe("getChildrenOfClass", function()
        it("Should return all children of specified className", function()
            local ScreenGui = Instance.new("ScreenGui")
            local ImageButton1 = Instance.new("ImageButton", ScreenGui)
            local ImageButton2 = Instance.new("ImageButton", ScreenGui)
            local TextButton = Instance.new("TextButton", ScreenGui)

            local childrenOfClass = GuiUtil:getChildrenOfClass(ScreenGui, "ImageButton")
            expect(#childrenOfClass).to.equal(2)
            expect(childrenOfClass[1].ClassName).to.equal("ImageButton")
        end)
    end)

    describe("fadeIn", function()
        it("should fade in gui to correct transparencies", function()
            local ScreenGui = Instance.new("ScreenGui")
            local ImageButton1 = Instance.new("ImageButton", ScreenGui)
            local TextButton = Instance.new("TextButton", ScreenGui)

            local BackgroundT = 1
            local ImageT = 0.75
            local TextT = 0

            ImageButton1.ImageTransparency = ImageT
            ImageButton1.BackgroundTransparency = BackgroundT
            TextButton.TextTransparency = TextT

            local tween = GuiUtil:fadeIn(ScreenGui, 2)
            tween.Completed:Wait()

            expect(math.floor(ImageButton1.ImageTransparency *100 + 0.5)).to.equal(ImageT*100)
            expect(math.floor(ImageButton1.BackgroundTransparency *100 + 0.5)).to.equal(BackgroundT*100)
            expect(math.floor(TextButton.TextTransparency *100 + 0.5)).to.equal(TextT*100)
        end)
    end)
end