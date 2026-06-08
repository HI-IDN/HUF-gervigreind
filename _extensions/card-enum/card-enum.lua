local function has_class(classes, wanted)
  for _, class in ipairs(classes) do
    if class == wanted then
      return true
    end
  end
  return false
end

local function render_blocks(blocks)
  return pandoc.write(pandoc.Pandoc(blocks), "html"):gsub("%s+$", "")
end

local function html_escape(text)
  text = tostring(text or "")
  text = text:gsub("&", "&amp;")
  text = text:gsub("<", "&lt;")
  text = text:gsub(">", "&gt;")
  text = text:gsub('"', "&quot;")
  return text
end

-- Renders a numbered card (card-enum)
local function item_html(number, blocks)
  return '<div class="card enum-card">' ..
    "<h3>" .. tostring(number) .. "</h3>" ..
    '<div class="card-enum-body">' .. render_blocks(blocks) .. "</div>" ..
    "</div>"
end

-- Renders an FA-icon card (fa-card)
-- Expects list item text in the form:  icon-name | Title | Body text
-- Optional family prefix:  [brands] spotify | …  or  [regular] heart | …
-- Default family is fa-solid.
local function fa_item_html(_, blocks)
  local text = pandoc.utils.stringify(blocks)
  local icon_part, title, body = text:match("^%s*([^|]+)%s*|%s*([^|]+)%s*|%s*(.+)%s*$")

  if not icon_part or not title or not body then
    return '<div class="card fa-card-item">' ..
      '<div class="fa-card-icon"><i class="fa-solid fa-circle-exclamation fa-fw box-icon"></i></div>' ..
      '<div class="fa-card-body"><h3>Villa</h3><p>Notaðu: icon | titill | texti</p></div>' ..
      "</div>"
  end

  -- Detect optional [family] prefix, e.g. [brands] or [regular]
  local family = "fa-solid"
  local icon = icon_part:gsub("^%s+", ""):gsub("%s+$", "")
  local prefix, rest = icon:match("^%[([^%]]+)%]%s*(.+)$")
  if prefix then
    family = "fa-" .. prefix
    icon   = rest
  end

  -- Strip any stray fa- prefix left in the icon name
  icon = icon:gsub("^fa%-%a+%s+", ""):gsub("^fa%-", ""):gsub("%s+$", "")

  return '<div class="card fa-card-item">' ..
    '<div class="fa-card-icon"><i class="' .. family .. ' fa-' .. html_escape(icon) .. ' fa-fw box-icon"></i></div>' ..
    '<div class="fa-card-body"><h3>' .. html_escape(title) .. "</h3><p>" .. html_escape(body) .. "</p></div>" ..
    "</div>"
end

-- Wraps a list of rendered item strings into a row div
local function row_html(items, row_class)
  if #items == 0 then return "" end
  return '<div class="' .. row_class .. '" style="--card-enum-cols: ' .. tostring(#items) .. ';">' ..
    table.concat(items, "\n") ..
    "</div>"
end

-- Collects all list items from a div's content, then chunks them into
-- rows of `cols` items.  HorizontalRule blocks are ignored (they are
-- produced by `---` which Quarto revealjs treats as a slide break, so
-- they never arrive at this filter reliably).
local function render_card_rows(div, item_renderer, wrapper_class, row_class)
  -- Allow per-block column override via  ::: {.card-enum cols=4}
  local cols = tonumber(div.attributes and div.attributes["cols"]) or 3

  -- Collect every rendered item in order
  local all_items = {}
  local number = 1

  for _, block in ipairs(div.content) do
    if block.t == "OrderedList" or block.t == "BulletList" then
      for _, item in ipairs(block.content) do
        table.insert(all_items, item_renderer(number, item))
        number = number + 1
      end
    elseif block.t ~= "Null" and block.t ~= "HorizontalRule" then
      table.insert(all_items, item_renderer(number, { block }))
      number = number + 1
    end
    -- HorizontalRule is silently skipped
  end

  -- Chunk into rows
  local rows = {}
  local i = 1
  while i <= #all_items do
    local row = {}
    for j = i, math.min(i + cols - 1, #all_items) do
      table.insert(row, all_items[j])
    end
    table.insert(rows, row_html(row, row_class))
    i = i + cols
  end

  return pandoc.RawBlock("html",
    '<div class="' .. wrapper_class .. '">' .. table.concat(rows, "\n") .. "</div>")
end

-- Renders a chevron step (for .steps diagrams)
local function step_chip_html(index, blocks)
  local text = pandoc.utils.stringify(blocks)
  local label, desc = text:match("^%s*([^|]+)%s*|%s*(.+)%s*$")
  if not label then
    label = text:gsub("^%s+", ""):gsub("%s+$", "")
    desc = nil
  end
  label = label:gsub("%s+$", "")
  local inner = "<strong>" .. html_escape(label) .. "</strong>"
  if desc then
    inner = inner .. "<span>" .. html_escape(desc:gsub("%s+$", "")) .. "</span>"
  end
  return '<div class="step-chip" data-step="' .. tostring(index) .. '">' .. inner .. "</div>"
end

function Div(div)
  if has_class(div.classes, "card-enum") then
    return render_card_rows(div, item_html, "card-enum", "card-enum-row")
  end

  if has_class(div.classes, "fa-card") then
    return render_card_rows(div, fa_item_html, "fa-card", "fa-card-row")
  end

  if has_class(div.classes, "steps") then
    local chips = {}
    local i = 1
    for _, block in ipairs(div.content) do
      if block.t == "BulletList" or block.t == "OrderedList" then
        for _, item in ipairs(block.content) do
          table.insert(chips, step_chip_html(i, item))
          i = i + 1
        end
      elseif block.t ~= "Null" and block.t ~= "HorizontalRule" then
        table.insert(chips, step_chip_html(i, { block }))
        i = i + 1
      end
    end
    return pandoc.RawBlock("html",
      '<div class="steps-row" style="--steps-count: ' .. tostring(#chips) .. ';">' ..
      table.concat(chips, "") .. "</div>")
  end

  return nil
end
