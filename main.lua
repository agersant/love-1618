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
                        if math.abs(expectedColor[i] - actualColor[i]) > 1 / 255 then
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
    local file = io.open(name .. ".png", "wb+");
    file:write(image:encode("png"):getString());
    file:close();
end

local draw = function()
    love.graphics.setColor({0 / 255, 234 / 255, 255 / 255, 0.6});
    love.graphics.circle("fill", 40, 40, 10, 16);
    love.graphics.setColor({0 / 255, 234 / 255, 255 / 255});
    love.graphics.circle("line", 40, 40, 10, 16);
end

draw();
local actual = capture();
local expected = love.image.newImageData("expected.png");
save(actual, "actual");
local identical, badPixel = diff(actual, expected);
print("identical", identical);
if badPixel then
    print(string.format(
              "Pixel at (x: %d, y: %d) is (R: %f, G: %f, B: %f, A: %g) but should be (R: %f, G: %f, B: %f, A: %f)",
              badPixel.x, badPixel.y, badPixel.actual[1], badPixel.actual[2],
              badPixel.actual[3], badPixel.actual[4], badPixel.expected[1],
              badPixel.expected[2], badPixel.expected[3], badPixel.expected[4]));
end

love.event.quit(identical and 0 or 1);

