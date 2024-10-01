Input objects allow you to create a field where the user can enter text.

Input objects are derived from Object, VisualObject, and ChangeableObject. Input objects have the following additional methods:

|   |   |
|---|---|
|[setInputType](objects/Input/setInputType.md)|Sets the input type
|[getInputType](objects/Input/getInputType.md)|Returns the input type
|[setDefaultText](objects/Input/setDefaultText.md)|Sets the default text
|[setInputLimit](objects/Input/setInputLimit.md)|Sets a limit to the number of characters that can be entered
|[getInputLimit](objects/Input/getInputLimit.md)|Returns the character limit
|[setOffset](objects/Input/setOffset.md)|Changes the offset inside the input
|[getOffset](objects/Input/getOffset.md)|Returns the input offset
|[setTextOffset](objects/Input/setTextOffset.md)|Changes the cursor position
|[getTextOffset](objects/Input/getTextOffset.md)|Returns the cursor position

Here's an example of how to create an Input object and set its properties:

Lua:

```lua
local main = basalt.createFrame()
local anInput = main:addInput()
anInput:setInputType("text")
anInput:setDefaultText("Username")
anInput:setInputLimit(20)
```

XML:

```xml
<input type="text" defaultText="Username" inputLimit="20" />
```
