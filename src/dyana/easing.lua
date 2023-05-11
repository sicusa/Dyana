--
-- Adapted from
-- Tweener's easing functions (Penner's Easing Equations)
-- and http://code.google.com/p/tweener/ (jstweener javascript version)
--

--[[
Disclaimer for Robert Penner's Easing Equations license:
TERMS OF USE - EASING EQUATIONS
Open source under the BSD License.
Copyright © 2001 Robert Penner
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the names of contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

-- For all easing functions:
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration (total time)

local sin = math.sin
local cos = math.cos
local pi = math.pi
local sqrt = math.sqrt
local abs = math.abs
local asin    = math.asin

---@param t number
---@param b number
---@param c number
---@return number
local function linear(t, b, c)
    return c * t + b
end

---@param t number
---@param b number
---@param c number
---@return number
local function in_quad(t, b, c)
    return c * t ^ 2 + b
end

---@param t number
---@param b number
---@param c number
---@return number
local function out_quad(t, b, c)
    return -c * t * (t - 2) + b
end

---@param t number
---@param b number
---@param c number
---@return number
local function in_out_quad(t, b, c)
    t = t * 2
    if t < 1 then
        return c / 2 * t ^ 2 + b
    else
        return -c / 2 * ((t - 1) * (t - 3) - 1) + b
    end
end

---@param t number
---@param b number
---@param c number
---@return number
local function out_in_quad(t, b, c)
    if t < 0.5 then
        return out_quad (t * 2, b, c / 2)
    else
        return in_quad((t * 2) - 1, b + c / 2, c / 2)
    end
end

---@param t number
---@param b number
---@param c number
---@return number
local function in_cubic (t, b, c)
    return c * t ^ 3 + b
end

---@param t number
---@param b number
---@param c number
---@return number
local function out_cubic(t, b, c)
    t = t - 1
    return c * (t ^ 3 + 1) + b
end

---@param t number
---@param b number
---@param c number
---@return number
local function in_out_cubic(t, b, c)
    t = t * 2
    if t < 1 then
        return c / 2 * t * t * t + b
    else
        t = t - 2
        return c / 2 * (t * t * t + 2) + b
    end
end

---@param t number
---@param b number
---@param c number
---@return number
local function out_in_cubic(t, b, c)
    if t < 0.5 then
        return out_cubic(t * 2, b, c / 2)
    else
        return in_cubic((t * 2) - 1, b + c / 2, c / 2)
    end
end

---@param t number
---@param b number
---@param c number
---@return number
local function in_quart(t, b, c)
    return c * t ^ 4 + b
end

---@param t number
---@param b number
---@param c number
---@return number
local function out_quart(t, b, c)
    t = t - 1
    return -c * (t ^ 4 - 1) + b
end

---@param t number
---@param b number
---@param c number
---@return number
local function in_out_quart(t, b, c)
    t = t * 2
    if t < 1 then
        return c / 2 * t ^ 4 + b
    else
        t = t - 2
        return -c / 2 * (t ^ 4 - 2) + b
    end
end

---@param t number
---@param b number
---@param c number
---@return number
local function out_in_quart(t, b, c)
    if t < 0.5 then
        return out_quart(t * 2, b, c / 2)
    else
        return in_quart((t * 2) - 1, b + c / 2, c / 2)
    end
end

---@param t number
---@param b number
---@param c number
---@return number
local function in_quint(t, b, c)
    return c * t ^ 5 + b
end

---@param t number
---@param b number
---@param c number
---@return number
local function out_quint(t, b, c)
    t = t - 1
    return c * (t ^ 5 + 1) + b
end

---@param t number
---@param b number
---@param c number
---@return number
local function in_out_quint(t, b, c)
    t = t * 2
    if t < 1 then
        return c / 2 * t ^ 5 + b
    else
        t = t - 2
        return c / 2 * (t ^ 5 + 2) + b
    end
end

---@param t number
---@param b number
---@param c number
---@return number
local function out_in_quint(t, b, c)
    if t < 0.5 then
        return out_quint(t * 2, b, c / 2)
    else
        return in_quint((t * 2) - 1, b + c / 2, c / 2)
    end
end

---@param t number
---@param b number
---@param c number
---@return number
local function in_sine(t, b, c)
    return -c * cos(t * (pi / 2)) + c + b
end

---@param t number
---@param b number
---@param c number
---@return number
local function out_sine(t, b, c)
    return c * sin(t * (pi / 2)) + b
end

---@param t number
---@param b number
---@param c number
---@return number
local function in_out_sine(t, b, c)
    return -c / 2 * (cos(pi * t) - 1) + b
end

---@param t number
---@param b number
---@param c number
---@return number
local function out_in_sine(t, b, c)
    if t < 0.5 then
        return out_sine(t * 2, b, c / 2)
    else
        return in_sine((t * 2) - 1, b + c / 2, c / 2)
    end
end

---@param t number
---@param b number
---@param c number
---@return number
local function in_expo(t, b, c)
    if t == 0 then
        return b
    else
        return c * 2 ^ (10 * (t - 1)) + b - c * 0.001
    end
end

---@param t number
---@param b number
---@param c number
---@return number
local function out_expo(t, b, c)
    if t == 1 then
        return b + c
    else
        return c * 1.001 * (-2 ^ (-10 * t) + 1) + b
    end
end

---@param t number
---@param b number
---@param c number
---@return number
local function in_out_expo(t, b, c)
    if t == 0 then return b end
    if t == 1 then return b + c end
    t = t * 2
    if t < 1 then
        return c / 2 * 2 ^ (10 * (t - 1)) + b - c * 0.0005
    else
        t = t - 1
        return c / 2 * 1.0005 * (-2 ^ (-10 * t) + 2) + b
    end
end

---@param t number
---@param b number
---@param c number
---@return number
local function out_in_expo(t, b, c)
    if t < 0.5 then
        return out_expo(t * 2, b, c / 2)
    else
        return in_expo((t * 2) - 1, b + c / 2, c / 2)
    end
end

---@param t number
---@param b number
---@param c number
---@return number
local function in_circ(t, b, c)
    return(-c * (sqrt(1 - t ^ 2) - 1) + b)
end

---@param t number
---@param b number
---@param c number
---@return number
local function out_circ(t, b, c)
    t = t - 1
    return(c * sqrt(1 - t ^ 2) + b)
end

---@param t number
---@param b number
---@param c number
---@return number
local function in_out_circ(t, b, c)
    t = t * 2
    if t < 1 then
        return -c / 2 * (sqrt(1 - t * t) - 1) + b
    else
        t = t - 2
        return c / 2 * (sqrt(1 - t * t) + 1) + b
    end
end

---@param t number
---@param b number
---@param c number
---@return number
local function out_in_circ(t, b, c)
    if t < 0.5 then
        return out_circ(t * 2, b, c / 2)
    else
        return in_circ((t * 2) - 1, b + c / 2, c / 2)
    end
end

---@param t number
---@param b number
---@param c number
---@return number
local function in_elastic(t, b, c, a, p)
    if t == 0 then return b end

    if t == 1    then return b + c end

    if not p then p = 0.3 end

    local s

    if not a or a < abs(c) then
        a = c
        s = p / 4
    else
        s = p / (2 * pi) * asin(c/a)
    end

    t = t - 1

    return -(a * 2 ^ (10 * t) * sin((t - s) * (2 * pi) / p)) + b
end

---@param t number
---@param b number
---@param c number
---@param a number period
---@param p number amplitude
---@return number
local function out_elastic(t, b, c, a, p)
    if t == 0 then return b end

    if t == 1 then return b + c end

    if not p then p = 0.3 end

    local s

    if not a or a < abs(c) then
        a = c
        s = p / 4
    else
        s = p / (2 * pi) * asin(c/a)
    end

    return a * 2 ^ (-10 * t) * sin((t - s) * (2 * pi) / p) + c + b
end

---@param t number
---@param b number
---@param c number
---@param a number period
---@param p number amplitude
---@return number
local function in_out_elastic(t, b, c, a, p)
    if t == 0 then return b end

    t = t * 2

    if t == 2 then return b + c end

    if not p then p = 0.3 * 1.5 end
    if not a then a = 0 end

    local s

    if not a or a < abs(c) then
        a = c
        s = p / 4
    else
        s = p / (2 * pi) * asin(c / a)
    end

    if t < 1 then
        t = t - 1
        return -0.5 * (a * 2 ^ (10 * t) * sin((t - s) * (2 * pi) / p)) + b
    else
        t = t - 1
        return a * 2 ^ (-10 * t) * sin((t - s) * (2 * pi) / p) * 0.5 + c + b
    end
end

---@param t number
---@param b number
---@param c number
---@param a number period
---@param p number amplitude
---@return number
local function out_in_elastic(t, b, c, a, p)
    if t < 0.5 then
        return out_elastic(t * 2, b, c / 2, a, p)
    else
        return in_elastic((t * 2) - 1, b + c / 2, c / 2, a, p)
    end
end

---@param t number
---@param b number
---@param c number
---@param s number
---@return number
local function in_back(t, b, c, s)
    if not s then s = 1.70158 end
    return c * t * t * ((s + 1) * t - s) + b
end

---@param t number
---@param b number
---@param c number
---@param s number
---@return number
local function out_back(t, b, c, s)
    if not s then s = 1.70158 end
    t = t - 1
    return c * (t * t * ((s + 1) * t + s) + 1) + b
end

---@param t number
---@param b number
---@param c number
---@param s number
---@return number
local function in_out_back(t, b, c, s)
    if not s then s = 1.70158 end
    s = s * 1.525
    t = t * 2
    if t < 1 then
        return c / 2 * (t * t * ((s + 1) * t - s)) + b
    else
        t = t - 2
        return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
    end
end

---@param t number
---@param b number
---@param c number
---@param s number
---@return number
local function out_in_back(t, b, c, s)
    if t < 0.5 then
        return out_back(t * 2, b, c / 2, s)
    else
        return in_back((t * 2) - 1, b + c / 2, c / 2, s)
    end
end

---@param t number
---@param b number
---@param c number
---@return number
local function out_bounce(t, b, c)
    if t < 1 / 2.75 then
        return c * (7.5625 * t * t) + b
    elseif t < 2 / 2.75 then
        t = t - (1.5 / 2.75)
        return c * (7.5625 * t * t + 0.75) + b
    elseif t < 2.5 / 2.75 then
        t = t - (2.25 / 2.75)
        return c * (7.5625 * t * t + 0.9375) + b
    else
        t = t - (2.625 / 2.75)
        return c * (7.5625 * t * t + 0.984375) + b
    end
end

---@param t number
---@param b number
---@param c number
---@return number
local function in_bounce(t, b, c)
    return c - out_bounce(1 - t, 0, c) + b
end

---@param t number
---@param b number
---@param c number
---@return number
local function in_out_bounce(t, b, c)
    if t < 0.5 then
        return in_bounce(t * 2, 0, c) * 0.5 + b
    else
        return out_bounce(t * 2 - 1, 0, c) * 0.5 + c * .5 + b
    end
end

---@param t number
---@param b number
---@param c number
---@return number
local function out_in_bounce(t, b, c)
    if t < 0.5 then
        return out_bounce(t * 2, b, c / 2)
    else
        return in_bounce((t * 2) - 1, b + c / 2, c / 2)
    end
end

---@class dyana.easing
return {
    linear = linear,
    in_quad = in_quad,
    out_quad = out_quad,
    in_out_quad = in_out_quad,
    out_in_quad = out_in_quad,
    in_cubic    = in_cubic ,
    out_cubic = out_cubic,
    in_out_cubic = in_out_cubic,
    out_in_cubic = out_in_cubic,
    in_quart = in_quart,
    out_quart = out_quart,
    in_out_quart = in_out_quart,
    out_in_quart = out_in_quart,
    in_quint = in_quint,
    out_quint = out_quint,
    in_out_quint = in_out_quint,
    out_in_quint = out_in_quint,
    in_sine = in_sine,
    out_sine = out_sine,
    in_out_sine = in_out_sine,
    out_in_sine = out_in_sine,
    in_expo = in_expo,
    out_expo = out_expo,
    in_out_expo = in_out_expo,
    out_in_expo = out_in_expo,
    in_circ = in_circ,
    out_circ = out_circ,
    in_out_circ = in_out_circ,
    out_in_circ = out_in_circ,
    in_elastic = in_elastic,
    out_elastic = out_elastic,
    in_out_elastic = in_out_elastic,
    out_in_elastic = out_in_elastic,
    in_back = in_back,
    out_back = out_back,
    in_out_back = in_out_back,
    out_in_back = out_in_back,
    in_bounce = in_bounce,
    out_bounce = out_bounce,
    in_out_bounce = in_out_bounce,
    out_in_bounce = out_in_bounce,
}