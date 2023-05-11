local actions = require("dyana.actions")

---@class dyana.tracks
local tracks = {}

local modf = math.modf

---@alias dyana.track<T> fun(frame: number): T

-- track constructors

---@generic T
---@param duration number
---@param action dyana.action<T>
---@return dyana.track<T?>
tracks.single = function(duration, action)
    local last_valid_frame = -1

    return function(frame)
        if frame > duration then
            if last_valid_frame ~= duration then
                last_valid_frame = duration
                return action(1)
            end
            return
        end

        last_valid_frame = frame
        return action(frame / duration)
    end
end

---@generic T
---@param offset number
---@param duration number
---@param action dyana.action<T>
---@return dyana.track<T?>
tracks.offset_single = function(offset, duration, action)
    local end_frame = offset + duration
    local last_valid_frame = -1

    return function(frame)
        if frame > end_frame then
            if last_valid_frame ~= end_frame then
                last_valid_frame = end_frame
                return action(1)
            end
            return
        elseif frame < offset then
            if last_valid_frame ~= offset then
                last_valid_frame = offset
                return action(0)
            end
            return
        end

        last_valid_frame = frame
        return action((frame - offset) / duration)
    end
end

---@generic T
---@param duration number
---@param ... dyana.action<T>
---@return dyana.track<T?>
tracks.multiple = function(duration, ...)
    return tracks.single(duration, actions.combine(...))
end

---@generic T
---@param actions {[1]: number, [2]: number, [3]: dyana.action<T>}[]
---@return dyana.track<T?>
tracks.sequence = function(actions)
    local action_seq = {}
    local frame_acc = 0

    for i = 1, #actions do
        local entry = actions[i]
        local interval = entry[1]
        local duration = entry[2]
        local action = entry[3]

        frame_acc = frame_acc + interval
        local end_frame = frame_acc + duration

        action_seq[#action_seq + 1] = {
            frame_acc, end_frame, duration, action
        }
        frame_acc = end_frame
    end

    local function find_action(seq, frame, li, ri)
        -- \binary search~!/
        local mid = math.floor((li + ri) / 2)
        local mid_action = seq[mid]

        if mid_action[1] <= frame then
            if frame <= mid_action[2] then
                return mid_action, mid
            elseif li ~= ri then
                return find_action(seq, frame, mid + 1, ri)
            else
                mid = mid + 1
                return seq[mid], mid
            end
        elseif li ~= ri then
            find_action(seq, frame, li, mid - 1)
        else
            return mid_action, mid
        end
    end

    local curr_index = 1
    local curr = action_seq[1] -- current action entry
    local last_valid_frame = -1

    return function(frame)
        local full_search

        if frame >= curr[2] then
            if last_valid_frame ~= curr[2] then
                last_valid_frame = curr[2]
                curr[4](1)
            end

            if curr_index == #action_seq then
                return
            end

            local next = action_seq[curr_index + 1]

            if frame < next[2] then
                curr_index = curr_index + 1
                curr = next
                if frame < curr[1] then
                    return
                end
            else
                full_search = true
            end
        elseif frame <= curr[1] then
            if last_valid_frame ~= curr[1] then
                last_valid_frame = curr[1]
                curr[4](0)
            end

            if curr_index == 1 then
                return
            end

            local last = action_seq[curr_index - 1]
            if last[2] <= frame then
                return -- still in current action entry
            end

            if last[1] <= frame then
                curr_index = curr_index - 1
                curr = last
            else
                full_search = true
            end
        end

        if full_search then
            local first_act = action_seq[1]
            local last_act = action_seq[#action_seq]

            -- special cases for first & last actions are
            -- profitable, for sequences can be used in loops or
            -- timelines where frames are frequently reset to
            -- 0 or total duration of the sequence.
            if frame <= first_act[2] then
                -- it is critical for actions to be reset in order!!!
                for i = curr_index, 2, -1 do
                    action_seq[i][4](0)
                end

                curr_index = 1
                curr = first_act

                if frame < curr[1] then
                    last_valid_frame = curr[1]
                    curr[4](0)
                    return
                end
                goto action_found
            elseif frame >= last_act[1] then
                for i = curr_index, #action_seq-1 do
                    action_seq[i][4](1)
                end

                curr_index = #action_seq
                curr = last_act

                if frame > curr[2] then
                    curr[4](1)
                    last_valid_frame = curr[2]
                    return
                end
                goto action_found
            end

            local entry
            local index

            if frame > curr[1] then
                entry, index = find_action(
                    action_seq, frame, curr_index + 1, #action_seq)

                for i = curr_index, index - 1 do
                    action_seq[i][4](1)
                end
            else
                entry, index = find_action(
                    action_seq, frame, 1, curr_index - 1)

                for i = curr_index, index, -1 do
                    action_seq[i][4](0)
                end
            end

            curr = entry
            curr_index = index
        end

        ::action_found::
        last_valid_frame = frame
        return curr[4]((frame - curr[1]) / curr[3])
    end
end

---@generic T
---@param count number
---@param duration number
---@param action dyana.action<T>
---@return dyana.track<T?>
tracks.loop = function(count, duration, action)
    local last_valid_frame = -1
    local end_frame = count * duration

    return function(frame)
        if frame >= end_frame then
            if last_valid_frame ~= end_frame then
                last_valid_frame = end_frame
                return action(1)
            end
            return
        end

        last_valid_frame = frame
        return action(frame % duration / duration)
    end
end

---@generic T
---@param duration number
---@param action dyana.action<T>
---@return dyana.track<T>
tracks.loop_forever = function(duration, action)
    return function(frame)
        return action(frame % duration / duration)
    end
end

---@generic T
---@param actions {[1]: number, [2]: number, [3]: dyana.action<T>}[]
---@return number
local function get_total_frames(actions)
    local total_frames = 0
    for i = 1, #actions do
        local action = actions[i]
        total_frames = total_frames + action[1] + action[2]
    end
    return total_frames
end

---@generic T
---@param count number
---@param actions {[1]: number, [2]: number, [3]: dyana.action<T>}[]
---@return dyana.action<T?>
tracks.loop_sequence = function(count, actions)
    local seq_track = tracks.sequence(actions)
    local total_frames = get_total_frames(actions)
    local end_frame = total_frames * count

    return function(frame)
        if frame < end_frame then
            return seq_track(frame % total_frames)
        else
            -- sequence track will handle the situation
            -- where the frame is greater then the total
            -- frame length of all actions.
            return seq_track(total_frames + frame)
        end
    end
end

---@generic T
---@param actions {[1]: number, [2]: number, [3]: dyana.action<T>}[]
---@return dyana.action<T>
tracks.loop_sequence_forever = function(actions)
    local seq_track = tracks.sequence(actions)
    local total_frames = get_total_frames(actions)

    return function(frame)
        return seq_track(frame % total_frames)
    end
end

---@generic T
---@param duration number
---@param action1 dyana.action<T>
---@param action2 dyana.action<T>
---@return dyana.track<T>
tracks.alternate = function(duration, action1, action2)
    return function(frame)
        local count, fract = modf(frame / duration)
        if count % 2 == 0 then
            return action1(fract)
        else
            return action2(fract)
        end
    end
end

-- track combinators

---@generic T
---@param ... dyana.track<T>
---@return dyana.track<T>
tracks.combine = function(...)
    local count = select("#", ...)

    if count == 1 then
        local t1 = ...
        return t1
    elseif count == 2 then
        local t1, t2 = ...
        return function(frame)
            t1(frame)
            return t2(frame)
        end
    elseif count == 3 then
        local t1, t2, t3 = ...
        return function(frame)
            t1(frame)
            t2(frame)
            return t3(frame)
        end
    elseif count == 4 then
        local t1, t2, t3, t4 = ...
        return function(frame)
            t1(frame)
            t2(frame)
            t3(frame)
            return t4(frame)
        end
    else
        local tracks = {...}
        return function(frame)
            for i = 1, count - 1 do
                tracks[i](frame)
            end
            tracks[count](frame)
        end
    end
end

---@generic T
---@param offset number
---@param track dyana.track<T>
---@return dyana.track<T?>
tracks.offset = function(offset, track)
    if offset == 0 then
        return track
    end

    if offset > 0 then
        local last_valid_frame = -1

        return function(frame)
            if frame < offset then
                if last_valid_frame ~= offset then
                    last_valid_frame = offset
                    return track(0)
                end
                return
            end

            last_valid_frame = frame
            return track(frame - offset)
        end
    else
        return function(frame)
            return track(frame - offset)
        end
    end
end

---@generic T
---@param start number
---@param duration number
---@param track dyana.track<T>
---@return dyana.track<T?>
tracks.clip = function(start, duration, track)
    local last_valid_frame = -1
    
    return function(frame)
        if frame > duration then
            if last_valid_frame ~= duration then
                last_valid_frame = duration
                return track(start + duration)
            end
            return
        end

        last_valid_frame = frame
        return track(start + frame)
    end
end

---@generic T
---@param mask_start number
---@param mask_duration number
---@param track dyana.track<T>
---@return dyana.track<T?>
tracks.mask = function(mask_start, mask_duration, track)
    local mask_end = mask_start + mask_duration
    local last_valid_frame = -1

    return function(frame)
        if frame > mask_end then
            if last_valid_frame ~= mask_end then
                last_valid_frame = mask_end
                return track(mask_start)
            end
            return
        elseif frame < mask_start then
            if last_valid_frame ~= mask_start then
                last_valid_frame = mask_start
                return track(mask_start)
            end
            return
        end

        last_valid_frame = frame
        return track(frame)
    end
end

---@generic T
---@param factor number
---@param track dyana.track<T>
---@return dyana.track<T?>
tracks.scale = function(factor, track)
    return function(frame)
        return track(frame * factor)
    end
end

return tracks