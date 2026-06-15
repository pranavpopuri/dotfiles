-- Generates a milli-compatible boids animation data table.
-- Call generate() at startup; each call uses a fresh random seed.

local M = {}

local W          = 50     -- canvas columns (a touch wider than the menu)
local H          = 22     -- canvas rows (~20% shorter for tighter wall influence)
local N          = 80     -- boids
local LEADERS    = 5
local FRAMES     = 1000   -- 30 seconds at 30ms
local DELAY      = 30     -- ms per frame
local WARMUP     = 150    -- steps before recording (flock forms without reaching an edge)
local LOOP_BLEND  = 150    -- ease the ending back to the first frame for a seamless loop

-- Flocking forces - tuned for smooth birdlike turns with mild turbulence
local VIEW_R      = 18
local SEP_R       = 5.2
local CROWD_R     = 8.0
local MAX_V       = 1.28
local MIN_V       = 0.50
local TARGET_V    = 0.94
local MAX_FORCE   = 0.082
local SEP_W       = 0.60
local CROWD_W     = 0.042
local ALI_W       = 0.14
local COH_W       = 0.0009
local FLOW_W      = 0.034
local EDGE_W      = 0.034
local STRAGGLER_W = 0.026
local LEADER_W    = 0.0008
local LEADER_ALI_W = 0.012
local LEADER_GOAL_W = 0.014
local TRAIL_W     = 0.014
local TRAIL_ALI_W = 0.110
local SWIRL_W     = 0.064

-- Wall force field: per-boid tangential swirl injects curliness, plus a
-- smooth normal push that prevents the flock from piling against the edge.
local WALL_R         = 8.0
local WALL_NORMAL_W  = 0.048
local WALL_TANGENT_W = 0.078

-- Curl-noise turbulence breaks the flock out of one-direction straight runs.
local CURL_W   = 0.032
local CURL_KX  = 0.062
local CURL_KY  = 0.048
local CURL_T1  = 0.0096
local CURL_T2  = 0.0081

-- Broad drift plus individual wander keeps the flock organic without jitter.
local EDGE_MARGIN = 7
local FLOW_RATE   = 0.014
local LEADER_RATE = 0.019
local GOAL_RATE   = 0.018
local WANDER_STR  = 0.048
local WANDER_RATE = 0.026
local TRAIL_LEN   = 84

-- Soft edges: the flock turns before it hits the canvas border.

local ASPECT     = H / W       -- canvas geometry factor
local Y_SPEED    = ASPECT * 0.86 -- row-speed budget for a terminal canvas

local BOID_CHAR  = "\xc2\xb7"  -- U+00B7 middle dot · (2 UTF-8 bytes)
local BOID_BYTES = 2

local CX = W / 2
local CY = H / 2

-- sim_frame advances during warmup too, so the flow phase is random each run.
local sim_frame = 0
local flow_base = 0
local leader_trail = {}

local function hsv_hex(h, s, v)
  local i = math.floor(h * 6) % 6
  local f = h * 6 - math.floor(h * 6)
  local p = v * (1 - s)
  local q = v * (1 - s * f)
  local t = v * (1 - s * (1 - f))
  local r, g, b
  if     i == 0 then r, g, b = v, t, p
  elseif i == 1 then r, g, b = q, v, p
  elseif i == 2 then r, g, b = p, v, t
  elseif i == 3 then r, g, b = p, q, v
  elseif i == 4 then r, g, b = t, p, v
  else               r, g, b = v, p, q end
  return string.format("#%02x%02x%02x",
    math.floor(r * 255 + 0.5),
    math.floor(g * 255 + 0.5),
    math.floor(b * 255 + 0.5))
end

local function vel_color(vx, vy)
  local hue = (math.atan(vy / Y_SPEED, vx) / (2 * math.pi) + 0.5) % 1.0
  local spd = math.sqrt(vx * vx + (vy / Y_SPEED) * (vy / Y_SPEED))
  local sat = 0.55 + 0.45 * math.min(1.0, spd / MAX_V)
  return hsv_hex(hue, sat, 0.97)
end

local function limit_force(x, y, max_force)
  local m = math.sqrt(x * x + y * y)
  if m > max_force and m > 0 then
    return x / m * max_force, y / m * max_force
  end
  return x, y
end

local function clamp_speed(vx, vy)
  local vis_vy = vy / Y_SPEED
  local spd = math.sqrt(vx * vx + vis_vy * vis_vy)
  if spd > MAX_V then
    vx = vx / spd * MAX_V
    vy = vis_vy / spd * MAX_V * Y_SPEED
  elseif spd < MIN_V and spd > 0 then
    vx = vx / spd * MIN_V
    vy = vis_vy / spd * MIN_V * Y_SPEED
  end
  return vx, vy
end

local function step(boids)
  sim_frame = sim_frame + 1
  -- The flock shares a loose heading that meanders instead of orbiting.
  local flow_angle = flow_base
    + math.sin(sim_frame * FLOW_RATE) * 1.30
    + math.sin(sim_frame * FLOW_RATE * 0.37 + 1.4) * 0.62
    + math.sin(sim_frame * FLOW_RATE * 1.63 + 0.5) * 0.34
  local flow_x = math.cos(flow_angle) * TARGET_V
  local flow_y = math.sin(flow_angle) * TARGET_V
  local leader_angle = flow_angle
    + math.sin(sim_frame * LEADER_RATE + 0.9) * 0.85
    + math.sin(sim_frame * LEADER_RATE * 0.43 + 2.1) * 0.48
  local leader_x = math.cos(leader_angle) * MAX_V
  local leader_y = math.sin(leader_angle) * MAX_V
  local next_boids = {}
  local flock_x, flock_y, flock_vx, flock_vy = 0, 0, 0, 0
  local lead_x, lead_y, lead_vx, lead_vy, lead_n = 0, 0, 0, 0, 0

  for i = 1, N do
    local b = boids[i]
    flock_x = flock_x + b.x
    flock_y = flock_y + b.y
    flock_vx = flock_vx + b.vx
    flock_vy = flock_vy + b.vy / Y_SPEED
    if b.leader then
      lead_x = lead_x + b.x
      lead_y = lead_y + b.y
      lead_vx = lead_vx + b.vx
      lead_vy = lead_vy + b.vy / Y_SPEED
      lead_n = lead_n + 1
    end
  end
  flock_x, flock_y = flock_x / N, flock_y / N
  flock_vx, flock_vy = flock_vx / N, flock_vy / N
  if lead_n > 0 then
    lead_x, lead_y = lead_x / lead_n, lead_y / lead_n
    lead_vx, lead_vy = lead_vx / lead_n, lead_vy / lead_n
  else
    lead_x, lead_y = flock_x, flock_y
    lead_vx, lead_vy = flock_vx, flock_vy
  end
  table.insert(leader_trail, 1, { x = lead_x, y = lead_y, vx = lead_vx, vy = lead_vy })
  if #leader_trail > TRAIL_LEN then
    table.remove(leader_trail)
  end
  local flock_spd = math.sqrt(flock_vx * flock_vx + flock_vy * flock_vy)
  if flock_spd == 0 then flock_spd = 1 end
  local head_x, head_y = flock_vx / flock_spd, flock_vy / flock_spd
  local side_x, side_y = -head_y, head_x
  local flock_edge_x, flock_edge_y = 0, 0
  if flock_x < W * 0.22 then
    flock_edge_x = (W * 0.22 - flock_x) * EDGE_W
  elseif flock_x > W * 0.78 then
    flock_edge_x = -(flock_x - W * 0.78) * EDGE_W
  end
  if flock_y < H * 0.28 then
    flock_edge_y = ((H * 0.28 - flock_y) / Y_SPEED) * EDGE_W
  elseif flock_y > H * 0.72 then
    flock_edge_y = -((flock_y - H * 0.72) / Y_SPEED) * EDGE_W
  end

  for i = 1, N do
    local b = boids[i]
    local sx, sy, px, py, ax, ay, cx, cy = 0, 0, 0, 0, 0, 0, 0, 0
    local sn, pn, n = 0, 0, 0

    for j = 1, N do
      if i ~= j then
        local o  = boids[j]
        local dx = o.x - b.x
        local dy = o.y - b.y
        local vdy = dy / Y_SPEED
        local d  = math.sqrt(dx * dx + vdy * vdy)
        if d < VIEW_R then
          cx, cy = cx + dx, cy + vdy
          ax, ay = ax + o.vx, ay + o.vy / Y_SPEED
          n = n + 1
          if d < SEP_R and d > 0 then
            local push = (SEP_R - d) / SEP_R
            sx = sx - dx / d * push
            sy = sy - vdy / d * push
            sn = sn + 1
          end
          if d < CROWD_R and d > 0 then
            local push = (CROWD_R - d) / CROWD_R
            px = px - dx / d * push * push
            py = py - vdy / d * push * push
            pn = pn + 1
          end
        end
      end
    end

    local steer_x, steer_y = 0, 0
    if sn > 0 then
      sx, sy = sx / sn * SEP_W, sy / sn * SEP_W
      steer_x, steer_y = steer_x + sx, steer_y + sy
    end
    if pn > 8 then
      steer_x = steer_x + px / pn * CROWD_W * (pn - 8)
      steer_y = steer_y + py / pn * CROWD_W * (pn - 8)
    end
    if n > 0 then
      local avg_vx = ax / n
      local avg_vy = ay / n
      local avg_spd = math.sqrt(avg_vx * avg_vx + avg_vy * avg_vy)
      if avg_spd > 0 then
        avg_vx, avg_vy = avg_vx / avg_spd * TARGET_V, avg_vy / avg_spd * TARGET_V
        steer_x = steer_x + (avg_vx - b.vx) * ALI_W
        steer_y = steer_y + (avg_vy - b.vy / Y_SPEED) * ALI_W
      end
      steer_x = steer_x + (cx / n) * COH_W
      steer_y = steer_y + (cy / n) * COH_W
    end

    if b.leader then
      local gp = b.goal_phase or 0
      local gx = CX
        + math.sin(sim_frame * GOAL_RATE + flow_base + gp) * W * 0.34
        + math.sin(sim_frame * GOAL_RATE * 0.41 + gp * 1.7) * W * 0.10
      local gy = CY
        + math.sin(sim_frame * GOAL_RATE * 0.71 + flow_base * 1.7 + gp * 1.3) * H * 0.30
        + math.sin(sim_frame * GOAL_RATE * 1.13 + gp * 0.8) * H * 0.09
      steer_x = steer_x + (leader_x - b.vx) * FLOW_W * 1.4
      steer_y = steer_y + (leader_y - b.vy / Y_SPEED) * FLOW_W * 1.4
      steer_x = steer_x + (gx - b.x) * LEADER_GOAL_W
      steer_y = steer_y + ((gy - b.y) / Y_SPEED) * LEADER_GOAL_W
      steer_x = steer_x + (lead_x - b.x) * COH_W * 0.35
      steer_y = steer_y + ((lead_y - b.y) / Y_SPEED) * COH_W * 0.35
    else
      local to_flock_x = flock_x - b.x
      local to_flock_y = (flock_y - b.y) / Y_SPEED
      local flock_dist = math.sqrt(to_flock_x * to_flock_x + to_flock_y * to_flock_y)
      local pull = 0
      if n < 4 then pull = pull + STRAGGLER_W * 0.45 end
      if flock_dist > 16 then pull = pull + STRAGGLER_W * (flock_dist - 16) * 0.14 end
      steer_x = steer_x + to_flock_x * pull + (flock_vx - b.vx) * ALI_W * 0.20
      steer_y = steer_y + to_flock_y * pull + (flock_vy - b.vy / Y_SPEED) * ALI_W * 0.20
    end

    if not b.leader then
      steer_x = steer_x + (lead_x - b.x) * LEADER_W
      steer_y = steer_y + ((lead_y - b.y) / Y_SPEED) * LEADER_W
      steer_x = steer_x + (lead_vx - b.vx) * LEADER_ALI_W
      steer_y = steer_y + (lead_vy - b.vy / Y_SPEED) * LEADER_ALI_W
      local trail = leader_trail[math.min(#leader_trail, b.trail_delay or 1)]
      if trail then
        local trail_spd = math.sqrt(trail.vx * trail.vx + trail.vy * trail.vy)
        if trail_spd == 0 then trail_spd = 1 end
        local tx = -trail.vy / trail_spd
        local ty = trail.vx / trail_spd
        local offset = (b.trail_offset or 0) * (0.65 + 0.35 * math.sin(sim_frame * 0.019 + b.phase))
        local target_x = trail.x + tx * offset
        local target_y = trail.y + ty * offset * Y_SPEED
        local mimic = 0.32 + 0.68 * math.max(0, math.sin(sim_frame * 0.023 + b.phase * 1.9))
        steer_x = steer_x + (target_x - b.x) * TRAIL_W * mimic
        steer_y = steer_y + ((target_y - b.y) / Y_SPEED) * TRAIL_W * mimic
        steer_x = steer_x + (trail.vx - b.vx) * TRAIL_ALI_W * mimic
        steer_y = steer_y + (trail.vy - b.vy / Y_SPEED) * TRAIL_ALI_W * mimic
      end
      steer_x = steer_x + (flow_x - b.vx) * FLOW_W * 0.06
      steer_y = steer_y + (flow_y - b.vy / Y_SPEED) * FLOW_W * 0.06
    end
    steer_x = steer_x + flock_edge_x
    steer_y = steer_y + flock_edge_y

    local rel_x = b.x - flock_x
    local rel_y = (b.y - flock_y) / Y_SPEED
    local along = rel_x * head_x + rel_y * head_y
    local side = rel_x * side_x + rel_y * side_y
    local swirl = math.sin(sim_frame * FLOW_RATE * 2.6 + along * 0.13)
      + math.sin(sim_frame * FLOW_RATE * 1.1 + b.phase) * 0.45
    steer_x = steer_x + side_x * swirl * SWIRL_W
    steer_y = steer_y + side_y * swirl * SWIRL_W
    if math.abs(side) > 8 then
      local side_pull = (math.abs(side) - 8) * 0.010
      if side > 0 then side_pull = -side_pull end
      steer_x = steer_x + side_x * side_pull
      steer_y = steer_y + side_y * side_pull
    end

    if b.x < EDGE_MARGIN then
      steer_x = steer_x + (EDGE_MARGIN - b.x) * EDGE_W
    elseif b.x > W - EDGE_MARGIN then
      steer_x = steer_x - (b.x - (W - EDGE_MARGIN)) * EDGE_W
    end
    if b.y < EDGE_MARGIN * Y_SPEED then
      steer_y = steer_y + (EDGE_MARGIN * Y_SPEED - b.y) / Y_SPEED * EDGE_W
    elseif b.y > H - EDGE_MARGIN * Y_SPEED then
      steer_y = steer_y - (b.y - (H - EDGE_MARGIN * Y_SPEED)) / Y_SPEED * EDGE_W
    end

    -- Wall force field: smooth inward push + per-boid tangential swirl.
    -- Each boid's phase makes neighbors slide opposite ways along the wall,
    -- which shears bunches apart and bends straight runs into curls.
    local lx_d, rx_d = b.x, W - b.x
    local ty_v, by_v = b.y / Y_SPEED, (H - b.y) / Y_SPEED
    local fl = lx_d < WALL_R and (WALL_R - lx_d) / WALL_R or 0
    local fr = rx_d < WALL_R and (WALL_R - rx_d) / WALL_R or 0
    local ft = ty_v < WALL_R and (WALL_R - ty_v) / WALL_R or 0
    local fb = by_v < WALL_R and (WALL_R - by_v) / WALL_R or 0
    fl, fr, ft, fb = fl * fl, fr * fr, ft * ft, fb * fb
    local s_lr = math.sin(b.phase * 2.3 + sim_frame * 0.022)
    local s_tb = math.cos(b.phase * 1.7 + sim_frame * 0.019)
    steer_x = steer_x + (fl - fr) * WALL_NORMAL_W + (ft - fb) * s_tb * WALL_TANGENT_W
    steer_y = steer_y + (ft - fb) * WALL_NORMAL_W + (fl - fr) * s_lr * WALL_TANGENT_W

    -- Curl-noise vortex perturbation across the canvas.
    local cnx = b.x * CURL_KX + sim_frame * CURL_T1
    local cny = (b.y / Y_SPEED) * CURL_KY + sim_frame * CURL_T2
    steer_x = steer_x + (-math.sin(cnx) * math.sin(cny)) * CURL_W
    steer_y = steer_y + (-math.cos(cnx) * math.cos(cny)) * CURL_W

    local wobble = math.sin(sim_frame * WANDER_RATE + b.phase)
    local flutter = math.sin(sim_frame * WANDER_RATE * 0.37 + b.phase * 1.7)
    steer_x = steer_x + math.cos(b.phase + wobble) * WANDER_STR * flutter
    steer_y = steer_y + math.sin(b.phase + wobble) * WANDER_STR * flutter

    steer_x, steer_y = limit_force(steer_x, steer_y, MAX_FORCE)
    local nvx = b.vx + steer_x
    local nvy = b.vy + steer_y * Y_SPEED
    nvx, nvy = clamp_speed(nvx, nvy)
    local nx = b.x + nvx
    local ny = b.y + nvy
    if nx < 0 then
      nx, nvx = 0, math.abs(nvx) * 0.75
    elseif nx >= W then
      nx, nvx = W - 0.01, -math.abs(nvx) * 0.75
    end
    if ny < 0 then
      ny, nvy = 0, math.abs(nvy) * 0.75
    elseif ny >= H then
      ny, nvy = H - 0.01, -math.abs(nvy) * 0.75
    end
    next_boids[i] = {
      x = nx,
      y = ny,
      vx = nvx,
      vy = nvy,
      phase = b.phase,
      leader = b.leader,
      trail_delay = b.trail_delay,
      trail_offset = b.trail_offset,
      goal_phase = b.goal_phase,
    }
  end

  for i = 1, N do
    boids[i] = next_boids[i]
  end
end

local function render(boids)
  local grid = {}
  for y = 1, H do grid[y] = {} end
  for i, b in ipairs(boids) do
    local gx = math.floor(b.x) + 1
    local gy = math.floor(b.y) + 1
    if gx >= 1 and gx <= W and gy >= 1 and gy <= H then
      -- last writer wins (fine for dense flocks)
      grid[gy][gx] = i
    end
  end

  local lines  = {}
  local colors = {}
  for y = 1, H do
    local parts      = {}
    local row_colors = {}
    local byte_pos   = 0
    for x = 1, W do
      local bi = grid[y][x]
      if bi then
        local col = vel_color(boids[bi].vx, boids[bi].vy)
        table.insert(row_colors, { byte_pos, byte_pos + BOID_BYTES, col, "NONE" })
        table.insert(parts, BOID_CHAR)
        byte_pos = byte_pos + BOID_BYTES
      else
        table.insert(parts, " ")
        byte_pos = byte_pos + 1
      end
    end
    lines[y]  = table.concat(parts)
    colors[y] = row_colors
  end
  return lines, colors
end

local function clone_boids(boids)
  local out = {}
  for i, b in ipairs(boids) do
    out[i] = {
      x = b.x,
      y = b.y,
      vx = b.vx,
      vy = b.vy,
      phase = b.phase,
      leader = b.leader,
      trail_delay = b.trail_delay,
      trail_offset = b.trail_offset,
      goal_phase = b.goal_phase,
    }
  end
  return out
end

local function smoothstep(t)
  return t * t * (3 - 2 * t)
end

local function blend_boids(a, b, t)
  local out = {}
  for i = 1, #a do
    local p = a[i]
    local q = b[i]
    out[i] = {
      x = p.x + (q.x - p.x) * t,
      y = p.y + (q.y - p.y) * t,
      vx = p.vx + (q.vx - p.vx) * t,
      vy = p.vy + (q.vy - p.vy) * t,
      phase = p.phase,
      leader = p.leader,
      trail_delay = p.trail_delay,
      trail_offset = p.trail_offset,
      goal_phase = p.goal_phase,
    }
  end
  return out
end

function M.generate()
  -- High-entropy seed: wall-clock seconds × large prime XOR'd with CPU microseconds
  local cpu_us = math.floor(os.clock() * 1e6) % 1000003
  math.randomseed(os.time() * 1000003 + cpu_us)

  sim_frame = 0
  flow_base = math.random() * 2 * math.pi
  leader_trail = {}

  -- All boids start in a loose cluster moving in the same random direction
  -- so they immediately behave like a flock, not scattered particles.
  local init_angle = flow_base + (math.random() - 0.5) * 0.7
  local cos_a = math.cos(init_angle)
  local sin_a = math.sin(init_angle)

  local boids = {}
  for i = 1, N do
    local rx = (math.random() - 0.5) * W * 0.30
    local ry = (math.random() - 0.5) * H * 0.28
    local is_leader = i <= LEADERS
    local trail_offset = ((i % 9) - 4) * 1.7 + (math.random() - 0.5) * 1.4
    table.insert(boids, {
      x  = CX + rx,
      y  = CY + ry,
      vx = cos_a * (is_leader and MAX_V or TARGET_V) + (math.random() - 0.5) * 0.18,
      vy = (sin_a * (is_leader and MAX_V or TARGET_V) + (math.random() - 0.5) * 0.18) * Y_SPEED,
      phase = math.random() * 2 * math.pi,
      leader = is_leader,
      trail_delay = is_leader and 1 or (18 + (i % 9) * 7 + math.floor(math.random() * 10)),
      trail_offset = trail_offset,
      goal_phase = math.random() * 2 * math.pi,
    })
  end

  for _ = 1, WARMUP do step(boids) end
  local loop_start = nil

  local all_frames = {}
  local all_colors = {}
  local all_delays = {}

  for frame = 1, FRAMES do
    step(boids)
    if frame == 1 then
      loop_start = clone_boids(boids)
    end
    local render_boids = boids
    if frame > FRAMES - LOOP_BLEND then
      local t = smoothstep((frame - (FRAMES - LOOP_BLEND)) / LOOP_BLEND)
      render_boids = blend_boids(boids, loop_start, t)
    end
    local f, c = render(render_boids)
    table.insert(all_frames, f)
    table.insert(all_colors, c)
    table.insert(all_delays, DELAY)
  end

  return { cols = W, rows = H, frames = all_frames, colors = all_colors, delays = all_delays }
end

return M
