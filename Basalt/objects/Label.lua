local VisualObject = require("VisualObject")
local utils = require("utils")
local createText = utils.createText
local tHex = require("tHex")

return function(name)
    -- Label
    local base = VisualObject(name)
    local objectType = "Label"

    base:setZIndex(3)

    local autoSize = true
    local fgColChanged,bgColChanged = false,false
    local text = "Label"

    local object = {
        getType = function(self)
            return objectType
        end,

        getBase = function(self)
            return base
        end,    
        
        setText = function(self, newText)
            text = tostring(newText)
            if(autoSize)then
                self:setSize(#text, 1)
            end
            self:updateDraw()
            return self
        end,

        getText = function(self)
            return text
        end,

        setBackground = function(self, col)
            base.setBackground(self, col)
            bgColChanged = true
            return self
        end,

        setForeground = function(self, col)
            base.setForeground(self, col)
            fgColChanged = true
            return self
        end,

        setSize = function(self, ...)
            base.setSize(self, ...)
            autoSize = false
            return self
        end,

        draw = function(self)
            base.draw(self)
            self:addDraw("label", function()
                local parent = self:getParent()
                local obx, oby = self:getPosition()
                local w,h = self:getSize()
                local bgCol,fgCol = self:getBackground(), self:getForeground()
                local verticalAlign = utils.getTextVerticalAlign(h, textVerticalAlign)
                if not(autoSize)then
                    local text = createText(text, w)
                    for k,v in pairs(text)do
                        if(k<=h)then
                            parent:setText(obx, oby+k-1, v)
                        end
                    end
                else
                    if(#text+obx>parent:getWidth())then
                        local text = createText(text, w)
                        for k,v in pairs(text)do
                            if(k<=h)then
                                parent:setText(obx, oby+k-1, v)
                            end
                        end
                    else
                        parent:setText(obx, oby, text:sub(1,w))
                    end
                end
            end)
        end,
        
        init = function(self)
            if(base.init(self))then
                local parent = self:getParent()
                self:setBackground(parent:getTheme("LabelBG"))
                self:setForeground(parent:getTheme("LabelText"))
                if(parent:getBackground()==colors.black)and(self:getBackground()==colors.black)then
                    self:setForeground(colors.lightGray)
                end
            end
        end

    }

    object.__index = object
    return setmetatable(object, base)
end