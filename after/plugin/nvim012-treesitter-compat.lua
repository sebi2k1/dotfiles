-- Nvim 0.12 removed the `all=false` option from add_directive/add_predicate.
-- match[capture_id] is now always TSNode[], never a bare TSNode.
-- Re-register the affected nvim-treesitter handlers until upstream fixes it.
-- Tracked: https://github.com/nvim-treesitter/nvim-treesitter/issues

if vim.fn.has("nvim-0.12") ~= 1 then return end

local ok, query = pcall(require, "vim.treesitter.query")
if not ok then return end

local opts = { force = true }

local non_filetype_aliases = {
  ex = "elixir", pl = "perl", sh = "bash", uxn = "uxntal", ts = "typescript",
}

local html_type_languages = {
  ["importmap"] = "json",
  ["module"] = "javascript",
  ["application/ecmascript"] = "javascript",
  ["text/ecmascript"] = "javascript",
}

local function resolve_lang(alias)
  local ft = vim.filetype.match { filename = "a." .. alias }
  return ft or non_filetype_aliases[alias] or alias
end

local function first_node(match, id)
  local nodes = match[id]
  if not nodes then return nil end
  return nodes[1]
end

query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
  local node = first_node(match, pred[2])
  if not node then return end
  metadata["injection.language"] = resolve_lang(vim.treesitter.get_node_text(node, bufnr):lower())
end, opts)

query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
  local node = first_node(match, pred[2])
  if not node then return end
  local val = vim.treesitter.get_node_text(node, bufnr)
  metadata["injection.language"] = html_type_languages[val]
    or (function() local p = vim.split(val, "/"); return p[#p] end)()
end, opts)

query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
  local id = pred[2]
  local node = first_node(match, id)
  if not node then return end
  local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ""
  metadata[id] = metadata[id] or {}
  metadata[id].text = string.lower(text)
end, opts)

query.add_predicate("nth?", function(match, _, _, pred)
  local node = first_node(match, pred[2])
  local n = tonumber(pred[3])
  if node and node:parent() and node:parent():named_child_count() > n then
    return node:parent():named_child(n) == node
  end
  return false
end, opts)

query.add_predicate("kind-eq?", function(match, _, _, pred)
  local node = first_node(match, pred[2])
  if not node then return true end
  return vim.tbl_contains({ unpack(pred, 3) }, node:type())
end, opts)
