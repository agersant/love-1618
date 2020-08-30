io.stdout:setvbuf("no");
io.stderr:setvbuf("no");

love.conf = function(options)
    options.console = true;
    options.modules.audio = false;
end

