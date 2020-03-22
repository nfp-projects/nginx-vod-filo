local files = {}

local map = {}

--[[ function tprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))      
    else
      print(formatting .. v)
    end
  end
end ]]--

local function ends_with(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end

local p = io.popen('ls -a "/content/kennslur"')
for file in p:lines() do
  if ends_with(file, '.mp4') and not ends_with(file, 'klippt.mp4') then
    table.insert(files, file)
  end
end

table.sort(files, function(a, b) return b < a end)

local created = 0

for i = 1, #files do
  temp = {}
  for s in string.gmatch(files[i], '([^_.]+)') do
    temp[#temp + 1] = s
  end
  if string.match(temp[1], '^%d%d%d%d%-%d%d%-%d%d$') and string.match(temp[2], '^%d%d%d%d$') then
    if not map[temp[1]] then
      created = created + 1
      if created > 6 then break end
      map[temp[1]] = {}
    end
      
    table.insert(map[temp[1]], {
      time = temp[2],
      file = files[i],
    })
  end
end

local result = {}

for k,v in pairs(map) do
  table.sort(v, function(a,b) return a['time'] < b['time'] end)
  table.insert(result, {
    date = k,
    items = v,
  })
end

table.sort(result, function(a,b) return a['date'] > b['date'] end)

ngx.say('[')
for k,v in pairs(result) do
  ngx.say('  {')
  ngx.say('    "data":"' .. v['date'] .. '",')
  ngx.say('    "items": [')
  for x,y in pairs(v['items']) do
    if next(v['items'], x) == nil then
      ngx.say('      { "time":"' .. y['time'] .. '", "file":"' .. y['file'] .. '" }')
    else
      ngx.say('      { "time":"' .. y['time'] .. '", "file":"' .. y['file'] .. '" },')
    end
  end
  ngx.say('    ]')
  if next(result, k) == nil then
    ngx.say('  }')
  else
    ngx.say('  },')
  end
end
ngx.say(']')
