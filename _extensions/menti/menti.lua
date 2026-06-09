-- menti.lua  –  uses Pandoc() to guarantee meta is read before headers

local function stringify(v)
  if v == nil then return nil end
  local s = tostring(pandoc.utils.stringify(v))
  local stripped = s:match("%[([^%]]+)%]%(")
  return stripped or s
end

local function has_class(h, cls)
  for _, c in ipairs(h.classes) do if c == cls then return true end end
  return false
end

function Pandoc(doc)
  local meta = doc.meta

  local MENTI_URL         = stringify(meta["menti_url"])         or nil
  local MENTI_DISPLAY_URL = stringify(meta["menti_display_url"]) or "www.menti.com"
  local MENTI_CODE        = stringify(meta["menti_code"])        or ""
  local MENTI_QR          = stringify(meta["menti_qr"])          or "img/menti-qr.png"

  io.stderr:write("[menti.lua] code='" .. MENTI_CODE .. "' url='" .. MENTI_DISPLAY_URL .. "'\n")

  local STYLE_URL  = 'style="font-size:24px;font-weight:600;color:#5f5f5f;text-align:center;margin:0;"'
  local STYLE_CODE = 'class="big-word" style="text-align:center;white-space:nowrap;display:block;"'
  local STYLE_LOGIN_CODE = 'class="menti-code"'

  doc = doc:walk({
    Header = function(h)

      -- ── Menti question slides ────────────────────────────────────────
      if h.attributes["data-menti"] == "true" then
        h.attributes["data-menti"] = nil
        if MENTI_URL then
          h.attributes["data-background-iframe"]      = MENTI_URL
          h.attributes["data-background-interactive"] = "true"
        end

        local panel = '<div class="menti-panel">' ..
          '<img style="width:175px;height:175px;object-fit:contain;display:block;" src="' .. MENTI_QR .. '" alt="QR">' ..
          '<div ' .. STYLE_URL  .. '>' .. MENTI_DISPLAY_URL .. '</div>' ..
          '<div ' .. STYLE_CODE .. '>' .. tostring(MENTI_CODE) .. '</div>' ..
          '</div>'

        return pandoc.Blocks { h, pandoc.RawBlock("html", panel) }
      end

      -- ── Login slide ──────────────────────────────────────────────────
      if has_class(h, "menti-login") then
        local intro = h.attributes["intro"] or "Farðu inn áður en við byrjum"
        h.attributes["intro"] = nil

        local html = '<div>' ..
          '<span class="kicker">Menti</span>' ..
          '<h2>' .. intro .. '</h2>' ..
          '<div class="menti-url">' .. MENTI_DISPLAY_URL .. '</div>' ..
          '<div ' .. STYLE_LOGIN_CODE .. '>' .. tostring(MENTI_CODE) .. '</div>' ..
          '</div>' ..
          '<img class="menti-qr" src="' .. MENTI_QR .. '" alt="QR-kóði fyrir Menti">'

        return pandoc.Blocks { h, pandoc.RawBlock("html", html) }
      end
    end
  })

  return doc
end
