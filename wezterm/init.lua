-- WezTerm visor implementation
-- Simpler architecture using native Hammerspoon window management

local wezterm = {
  -- Terminal identification
  macApp = "WezTerm.app",
  bundleId = "com.github.wez.wezterm",
  windowTitle = "VISOR",
  
  -- Launch configuration
  launchCmdLine = {
    executable = "wezterm",
    background = true,
    args = {
      "start",
      "--class", "org.wez.wezterm.visor",
      "--cwd", os.getenv("HOME") or "$HOME",
    }
  },
  
  -- State
  visorWindowID = nil,
  appWatcher = nil,
}

-- Metatable for terminal template pattern
wezterm.__index = wezterm

-- Find existing visor window
-- Uses cached window ID for fast lookup, falls back to title search
function wezterm:findVisorWindow()
  -- Fast path: check cached window ID
  if self.visorWindowID then
    local window = hs.window.get(self.visorWindowID)
    if window and window:isStandard() then
      log.d("Found visor window via cached ID")
      return window
    end
    -- Stale ID, clear it
    log.d("Cached window ID is stale, clearing")
    self.visorWindowID = nil
  end
  
  -- Slow path: search by title
  local app = hs.application.get(self.bundleId)
  if not app then
    log.d("WezTerm application not running")
    return nil
  end
  
  for _, window in ipairs(app:allWindows()) do
    if window:title() == self.windowTitle then
      log.d("Found visor window via title search")
      -- Cache the window ID for next time
      self.visorWindowID = window:id()
      return window
    end
  end
  
  log.d("No visor window found")
  return nil
end

-- Spawn WezTerm process
function wezterm:spawnWezTerm()
  local cmd = self.launchCmdLine.executable
  
  -- Build command line from args
  for _, arg in ipairs(self.launchCmdLine.args) do
    -- Escape argument for shell
    if arg:match("%s") or arg:match("[&|;<>()-- WezTerm visor implementation
-- Simpler architecture using native Hammerspoon window management

local wezterm = {
  -- Terminal identification
  macApp = "WezTerm.app",
  bundleId = "com.github.wez.wezterm",
  windowTitle = "VISOR",
  
  -- Launch configuration
  launchCmdLine = {
    executable = "wezterm",
    background = true,
    args = {
      "start",
      "--class", "org.wez.wezterm.visor",
      "--cwd", os.getenv("HOME") or "$HOME",
    }
  },
  
  -- State
  visorWindowID = nil,
  appWatcher = nil,
}

-- Metatable for terminal template pattern
wezterm.__index = wezterm

-- Find existing visor window
-- Uses cached window ID for fast lookup, falls back to title search
function wezterm:findVisorWindow()
  -- Fast path: check cached window ID
  if self.visorWindowID then
    local window = hs.window.get(self.visorWindowID)
    if window and window:isStandard() then
      log.d("Found visor window via cached ID")
      return window
    end
    -- Stale ID, clear it
    log.d("Cached window ID is stale, clearing")
    self.visorWindowID = nil
  end
  
  -- Slow path: search by title
  local app = hs.application.get(self.bundleId)
  if not app then
    log.d("WezTerm application not running")
    return nil
  end
  
  for _, window in ipairs(app:allWindows()) do
    if window:title() == self.windowTitle then
      log.d("Found visor window via title search")
      -- Cache the window ID for next time
      self.visorWindowID = window:id()
      return window
    end
  end
  
  log.d("No visor window found")
\\\"']") then
      arg = "'" .. arg:gsub("'", "'\\''") .. "'"
    end
    cmd = cmd .. " " .. arg
  end
  
  -- Run in background
  if self.launchCmdLine.background then
    cmd = cmd .. " &"
  end
  
  log.d("Spawning WezTerm: " .. cmd)
  local output, status, exitType, rc = hs.execute(cmd)
  
  if not status then
    log.ef("Failed to spawn WezTerm: %s %s", exitType, rc)
    if output and output ~= "" then
      log.ef("Output: %s", output)
    end
    return false
  end
  
  log.d("WezTerm spawn command executed successfully")
  return true
end

-- Wait for visor window to appear after spawning
function wezterm:waitForWindow(timeout)
  timeout = timeout or 5
  local start = hs.timer.absoluteTime()
  local deadline = start + (timeout * 1000000000) -- Convert to nanoseconds
  
  log.d("Waiting for visor window to appear (timeout: " .. timeout .. "s)")
  
  while hs.timer.absoluteTime() < deadline do
    local window = self:findVisorWindow()
    if window then
      log.d("Visor window appeared")
      return window
    end
    hs.timer.usleep(100000) -- Sleep 100ms
  end
  
  log.w("Timed out waiting for visor window after " .. timeout .. " seconds")
  return nil
end

-- Start/show visor window (spawn if needed)
function wezterm:startVisorWindow(display)
  local visorWindow = self:findVisorWindow()
  
  if not visorWindow then
    log.d("No existing visor window, spawning new instance")
    
    if not self:spawnWezTerm() then
      log.e("Failed to spawn WezTerm")
      return nil
    end
    
    visorWindow = self:waitForWindow()
    if not visorWindow then
      log.e("Failed to get visor window after spawn")
      return nil
    end
  end
  
  return self:showVisorWindow(visorWindow, display)
end

-- Show and position visor window
function wezterm:showVisorWindow(visorWindow, display)
  local screenFrame = display:fullFrame()
  
  -- Calculate dropdown position (full width, configurable height at top)
  local targetFrame = hs.geometry.rect(
    screenFrame.x,
    screenFrame.y,
    screenFrame.w,
    screenFrame.h * self.opts.height
  )
  
  log.df("Positioning visor at: x=%d, y=%d, w=%d, h=%d",
         targetFrame.x, targetFrame.y, targetFrame.w, targetFrame.h)
  
  -- Set frame with no animation (instant)
  visorWindow:setFrame(targetFrame, 0)
  
  -- Unhide and focus
  visorWindow:application():unhide()
  visorWindow:focus()
  
  return visorWindow
end

-- Hide visor window
function wezterm:hideVisorWindow(visorWindow)
  log.d("Hiding visor window")
  visorWindow:application():hide()
  return visorWindow
end

-- Get terminal app and visor window references
function wezterm:getTerminalAppAndVisor()
  local visorWindow = self:findVisorWindow()
  local termApp = visorWindow and visorWindow:application()
  return termApp, visorWindow
end

-- Initialize module (sets up app watcher for quit detection)
function wezterm:init()
  log.d("Initializing WezTerm visor module")
  
  -- Setup application watcher to detect termination
  self.appWatcher = hs.application.watcher.new(function(appName, eventType, app)
    -- Only watch for our WezTerm instance
    if app:bundleID() ~= self.bundleId then
      return
    end
    
    -- Detect termination
    if eventType == hs.application.watcher.terminated then
      log.i("WezTerm visor terminated, clearing cached state")
      -- Clear cached window ID so next toggle spawns fresh
      self.visorWindowID = nil
    end
  end)
  
  -- Start the watcher
  self.appWatcher:start()
  log.d("Application watcher started")
end

-- Factory function to create terminal instance from template
function wezterm.fromTemplate(template)
  return setmetatable(template, wezterm)
end

return wezterm
