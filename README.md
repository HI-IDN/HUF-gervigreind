# HUF-gervigreind

Kennsluefni fyrir Háskóla unga fólksins um gervigreind, gagnavísindi, spunagreind og hvernig ChatGPT spáir fyrir um líklegt framhald texta.

Glærurnar eru skrifaðar í Quarto:

- [`slides.qmd`](slides.qmd) — aðalglærurnar, hannaðar sem RevealJS kynning í HÍ26 hönnunarstaðli
- [`styles/hi26-reveal.css`](styles/hi26-reveal.css) — HÍ26 stíll fyrir RevealJS glærurnar
- [`menti.md`](menti.md) — yfirlit yfir Menti-spurningar og hvaða Mentimeter question type á að velja
- [`img/`](img/) — lógó, að AI-generated myndir

## Breyta glærunum

Breyttu [`slides.qmd`](slides.qmd). Glærur eru aðskildar með `---`.

Stíllinn er skilgreindur í [`styles/hi26-reveal.css`](styles/hi26-reveal.css). `slides.qmd` vísar í skrána í Quarto YAML með `css: styles/hi26-reveal.css`.

Þar eru HÍ26 litirnir og Jost letrið:

- aðallitur HÍ: `#10099F`
- stoðlitir: `#2DD2C0`, `#00FFBA`, `#FAC55B`, `#FC8484`, `#FFA05F`
- gráir fletir: `#F5F5F5`, `#EEEEEE`
- texti: `#262626`

## Þýða og skoða

Til að þýða:

```bash
quarto render slides.qmd --output index.html
```

Til að skoða staðbundið — opnaðu **ekki** `index.html` beint í vafra (`file://`). Chrome leyfir ekki Mentimeter iframes af `file://`. Keyrðu vefþjón í staðinn:

```bash
python -m http.server 8080
```

Opnaðu síðan [http://localhost:8080/index.html](http://localhost:8080/index.html).

## Birta á GitHub Pages

Síðan er hýst á: https://hi-idn.github.io/HUF-gervigreind/

GitHub Pages þjónar `index.html` sjálfkrafa úr rótinni á `main` branch. Til að uppfæra útgáfuna sem birtist á GitHub Pages skaltu rendera `slides.qmd` yfir í `index.html`:

```bash
quarto render slides.qmd --output index.html
```

Síðan uppfærist sjálfkrafa eftir nokkrar mínútur eftir hvert `git push`.

**Uppsetning GitHub Pages** (þarf aðeins að gera einu sinni):

1. Farðu á **Settings → Pages** í GitHub repoinu
2. Undir *Source*: veldu **Deploy from a branch**
3. Branch: `main` — mappa: `/ (root)` — smelltu **Save**

## Menti

Allar Menti-spurningar eru teknar saman í [`menti.md`](menti.md). Þar kemur fram:

- hvar spurningin tengist í fyrirlestrinum
- íslenski spurningatextinn
- enska Mentimeter-heitið sem á að velja, t.d. **Word Cloud**, **Open Ended**, **Multiple Choice** eða **Ranking**

## Myndir

Eru búnar til með *Gemini 3.5 Flash*, Google, 7. júní 2026, https://gemini.google.com.

## Lyklaborðsstýringar

| Lykill        | Aðgerð                           |
|---------------|----------------------------------|
| `→` / `Space` | Næsta glæra                      |
| `←`           | Fyrri glæra                      |
| `F`           | Kveikja/slökkva á fullskjá       |
| `S`           | Opna kynningarsýn (speaker view) |
| `Esc`         | Yfirlit yfir allar glærur        |
