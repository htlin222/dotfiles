return {
  "rachartier/tiny-glimmer.nvim",
  event = "VeryLazy",
  opts = {
    -- Add buffer validation to prevent invalid buffer id errors
    on_attach = function(bufnr)
      -- Ensure buffer is valid before operations
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
    end,
  },
  config = function(_, opts)
    -- Override the cleanup function to add buffer validation
    local glimmer = require("tiny-glimmer")
    glimmer.setup(opts)
    
    -- Patch the animation cleanup to validate buffer before deleting extmarks
    local animation = require("tiny-glimmer.glimmer_animation")
    if animation and animation.cleanup then
      local original_cleanup = animation.cleanup
      animation.cleanup = function(self)
        if self.buffer and vim.api.nvim_buf_is_valid(self.buffer) then
          return original_cleanup(self)
        end
      end
    end
  end,
}
