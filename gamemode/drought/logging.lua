local LOGGERS = {}

function Log(name)
    if not name then
        local str = debug.getinfo(1)
        str = str.source:sub(2)
        name = str:match("^.*/(.*).lua$") or str
    end

    LOGGERS[name] = true
    local LCOLOR = HSVToColor(math.random(-360, 360) * 1 % 360, 1, 1)
    -- print("[" .. name .. " : L" .. line .. "] ", ...)

    return function(...)
        if LOGGERS[name] == true then
            local line = debug.getinfo(2).currentline
            MsgC(LCOLOR, "[", name, " : L", line, "] ")

            local args = {...}

            if #args == 1 then
                MsgC(args[1], "\n")
            elseif #args == 0 then
                ErrorNoHalt("No message given?\n")
            else
                local concat = ""

                for i = 1, #args - 1 do
                    concat = concat .. tostring(args[i]) .. ", "
                end

                concat = concat .. tostring(args[#args])
                Msg(concat .. "\n")
            end

            return line
        end
    end
end

function SetLoggingMode(name, bool)
    if isnumber(bool) then
        bool = (bool == 1)
    else
        if not isbool(bool) then
            bool = false
        end
    end

    LOGGERS[name] = bool
end