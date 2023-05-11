---@class dyana.actions
local actions = {}

---@alias dyana.action<T> fun(time: number): T

-- action constructors

---@generic T
---@generic U
---@param initial T
---@param final T
---@param callback fun(current: T): U
---@return dyana.action<U>
actions.tween = function(initial, final, callback)
    local diff = final - initial
    return function(time)
        return callback(initial + diff * time)
    end
end

---@generic T
---@generic U
---@param initial T
---@param final T
---@param easing_func fun(time: number, initial: T, diff: T): T
---@param callback fun(current: T): U
---@return dyana.action<U>
actions.custom_tween = function(initial, final, easing_func, callback)
    local diff = final - initial
    return function(time)
        return callback(easing_func(time, initial, diff))
    end
end

---@generic T
---@param callback fun(): T
---@return dyana.action<T?>
actions.event = function(callback)
    local last_time
    return function(time)
        if last_time ~= time then
            last_time = time
            if time == 1 then
                return callback()
            end
        end
    end
end

-- action combinators

---@generic T
---@param action dyana.action<T>
---@return dyana.action<T>
actions.reverse = function(action)
    return function(time)
        return action(1 - time)
    end
end

---@generic T
---@param easing_func fun(time: number, initial: number, diff: number): number
---@param action dyana.action<T>
---@return dyana.action<T>
actions.ease = function(easing_func, action)
    return function(time)
        return action(easing_func(time, 0, 1))
    end
end

---@generic T
---@param ... dyana.action<T>
---@return dyana.action<T>
actions.combine = function(...)
    local count = select("#", ...)
    if count == 1 then
        local t1 = ...
        return t1
    elseif count == 2 then
        local t1, t2 = ...
        return function(time)
            t1(time)
            return t2(time)
        end
    elseif count == 3 then
        local t1, t2, t3 = ...
        return function(time)
            t1(time)
            t2(time)
            return t3(time)
        end
    elseif count == 4 then
        local t1, t2, t3, t4 = ...
        return function(time)
            t1(time)
            t2(time)
            t3(time)
            return t4(time)
        end
    else
        local actions = {...}
        return function(time)
            for i = 1, count - 1 do
                actions[i](time)
            end
            return actions[count](time)
        end
    end
end

---@generic T
---@param out_action dyana.action<T>
---@param in_actoun dyana.action<T>
---@return dyana.action<T>
actions.cross = function(out_action, in_actoun)
    return function(time)
        out_action(1 - time)
        return in_actoun(time)
    end
end

return actions