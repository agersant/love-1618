_G.love = love or {};

local diff = function(actual, expected)
    local sameWidth = expected:getWidth() == actual:getWidth();
    local sameHeight = expected:getHeight() == actual:getHeight();
    local badPixel;
    if sameWidth and sameHeight then
        for y = 0, actual:getHeight() - 1 do
            for x = 0, actual:getWidth() - 1 do
                if not badPixel then
                    local expectedColor = {expected:getPixel(x, y)};
                    local actualColor = {actual:getPixel(x, y)};
                    for i = 1, 4 do
                        if math.abs(expectedColor[i] - actualColor[i]) * 255 > 1 then
                            badPixel = {
                                x = x,
                                y = y,
                                expected = expectedColor,
                                actual = actualColor
                            };
                        end
                    end
                end
            end
        end
    end
    local identical = sameWidth and sameHeight and not badPixel;
    return identical, badPixel;
end

local capture = function()
    local screenshot;
    love.graphics.captureScreenshot(function(imageData)
        screenshot = imageData;
    end);
    love.graphics.present();
    return screenshot;
end

local save = function(image, name)
    local file = io.open(name, "wb+");
    file:write(image:encode("png"):getString());
    file:close();
end

local draw = function(shape, alpha)
    love.graphics.clear(love.graphics.getBackgroundColor());
    love.graphics.setColor({0 / 255, 234 / 255, 255 / 255, alpha});
    if shape == "disk" then
        love.graphics.circle("fill", 40, 40, 10, 16);
    elseif shape == "circle" then
        love.graphics.circle("line", 40, 40, 10, 16);
    elseif shape == "square" then
        love.graphics.rectangle("fill", 30, 30, 20, 20);
    end
end

local success = true;
local runTest = function(renderTarget, shape, alpha)

    local testName = string.format("%s-%s-%.2f", renderTarget, shape, alpha);

    local actual;
    if renderTarget == "canvas" then
        local canvas = love.graphics.newCanvas(love.graphics.getPixelWidth(),
                                               love.graphics.getPixelHeight());
        love.graphics.setCanvas(canvas);
        draw(shape, alpha);
        love.graphics.setCanvas();
        actual = canvas:newImageData();
    elseif renderTarget == "backbuffer" then
        draw(shape, alpha);
        actual = capture();
    end

    local expected = love.image.newImageData(
                         string.format("expected/expected-%s.png", testName));
    local identical, badPixel = diff(actual, expected);
    success = success and identical and not badPixel;
    print("\nTest case: " .. testName)
    print("\tidentical: ", identical);

    save(actual, string.format("actual-%s.png", testName));

    if badPixel then
        print(string.format(
                  "\tPixel at (x: %d, y: %d) is (R: %f, G: %f, B: %f, A: %f) but should be (R: %f, G: %f, B: %f, A: %f)",
                  badPixel.x, badPixel.y, badPixel.actual[1],
                  badPixel.actual[2], badPixel.actual[3], badPixel.actual[4],
                  badPixel.expected[1], badPixel.expected[2],
                  badPixel.expected[3], badPixel.expected[4]));
    end
end

local numAlphaSteps = 5;
for _, renderTarget in ipairs({"canvas", "backbuffer"}) do
    for alpha = 1, numAlphaSteps do
        for _, shape in ipairs({"disk", "circle", "square"}) do
            runTest(renderTarget, shape, alpha / numAlphaSteps);
        end
    end
end

love.event.quit(success and 0 or 1);

