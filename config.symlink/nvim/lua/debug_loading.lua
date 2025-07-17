-- Debug script to check loading path
print("=== Debugging loading path ===")

-- Test loading fttemplate directly
local success, err = pcall(require, "autocmd.fttemplate")
if success then
  print("✅ fttemplate loaded successfully")
else
  print("❌ fttemplate failed to load:", err)
end

-- Test loading autocmd.init
local success2, err2 = pcall(require, "autocmd.init")
if success2 then
  print("✅ autocmd.init loaded successfully")
else
  print("❌ autocmd.init failed to load:", err2)
end

-- Test loading autocmd
local success3, err3 = pcall(require, "autocmd")
if success3 then
  print("✅ autocmd loaded successfully")
else
  print("❌ autocmd failed to load:", err3)
end