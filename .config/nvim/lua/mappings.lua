require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- nvim/tmux navigation
map("n", "<C-h>", "<cmd>lua require(\"tmux\").move_left()<cr>", { desc = "Move Left" })
map("n", "<C-l>", "<cmd>lua require(\"tmux\").move_right()<cr>", { desc = "Move Right" })
map("n", "<C-j>", "<cmd>lua require(\"tmux\").move_bottom()<cr>", { desc = "Move Down" })
map("n", "<C-k>", "<cmd>lua require(\"tmux\").move_top()<cr>", { desc = "Move Up" })

-- nvim/tmux resize
map("n", "<M-h>", "<cmd>lua require(\"tmux\").resize_left()<cr>]]", { desc = "Resize left" })
map("n", "<M-l>", "<cmd>lua require(\"tmux\").resize_right()<cr>]]", { desc = "Resize Right" })
map("n", "<M-j>", "<cmd>lua require(\"tmux\").resize_bottom()<cr>]]", { desc = "Resize Down" })
map("n", "<M-k>", "<cmd>lua require(\"tmux\").resize_top()<cr>]]", { desc = "Resize Top" })
