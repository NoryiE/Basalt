local Object = require("Object")
local utils = require("utils")
local xmlValue = utils.getValueFromXML

return function(name)
    -- Input
    local base = Object(name)
    local objectType = "Input"

    local inputType = "text"
    local inputLimit = 0
    base:setZIndex(5)
    base:setValue("")
    base.width = 10
    base.height = 1

    local textX = 1
    local wIndex = 1

    local defaultText = ""
    local defaultBGCol
    local defaultFGCol
    local showingText = defaultText
    local internalValueChange = false

    local object = {
        getType = function(self)
            return objectType
        end;

        setInputType = function(self, iType)
            if (iType == "password") or (iType == "number") or (iType == "text") then
                inputType = iType
            end
            return self
        end;

        setDefaultText = function(self, text, fCol, bCol)
            defaultText = text
            defaultBGCol = bCol or defaultBGCol
            defaultFGCol = fCol or defaultFGCol
            if (self:isFocused()) then
                showingText = ""
            else
                showingText = defaultText
            end
            return self
        end;

        getInputType = function(self)
            return inputType
        end;

        setValue = function(self, val)
            base.setValue(self, tostring(val))
            if not (internalValueChange) then
                textX = tostring(val):len() + 1
            end
            return self
        end;

        getValue = function(self)
            local val = base.getValue(self)
            return inputType == "number" and tonumber(val) or val
        end;

        setInputLimit = function(self, limit)
            inputLimit = tonumber(limit) or inputLimit
            return self
        end;

        getInputLimit = function(self)
            return inputLimit
        end;

        setValuesByXMLData = function(self, data)
            base.setValuesByXMLData(self, data)
            local dBG,dFG
            if(xmlValue("defaultBG", data)~=nil)then dBG = xmlValue("defaultBG", data) end
            if(xmlValue("defaultFG", data)~=nil)then dFG = xmlValue("defaultFG", data) end
            if(xmlValue("default", data)~=nil)then self:setDefaultText(xmlValue("default", data), dFG~=nil and colors[dFG], dBG~=nil and colors[dBG]) end
            if(xmlValue("limit", data)~=nil)then self:setInputLimit(xmlValue("limit", data)) end
            if(xmlValue("type", data)~=nil)then self:setInputType(xmlValue("type", data)) end
            return self
        end,

        getFocusHandler = function(self)
            base.getFocusHandler(self)
            if (self.parent ~= nil) then
                local obx, oby = self:getAnchorPosition()
                showingText = ""
                if (self.parent ~= nil) then
                    self.parent:setCursor(true, obx + textX - wIndex, oby+math.floor(self.height/2), self.fgColor)
                end
            end
        end;

        loseFocusHandler = function(self)
            base.loseFocusHandler(self)
            if (self.parent ~= nil) then
                self.parent:setCursor(false)
                showingText = defaultText
            end
        end;

        keyHandler = function(self, key)
            if (base.keyHandler(self, key)) then
                local w,h = self:getSize()
                internalValueChange = true
                    if (key == keys.backspace) then
                        -- on backspace
                        local text = tostring(base.getValue())
                        if (textX > 1) then
                            self:setValue(text:sub(1, textX - 2) .. text:sub(textX, text:len()))
                            if (textX > 1) then
                                textX = textX - 1
                            end
                            if (wIndex > 1) then
                                if (textX < wIndex) then
                                    wIndex = wIndex - 1
                                end
                            end
                        end
                    end
                    if (key == keys.enter) then
                        -- on enter
                        if (self.parent ~= nil) then
                            --self.parent:removeFocusedObject(self)
                        end
                    end
                    if (key == keys.right) then
                        -- right arrow
                        local tLength = tostring(base.getValue()):len()
                        textX = textX + 1

                        if (textX > tLength) then
                            textX = tLength + 1
                        end
                        if (textX < 1) then
                            textX = 1
                        end
                        if (textX < wIndex) or (textX >= w + wIndex) then
                            wIndex = textX - w + 1
                        end
                        if (wIndex < 1) then
                            wIndex = 1
                        end
                    end

                    if (key == keys.left) then
                        -- left arrow
                        textX = textX - 1
                        if (textX >= 1) then
                            if (textX < wIndex) or (textX >= w + wIndex) then
                                wIndex = textX
                            end
                        end
                        if (textX < 1) then
                            textX = 1
                        end
                        if (wIndex < 1) then
                            wIndex = 1
                        end
                    end
                local obx, oby = self:getAnchorPosition()
                local val = tostring(base.getValue())
                local cursorX = (textX <= val:len() and textX - 1 or val:len()) - (wIndex - 1)

                if (cursorX > self.x + w - 1) then
                    cursorX = self.x + w - 1
                end
                if (self.parent ~= nil) then
                    self.parent:setCursor(true, obx + cursorX, oby+math.floor(h/2), self.fgColor)
                end
                internalValueChange = false
                return true
            end
            return false
        end,

        charHandler = function(self, char)
            if (base.charHandler(self, char)) then
                internalValueChange = true
                local w,h = self:getSize()
                local text = base.getValue()
                if (text:len() < inputLimit or inputLimit <= 0) then
                    if (inputType == "number") then
                        local cache = text
                        if (char == ".") or (tonumber(char) ~= nil) then
                            self:setValue(text:sub(1, textX - 1) .. char .. text:sub(textX, text:len()))
                            textX = textX + 1
                        end
                        if (tonumber(base.getValue()) == nil) then
                            self:setValue(cache)
                        end
                    else
                        self:setValue(text:sub(1, textX - 1) .. char .. text:sub(textX, text:len()))
                        textX = textX + 1
                    end
                    if (textX >= w + wIndex) then
                        wIndex = wIndex + 1
                    end
                end
                local obx, oby = self:getAnchorPosition()
                local val = tostring(base.getValue())
                local cursorX = (textX <= val:len() and textX - 1 or val:len()) - (wIndex - 1)

                if (cursorX > self.x + w - 1) then
                    cursorX = self.x + w - 1
                end
                if (self.parent ~= nil) then
                    self.parent:setCursor(true, obx + cursorX, oby+math.floor(h/2), self.fgColor)
                end
                internalValueChange = false
                return true
            end
            return false
        end,

        draw = function(self)
            if (base.draw(self)) then
                if (self.parent ~= nil) then
                    local obx, oby = self:getAnchorPosition()
                    local w,h = self:getSize()
                    local verticalAlign = utils.getTextVerticalAlign(h, "center")

                    if(self.bgColor~=false)then self.parent:drawBackgroundBox(obx, oby, w, h, self.bgColor) end
                    for n = 1, h do
                        if (n == verticalAlign) then
                            local val = tostring(base.getValue())
                            local bCol = self.bgColor
                            local fCol = self.fgColor
                            local text
                            if (val:len() <= 0) then
                                text = showingText
                                bCol = defaultBGCol or bCol
                                fCol = defaultFGCol or fCol
                            end

                            text = showingText
                            if (val ~= "") then
                                text = val
                            end
                            text = text:sub(wIndex, w + wIndex - 1)
                            local space = w - text:len()
                            if (space < 0) then
                                space = 0
                            end
                            if (inputType == "password") and (val ~= "") then
                                text = string.rep("*", text:len())
                            end
                            text = text .. string.rep(" ", space)
                            self.parent:writeText(obx, oby + (n - 1), text, bCol, fCol)
                        end
                    end
                end
            end
        end,

        init = function(self)
            self.bgColor = self.parent:getTheme("InputBG")
            self.fgColor = self.parent:getTheme("InputText")
            if(self.parent~=nil)then
                self.parent:addEvent("mouse_click", self)
                self.parent:addEvent("key", self)
                self.parent:addEvent("char", self)
            end
        end,
    }

    return setmetatable(object, base)
end