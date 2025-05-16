set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc

if has('nvim')
  lua << EOF
  require("nvim-tree").setup {
  git = {
    enable = false,
  },
  renderer = {
    indent_markers = {
      enable = true,
      icons = {
        corner = "└",
        edge   = "│",
        item   = "│",
        bottom = "─",
        none   = " ",
      },
    },
    highlight_git = false,
    special_files = {}, 
    highlight_opened_files = "name",
    icons = {
      show = {
        file = false,
        folder = false,
        folder_arrow = false,
      },
      glyphs = {
        folder = {
          arrow_closed = "→", -- when folder is closed
          arrow_open = "↳",   -- when folder is open
        },
      },
    },
  },
  update_focused_file = {
    enable = true,
    update_root = false,
  },
  on_attach = function(bufnr)
    local api = require("nvim-tree.api")

    local function opts(desc)
      return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- Set selected folder as root
    -- Note: set folder as root with <C>]

    -- Load the default mappings first
    api.config.mappings.default_on_attach(bufnr)

    -- Then unmap specific keys that you want to override with your global ones
    vim.keymap.del("n", "J", { buffer = bufnr })
    vim.keymap.del("n", "K", { buffer = bufnr })
    vim.keymap.del("n", "<C-k>", { buffer = bufnr })
    vim.keymap.set("n", "<leader>f", ":NvimTreeFocus<CR>", { desc = "Focus file tree" })
  end,

    }
  -- Now apply highlights after setup
  vim.cmd [[
    highlight NvimTreeFolderName guifg=#00ffff gui=bold
    highlight NvimTreeOpenedFolderName guifg=#00ffff gui=bold
    highlight NvimTreeFolderIcon guifg=#00ffff gui=bold

    highlight NvimTreeExecFile guifg=#ffffff gui=NONE
    highlight NvimTreeSpecialFile guifg=#ffffff gui=NONE
    highlight NvimTreeImageFile guifg=#ffffff gui=NONE

    highlight NvimTreeIndentMarker guifg=gray gui=NONE
    highlight NvimTreeOpenedFile guifg=green gui=bold
  ]]
EOF
endif

