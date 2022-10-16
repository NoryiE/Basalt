local Object = require("Object")
local xmlValue = require("utils").getValueFromXML
local images = require("images")
local log = require("basaltLogs")

local unpack,sub = table.unpack,string.sub
return function(name)
    -- Image
    local base = Object(name)
    local objectType = "Image"
    base:setZIndex(2)
    local originalImage
    local image
    local curFrame = 1
    local infinitePlay = false
    local animTimer

    base.width = 24
    base.height = 8

    local object = {
        init = function(self)
            if(base.init(self))then
                self.bgColor = self.parent:getTheme("ImageBG")
            end
        end,
        getType = function(self)
            return objectType
        end;

        loadImage = function(self, path, f)
            if not(fs.exists(path))then error("No valid path: "..path) end
            originalImage = images.loadImageAsBimg(path, f)
            curFrame = 1
            image = originalImage
            self:updateDraw()
            return self
        end;

        play = function(self, inf)
            if(originalImage.animated)then
                local t = originalImage[curFrame].duration or originalImage.secondsPerFrame or 0.2
                self.parent:addEvent("other_event", self)
                animTimer = os.startTimer(t)
                infinitePlay = inf or false
            end
            return self
        end,

        selectFrame = function(self, fr)
            if(originalImage[fr]~=nil)then
                curFrame = fr
                if(animTimer~=nil)then
                    os.cancelTimer(animTimer)
                end
                self:updateDraw()
            end
        end,

        eventHandler = function(self, event, timerId, ...)
            base.eventHandler(self, event, timerId, ...)
            if(event=="timer")then
                if(timerId==animTimer)then
                    if(originalImage[curFrame+1]~=nil)then
                        curFrame = curFrame + 1
                        local t = originalImage[curFrame].duration or originalImage.secondsPerFrame or 0.2
                        animTimer = os.startTimer(t)
                    else
                        if(infinitePlay)then
                            curFrame = 1
                            local t = originalImage[curFrame].duration or originalImage.secondsPerFrame or 0.2
                            animTimer = os.startTimer(t)
                        end
                    end
                    self:updateDraw()
                end
            end
        end,

        getMetadata = function(self, key)
            return originalImage[key]
        end,

        setImage = function(self, data)
            originalImage = data
            image = originalImage
            curFrame = 1
            if(animTimer~=nil)then
                os.cancelTimer(animTimer)
            end
            self:updateDraw()
        end,

        getImageSize = function(self)
            return originalImage.width, originalImage.height
        end,

        resizeImage = function(self, w, h)
            image = images.resizeBIMG(originalImage, w, h)
            self:updateDraw()
            return self
        end,

        setValuesByXMLData = function(self, data)
            base.setValuesByXMLData(self, data)
            if(xmlValue("path", data)~=nil)then self:loadImage(xmlValue("path", data)) end
            return self
        end,

        draw = function(self)
            if (base.draw(self)) then
                if (image ~= nil) then
                    local obx, oby = self:getAnchorPosition()
                    local w,h = self:getSize()
                    for y,v in ipairs(image[curFrame])do
                        log(unpack(v))
                        local t, f, b  = unpack(v)
                        t = sub(t, 1,w)
                        f = sub(f, 1,w)
                        b = sub(b, 1,w)
                        self.parent:blit(obx, oby+y-1, t, f, b)
                        if(y==h)then break end
                    end
                end
            end
        end,
    }

    return setmetatable(object, base)
end