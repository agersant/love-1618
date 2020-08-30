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

local draw = function(fill, line)
    love.graphics.clear(love.graphics.getBackgroundColor());
    if fill then
        love.graphics.setColor({0 / 255, 234 / 255, 255 / 255, 0.6});
        love.graphics.circle("fill", 40, 40, 10, 16);
    end
    if line then
        love.graphics.setColor({0 / 255, 234 / 255, 255 / 255});
        love.graphics.circle("line", 40, 40, 10, 16);
    end
end

local success = true;
local runTest = function(renderTarget, fill, line)
    local actual;
    if renderTarget == "canvas" then
        local canvas = love.graphics.newCanvas(love.graphics.getPixelWidth(),
                                               love.graphics.getPixelHeight());
        love.graphics.setCanvas(canvas);
        draw(fill, line);
        love.graphics.setCanvas();
        actual = canvas:newImageData();
    elseif renderTarget == "backbuffer" then
        draw(fill, line);
        actual = capture();
    end

    local imageSuffix = renderTarget;
    if fill then imageSuffix = string.format("%s-%s", imageSuffix, "fill"); end
    if line then imageSuffix = string.format("%s-%s", imageSuffix, "line"); end

    local expected = love.image.newImageData(
                         string.format("expected-%s.png", imageSuffix));
    local identical, badPixel = diff(actual, expected);
    success = success and identical and not badPixel;
    print("\nTest case: " .. renderTarget)
    print("\tidentical: ", identical);

    save(actual, string.format("actual-%s.png", imageSuffix));

    if badPixel then
        print(string.format(
                  "\tPixel at (x: %d, y: %d) is (R: %f, G: %f, B: %f, A: %g) but should be (R: %f, G: %f, B: %f, A: %f)",
                  badPixel.x, badPixel.y, badPixel.actual[1],
                  badPixel.actual[2], badPixel.actual[3], badPixel.actual[4],
                  badPixel.expected[1], badPixel.expected[2],
                  badPixel.expected[3], badPixel.expected[4]));
    end
end

for _, renderTarget in ipairs({"canvas", "backbuffer"}) do
    for _, fill in ipairs({true, false}) do
        for _, line in ipairs({true, false}) do
            if fill or line then runTest(renderTarget, fill, line); end
        end
    end
end

love.event.quit(success and 0 or 1);

