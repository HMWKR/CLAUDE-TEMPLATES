# CSS Evaluate Snippets (22개)

> Lead가 Stage 1 데이터 수집 시 `browser_evaluate`로 실행하는 JavaScript IIFE 스니펫.
> 각 스니펫은 JSON을 반환하며, `pass: boolean` 필드로 자동 판정을 포함한다.
> **SSOT**: 모든 TM은 이 파일의 스니펫 결과만 참조한다.

---

## 기존 스니펫 (16개)

### T-1: Body Font Size (본문 16px 이상)

```javascript
(function(){
  const body = document.body;
  const cs = window.getComputedStyle(body);
  const fontSize = parseFloat(cs.fontSize);
  return {
    bodyFontSize: cs.fontSize,
    bodyFontSizePx: fontSize,
    pass: fontSize >= 16,
    bodyFontFamily: cs.fontFamily
  };
})()
```

### T-2: Heading Ratio (H1 2-2.5x, H2 1.5-1.75x, H3 1.25-1.5x)

```javascript
(function(){
  const body = document.body;
  const base = parseFloat(window.getComputedStyle(body).fontSize);
  const headings = {};
  ['h1','h2','h3','h4','h5','h6'].forEach(tag => {
    const el = document.querySelector(tag);
    if(el) {
      const size = parseFloat(window.getComputedStyle(el).fontSize);
      headings[tag] = { fontSize: size + 'px', ratio: +(size/base).toFixed(2) };
    }
  });
  const h1r = headings.h1?.ratio || 0;
  const h2r = headings.h2?.ratio || 0;
  const h3r = headings.h3?.ratio || 0;
  return {
    baseFontSize: base + 'px',
    headings,
    h1Pass: h1r >= 2.0 && h1r <= 2.5,
    h2Pass: h2r >= 1.5 && h2r <= 1.75,
    h3Pass: h3r >= 1.25 && h3r <= 1.5,
    hierarchyCorrect: h1r > h2r && h2r > h3r
  };
})()
```

### T-3: Input Font Size (16px 이상, iOS 줌 방지)

```javascript
(function(){
  const inputs = document.querySelectorAll('input, textarea, select');
  const results = [];
  inputs.forEach((el, i) => {
    if(i < 10) {
      const cs = window.getComputedStyle(el);
      const size = parseFloat(cs.fontSize);
      results.push({
        tag: el.tagName.toLowerCase(),
        type: el.type || 'text',
        fontSize: size + 'px',
        pass: size >= 16
      });
    }
  });
  return { inputCount: inputs.length, samples: results, allPass: results.every(r => r.pass) };
})()
```

### T-4: Line-Height Ratios (본문 1.4-1.8, 제목 1.1-1.4)

```javascript
(function(){
  const elements = [
    { sel: 'p', name: 'paragraph', ideal: [1.4, 1.8] },
    { sel: 'h1', name: 'h1', ideal: [1.1, 1.3] },
    { sel: 'h2', name: 'h2', ideal: [1.2, 1.4] },
    { sel: 'li', name: 'listItem', ideal: [1.4, 1.8] }
  ];
  const results = {};
  elements.forEach(({ sel, name, ideal }) => {
    const el = document.querySelector(sel);
    if(el) {
      const cs = window.getComputedStyle(el);
      const lh = parseFloat(cs.lineHeight);
      const fs = parseFloat(cs.fontSize);
      const ratio = lh / fs;
      results[name] = {
        lineHeight: cs.lineHeight,
        fontSize: cs.fontSize,
        ratio: +ratio.toFixed(2),
        pass: ratio >= ideal[0] && ratio <= ideal[1]
      };
    }
  });
  return results;
})()
```

### T-5: Paragraph Max-Width (35-80 chars)

```javascript
(function(){
  const p = document.querySelector('p');
  if(!p) return { found: false };
  const cs = window.getComputedStyle(p);
  const widthPx = p.getBoundingClientRect().width;
  const fontSize = parseFloat(cs.fontSize);
  const charsPerLine = Math.round(widthPx / (fontSize * 0.5));
  return {
    widthPx: +widthPx.toFixed(0),
    fontSize: fontSize + 'px',
    estimatedCharsPerLine: charsPerLine,
    maxWidth: cs.maxWidth,
    pass: charsPerLine >= 35 && charsPerLine <= 80
  };
})()
```

### S-1: Component Padding Consistency

```javascript
(function(){
  const buttons = document.querySelectorAll('button, [role="button"], a.btn, .button');
  const cards = document.querySelectorAll('.card, [class*="card"], article');
  const measure = (els, name) => {
    const paddings = new Set();
    const samples = [];
    Array.from(els).slice(0, 8).forEach(el => {
      const cs = window.getComputedStyle(el);
      const pad = `${cs.paddingTop} ${cs.paddingRight} ${cs.paddingBottom} ${cs.paddingLeft}`;
      paddings.add(pad);
      samples.push({ tag: el.tagName, class: el.className?.toString().substring(0,30), padding: pad });
    });
    return { count: els.length, uniquePaddings: paddings.size, consistent: paddings.size <= 2, samples };
  };
  return { buttons: measure(buttons, 'button'), cards: measure(cards, 'card') };
})()
```

### S-2: Grid/Spacing System (4px/8px 배수)

```javascript
(function(){
  const elements = document.querySelectorAll('main > *, section > *, .container > *');
  const margins = new Set(); const paddings = new Set(); const gaps = new Set();
  Array.from(elements).slice(0, 20).forEach(el => {
    const cs = window.getComputedStyle(el);
    [cs.marginTop, cs.marginBottom, cs.marginLeft, cs.marginRight].forEach(v => {
      const px = parseFloat(v); if(px > 0) margins.add(px);
    });
    [cs.paddingTop, cs.paddingBottom, cs.paddingLeft, cs.paddingRight].forEach(v => {
      const px = parseFloat(v); if(px > 0) paddings.add(px);
    });
    if(cs.gap && cs.gap !== 'normal') gaps.add(parseFloat(cs.gap));
  });
  const check = (vals) => {
    const arr = [...vals];
    const on4 = arr.filter(v => v % 4 === 0).length;
    const on8 = arr.filter(v => v % 8 === 0).length;
    return { values: arr.sort((a,b) => a-b), total: arr.length, on4pxGrid: on4, on8pxGrid: on8,
      gridCompliance: arr.length > 0 ? +(on4/arr.length*100).toFixed(0) + '%' : 'N/A' };
  };
  return { margins: check(margins), paddings: check(paddings), gaps: check(gaps) };
})()
```

### C-1: Text-Background Contrast (WCAG 4.5:1)

```javascript
(function(){
  function luminance(r, g, b) {
    const [rs, gs, bs] = [r, g, b].map(c => { c /= 255; return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4); });
    return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs;
  }
  function parseColor(str) {
    const m = str.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/);
    return m ? [+m[1], +m[2], +m[3]] : null;
  }
  function contrastRatio(fg, bg) {
    const l1 = luminance(...fg), l2 = luminance(...bg);
    const lighter = Math.max(l1, l2), darker = Math.min(l1, l2);
    return +((lighter + 0.05) / (darker + 0.05)).toFixed(2);
  }
  const samples = [];
  document.querySelectorAll('p, h1, h2, h3, a, span, li, button, label').forEach((el, i) => {
    if(i >= 15) return;
    const cs = window.getComputedStyle(el);
    const fg = parseColor(cs.color);
    const bg = parseColor(cs.backgroundColor) || parseColor(window.getComputedStyle(document.body).backgroundColor);
    if(fg && bg) {
      const ratio = contrastRatio(fg, bg);
      const size = parseFloat(cs.fontSize);
      const isLarge = size >= 18.66 || (size >= 14 && cs.fontWeight >= 700);
      const required = isLarge ? 3 : 4.5;
      samples.push({
        tag: el.tagName, text: el.textContent?.substring(0,20),
        color: cs.color, bgColor: cs.backgroundColor,
        ratio, required, pass: ratio >= required, isLargeText: isLarge
      });
    }
  });
  return { sampleCount: samples.length, allPass: samples.every(s => s.pass), failures: samples.filter(s => !s.pass), samples };
})()
```

### C-2: Focus Ring Visibility (동적 검증)

```javascript
(function(){
  const interactive = document.querySelectorAll('a, button, input, select, textarea, [tabindex]');
  const results = [];
  Array.from(interactive).slice(0, 10).forEach((el, i) => {
    const before = window.getComputedStyle(el);
    const boxShadowBefore = before.boxShadow;
    el.focus();
    const after = window.getComputedStyle(el);
    const hasOutlineChange = after.outlineStyle !== 'none' && after.outlineWidth !== '0px';
    const hasShadowChange = after.boxShadow !== 'none' && after.boxShadow !== boxShadowBefore;
    results.push({
      tag: el.tagName, type: el.type || '',
      focusOutline: after.outline, focusOutlineOffset: after.outlineOffset,
      focusBoxShadow: after.boxShadow !== 'none' ? after.boxShadow?.substring(0,50) : 'none',
      visible: hasOutlineChange || hasShadowChange
    });
    el.blur();
  });
  return { interactiveCount: interactive.length, samples: results, allVisible: results.every(r => r.visible) };
})()
```

### M-1: Modal/Dialog Detection

```javascript
(function(){
  const modals = document.querySelectorAll('[role="dialog"], [role="alertdialog"], dialog, .modal, [class*="modal"], [class*="overlay"]');
  const results = [];
  modals.forEach((el, i) => {
    if(i >= 5) return;
    const cs = window.getComputedStyle(el);
    results.push({
      tag: el.tagName, role: el.getAttribute('role'), ariaModal: el.getAttribute('aria-modal'),
      ariaLabel: el.getAttribute('aria-label') || el.getAttribute('aria-labelledby'),
      display: cs.display, visibility: cs.visibility, zIndex: cs.zIndex
    });
  });
  return { count: modals.length, samples: results };
})()
```

### M-2: Component Variety

```javascript
(function(){
  const components = {
    buttons: document.querySelectorAll('button, [role="button"], input[type="submit"]').length,
    links: document.querySelectorAll('a[href]').length,
    inputs: document.querySelectorAll('input, textarea, select').length,
    images: document.querySelectorAll('img, picture, svg').length,
    lists: document.querySelectorAll('ul, ol').length,
    tables: document.querySelectorAll('table').length,
    forms: document.querySelectorAll('form').length,
    navs: document.querySelectorAll('nav').length,
    headings: document.querySelectorAll('h1,h2,h3,h4,h5,h6').length,
    sections: document.querySelectorAll('section, article, aside, main').length
  };
  return components;
})()
```

### ANIM-1: Animation/Transition Metrics

```javascript
(function(){
  const allEls = document.querySelectorAll('*');
  const transitions = []; const animations = [];
  let reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  Array.from(allEls).slice(0, 200).forEach(el => {
    const cs = window.getComputedStyle(el);
    if(cs.transitionProperty && cs.transitionProperty !== 'all' && cs.transitionProperty !== 'none') {
      transitions.push({
        tag: el.tagName, class: el.className?.toString().substring(0,30),
        property: cs.transitionProperty, duration: cs.transitionDuration,
        timingFunction: cs.transitionTimingFunction, delay: cs.transitionDelay
      });
    }
    if(cs.animationName && cs.animationName !== 'none') {
      animations.push({
        tag: el.tagName, class: el.className?.toString().substring(0,30),
        name: cs.animationName, duration: cs.animationDuration,
        timingFunction: cs.animationTimingFunction, iterationCount: cs.animationIterationCount
      });
    }
  });
  const durations = [...transitions, ...animations].map(t => parseFloat(t.duration) * 1000);
  return {
    transitionCount: transitions.length, animationCount: animations.length,
    prefersReducedMotion: reducedMotion,
    durationStats: durations.length ? {
      min: Math.min(...durations) + 'ms', max: Math.max(...durations) + 'ms',
      avg: +(durations.reduce((a,b)=>a+b,0)/durations.length).toFixed(0) + 'ms'
    } : null,
    transitions: transitions.slice(0, 10), animations: animations.slice(0, 10)
  };
})()
```

### DS-1: Design System Consistency

```javascript
(function(){
  const measure = (selector, name) => {
    const els = document.querySelectorAll(selector);
    const styles = new Map();
    Array.from(els).slice(0, 15).forEach(el => {
      const cs = window.getComputedStyle(el);
      const key = `${cs.backgroundColor}|${cs.color}|${cs.fontSize}|${cs.fontWeight}|${cs.borderRadius}|${cs.padding}`;
      styles.set(key, (styles.get(key)||0) + 1);
    });
    return { count: els.length, uniqueVariants: styles.size, variants: [...styles.entries()].map(([k,v]) => ({ style: k, count: v })).sort((a,b) => b.count - a.count).slice(0, 5) };
  };
  const cssVars = [];
  try {
    for(const sheet of document.styleSheets) {
      try {
        for(const rule of sheet.cssRules) {
          if(rule.selectorText === ':root' || rule.selectorText === ':root, :host') {
            const text = rule.cssText;
            const matches = text.match(/--[\w-]+/g);
            if(matches) cssVars.push(...matches);
          }
        }
      } catch(e) {}
    }
  } catch(e) {}
  return {
    buttons: measure('button, [role="button"], .btn, [class*="btn"]', 'button'),
    cards: measure('.card, [class*="card"], article', 'card'),
    inputs: measure('input, textarea, select', 'input'),
    cssCustomProperties: { count: cssVars.length, samples: cssVars.slice(0, 20) }
  };
})()
```

### NAV-1: Navigation Structure

```javascript
(function(){
  const navs = document.querySelectorAll('nav');
  const navData = [];
  navs.forEach((nav, i) => {
    if(i >= 5) return;
    const links = nav.querySelectorAll('a');
    navData.push({
      ariaLabel: nav.getAttribute('aria-label') || nav.getAttribute('aria-labelledby'),
      role: nav.getAttribute('role'),
      linkCount: links.length,
      links: Array.from(links).slice(0, 10).map(a => ({ text: a.textContent?.trim().substring(0,30), href: a.getAttribute('href')?.substring(0,50) }))
    });
  });
  const skipLink = document.querySelector('a[href^="#main"], a[href^="#content"], .skip-link, .skip-nav');
  const breadcrumb = document.querySelector('[aria-label*="breadcrumb"], [aria-label*="Breadcrumb"], .breadcrumb, nav.breadcrumbs');
  const headerLinks = document.querySelectorAll('header a, [role="banner"] a');
  const footerLinks = document.querySelectorAll('footer a, [role="contentinfo"] a');
  return {
    navCount: navs.length, navs: navData,
    skipLink: skipLink ? { found: true, href: skipLink.getAttribute('href'), text: skipLink.textContent?.trim() } : { found: false },
    breadcrumb: breadcrumb ? { found: true, ariaLabel: breadcrumb.getAttribute('aria-label') } : { found: false },
    headerLinkCount: headerLinks.length, footerLinkCount: footerLinks.length,
    millersLaw: navData.every(n => n.linkCount <= 9)
  };
})()
```

### FORM-1: Form UX Analysis

```javascript
(function(){
  const forms = document.querySelectorAll('form');
  const formData = [];
  forms.forEach((form, fi) => {
    if(fi >= 5) return;
    const fields = form.querySelectorAll('input, textarea, select');
    const fieldData = [];
    fields.forEach((field, i) => {
      if(i >= 15) return;
      const label = field.labels?.[0] || document.querySelector(`label[for="${field.id}"]`);
      const ariaLabel = field.getAttribute('aria-label') || field.getAttribute('aria-labelledby');
      fieldData.push({
        tag: field.tagName.toLowerCase(), type: field.type || 'text',
        name: field.name, id: field.id,
        hasLabel: !!label, labelText: label?.textContent?.trim().substring(0,30),
        hasAriaLabel: !!ariaLabel,
        placeholder: field.placeholder?.substring(0,30),
        required: field.required || field.getAttribute('aria-required') === 'true',
        autocomplete: field.getAttribute('autocomplete'),
        pattern: field.getAttribute('pattern'),
        inputmode: field.getAttribute('inputmode')
      });
    });
    const errorMsgs = form.querySelectorAll('[class*="error"], [class*="invalid"], [role="alert"], .field-error');
    formData.push({
      action: form.action?.substring(0,50), method: form.method,
      fieldCount: fields.length, fields: fieldData,
      hasNovalidate: form.hasAttribute('novalidate'),
      errorMessageCount: errorMsgs.length,
      submitButton: form.querySelector('button[type="submit"], input[type="submit"]') ? true : false
    });
  });
  const standaloneInputs = document.querySelectorAll('input:not(form input), textarea:not(form textarea)');
  return {
    formCount: forms.length, forms: formData,
    standaloneInputCount: standaloneInputs.length,
    labelsConnected: formData.every(f => f.fields.every(fd => fd.hasLabel || fd.hasAriaLabel))
  };
})()
```

### A-1: Comprehensive CSS Snapshot (종합 수집)

```javascript
(function(){
  const body = document.body;
  const p = document.querySelector('p');
  const h1 = document.querySelector('h1');
  const input = document.querySelector('input');
  const btn = document.querySelector('button');
  const cs = (el) => el ? window.getComputedStyle(el) : null;
  return {
    typography: {
      bodyFontSize: cs(p)?.fontSize || cs(body)?.fontSize,
      bodyLineHeight: cs(p)?.lineHeight,
      bodyFontFamily: cs(p)?.fontFamily?.split(',')[0],
      h1FontSize: cs(h1)?.fontSize,
      inputFontSize: cs(input)?.fontSize
    },
    spacing: {
      bodyPadding: cs(body)?.padding,
      bodyMargin: cs(body)?.margin,
      buttonPadding: cs(btn) ? `${cs(btn).paddingTop} ${cs(btn).paddingRight} ${cs(btn).paddingBottom} ${cs(btn).paddingLeft}` : null
    },
    color: {
      bodyColor: cs(body)?.color,
      bodyBg: cs(body)?.backgroundColor,
      linkColor: cs(document.querySelector('a'))?.color,
      buttonBg: cs(btn)?.backgroundColor
    },
    viewport: {
      width: window.innerWidth,
      height: window.innerHeight,
      devicePixelRatio: window.devicePixelRatio
    },
    meta: {
      viewport: document.querySelector('meta[name="viewport"]')?.content,
      charset: document.characterSet,
      title: document.title?.substring(0, 50)
    }
  };
})()
```

---

## 신규 Design Quality 스니펫 (6개)

### DQ-1: Font Quality (폰트 품질 분석)

> 담당 TM: TM7 (Typography & Color Quality)
> 체크리스트: S-01~S-04, S-10~S-13

```javascript
(function(){
  // 제네릭/저품질 폰트 목록
  const GENERIC_FONTS = ['arial','helvetica','times new roman','times','courier new','courier',
    'verdana','georgia','comic sans ms','impact','trebuchet ms','tahoma','lucida console'];
  const SYSTEM_STACKS = ['system-ui','-apple-system','blinkmacsystemfont','segoe ui','roboto',
    'inter','noto sans','open sans','lato','source sans','oxygen','ubuntu','cantarell','fira sans'];

  // 모든 텍스트 요소에서 font-family 수집
  const fontFamilies = new Map(); // family -> { count, elements }
  const els = document.querySelectorAll('h1,h2,h3,h4,h5,h6,p,span,a,li,button,label,input,td,th,blockquote');
  Array.from(els).slice(0, 100).forEach(el => {
    const cs = window.getComputedStyle(el);
    const primary = cs.fontFamily.split(',')[0].trim().replace(/['"]/g, '').toLowerCase();
    if(!fontFamilies.has(primary)) fontFamilies.set(primary, { count: 0, tags: new Set() });
    const entry = fontFamilies.get(primary);
    entry.count++;
    entry.tags.add(el.tagName);
  });

  // Display vs Body 페어링 분석
  const headingFonts = new Set();
  const bodyFonts = new Set();
  document.querySelectorAll('h1,h2,h3').forEach(el => {
    headingFonts.add(window.getComputedStyle(el).fontFamily.split(',')[0].trim().replace(/['"]/g, '').toLowerCase());
  });
  document.querySelectorAll('p,li,span').forEach(el => {
    bodyFonts.add(window.getComputedStyle(el).fontFamily.split(',')[0].trim().replace(/['"]/g, '').toLowerCase());
  });

  // 모듈러 스케일 분석
  const fontSizes = new Set();
  document.querySelectorAll('h1,h2,h3,h4,h5,h6,p').forEach(el => {
    fontSizes.add(parseFloat(window.getComputedStyle(el).fontSize));
  });
  const sizeArr = [...fontSizes].sort((a,b) => a-b);
  const ratios = [];
  for(let i = 1; i < sizeArr.length; i++) {
    ratios.push(+(sizeArr[i] / sizeArr[i-1]).toFixed(3));
  }
  const avgRatio = ratios.length ? +(ratios.reduce((a,b)=>a+b,0)/ratios.length).toFixed(3) : 0;
  const ratioVariance = ratios.length ? +(Math.max(...ratios) - Math.min(...ratios)).toFixed(3) : 0;

  // H1/body 비율
  const h1 = document.querySelector('h1');
  const bodyP = document.querySelector('p');
  const h1Size = h1 ? parseFloat(window.getComputedStyle(h1).fontSize) : 0;
  const bodySize = bodyP ? parseFloat(window.getComputedStyle(bodyP).fontSize) : 16;
  const h1BodyRatio = bodySize > 0 ? +(h1Size / bodySize).toFixed(2) : 0;

  // 제네릭 폰트 사용 여부
  const allFonts = [...fontFamilies.keys()];
  const genericUsed = allFonts.filter(f => GENERIC_FONTS.includes(f));
  const systemUsed = allFonts.filter(f => SYSTEM_STACKS.includes(f));
  const uniqueFontCount = allFonts.filter(f => !['sans-serif','serif','monospace','cursive','fantasy','inherit'].includes(f)).length;

  return {
    fonts: Object.fromEntries([...fontFamilies.entries()].map(([k,v]) => [k, { count: v.count, tags: [...v.tags] }])),
    uniqueFontCount,
    genericFontsUsed: genericUsed,
    systemStacksUsed: systemUsed,
    hasGenericFont: genericUsed.length > 0,
    displayBodyPairing: {
      headingFonts: [...headingFonts],
      bodyFonts: [...bodyFonts],
      hasPairing: headingFonts.size > 0 && bodyFonts.size > 0 && ![...headingFonts].every(f => bodyFonts.has(f))
    },
    typeScale: {
      sizes: sizeArr.map(s => s + 'px'),
      ratios,
      avgRatio,
      ratioVariance,
      isModular: ratioVariance <= 0.15 && ratios.length >= 3
    },
    h1BodyRatio,
    h1BodyRatioPass: h1BodyRatio >= 2.5,
    fontCountPass: uniqueFontCount <= 3
  };
})()
```

### DQ-2: Color Distribution (색상 분포 분석)

> 담당 TM: TM7 (Typography & Color Quality)
> 체크리스트: S-05~S-09, S-14~S-25

```javascript
(function(){
  // oklch/hsl/rgb 파싱 → Hue 추출
  function extractHue(colorStr) {
    // oklch
    let m = colorStr.match(/oklch\([\d.]+\s+[\d.]+\s+([\d.]+)/);
    if(m) return +m[1];
    // hsl
    m = colorStr.match(/hsla?\(([\d.]+)/);
    if(m) return +m[1];
    // rgb → hue 변환
    m = colorStr.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/);
    if(m) {
      const r = +m[1]/255, g = +m[2]/255, b = +m[3]/255;
      const max = Math.max(r,g,b), min = Math.min(r,g,b);
      if(max === min) return 0;
      let h;
      if(max === r) h = ((g-b)/(max-min)) % 6;
      else if(max === g) h = (b-r)/(max-min) + 2;
      else h = (r-g)/(max-min) + 4;
      h = Math.round(h * 60);
      return h < 0 ? h + 360 : h;
    }
    return null;
  }

  function isChromatic(colorStr) {
    const m = colorStr.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/);
    if(!m) return false;
    const r = +m[1], g = +m[2], b = +m[3];
    return !(r === g && g === b); // 무채색이 아님
  }

  // 모든 요소에서 색상 수집
  const colorMap = new Map(); // hue-bucket -> count
  const rawColors = new Map(); // color string -> count
  const bgColors = new Map();
  const els = document.querySelectorAll('*');
  Array.from(els).slice(0, 300).forEach(el => {
    const cs = window.getComputedStyle(el);
    [cs.color, cs.backgroundColor, cs.borderColor].forEach(c => {
      if(!c || c === 'rgba(0, 0, 0, 0)' || c === 'transparent') return;
      rawColors.set(c, (rawColors.get(c)||0) + 1);
      if(isChromatic(c)) {
        const hue = extractHue(c);
        if(hue !== null) {
          const bucket = Math.round(hue / 30) * 30; // 30도 버킷
          colorMap.set(bucket, (colorMap.get(bucket)||0) + 1);
        }
      }
    });
    if(cs.backgroundColor && cs.backgroundColor !== 'rgba(0, 0, 0, 0)') {
      bgColors.set(cs.backgroundColor, (bgColors.get(cs.backgroundColor)||0) + 1);
    }
  });

  // 주조색 분석
  const hueBuckets = [...colorMap.entries()].sort((a,b) => b[1] - a[1]);
  const totalChromatic = hueBuckets.reduce((s,e) => s + e[1], 0);
  const dominantHue = hueBuckets[0] || [0, 0];
  const dominantRatio = totalChromatic > 0 ? +(dominantHue[1] / totalChromatic * 100).toFixed(1) : 0;

  // Accent 분석
  const accentHue = hueBuckets[1] || [0, 0];
  const hueDiff = hueBuckets.length >= 2 ? Math.abs(hueBuckets[0][0] - hueBuckets[1][0]) : 0;
  const adjustedDiff = hueDiff > 180 ? 360 - hueDiff : hueDiff;

  // 보라+흰 조합 감지
  const purpleWhiteCombo = (() => {
    let found = false;
    document.querySelectorAll('*').forEach(el => {
      if(found) return;
      const cs = window.getComputedStyle(el);
      const m = cs.color.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/);
      const bm = cs.backgroundColor.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/);
      if(m && bm) {
        const isPurple = (+m[1] > 100 && +m[3] > 100 && +m[2] < 80);
        const isWhiteBg = (+bm[1] > 240 && +bm[2] > 240 && +bm[3] > 240);
        if(isPurple && isWhiteBg) found = true;
      }
    });
    return found;
  })();

  // off-white / off-black 사용 여부
  const bodyBg = window.getComputedStyle(document.body).backgroundColor;
  const bodyBgM = bodyBg.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/);
  const isOffWhite = bodyBgM && (+bodyBgM[1] >= 240 && +bodyBgM[1] <= 253);
  const bodyColor = window.getComputedStyle(document.body).color;
  const bodyColorM = bodyColor.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/);
  const isOffBlack = bodyColorM && (+bodyColorM[1] >= 15 && +bodyColorM[1] <= 50);

  return {
    totalUniqueColors: rawColors.size,
    chromaticHueBuckets: hueBuckets.map(([h,c]) => ({ hue: h + 'deg', count: c })),
    dominant: {
      hue: dominantHue[0] + 'deg',
      ratio: dominantRatio + '%',
      pass: dominantRatio >= 60
    },
    accent: {
      hue: accentHue[0] + 'deg',
      hueDiffFromDominant: adjustedDiff + 'deg',
      pass: adjustedDiff >= 60
    },
    purpleWhiteCombo: { detected: purpleWhiteCombo, pass: !purpleWhiteCombo },
    offWhiteOffBlack: { bodyUsesOffWhite: isOffWhite, bodyUsesOffBlack: isOffBlack },
    colorCount: rawColors.size,
    topColors: [...rawColors.entries()].sort((a,b) => b[1] - a[1]).slice(0, 10).map(([c,n]) => ({ color: c, count: n }))
  };
})()
```

### DQ-3: Layout Pattern (레이아웃 패턴 분석)

> 담당 TM: TM19 (Layout & Brand + Memorability)
> 체크리스트: T-01~T-03, T-09, T-17

```javascript
(function(){
  // 섹션별 레이아웃 구조 분석
  const sections = document.querySelectorAll('section, main > div, [class*="section"], .container > div');
  const layoutPatterns = [];
  const layoutTypes = new Set();

  Array.from(sections).slice(0, 15).forEach(el => {
    const cs = window.getComputedStyle(el);
    const children = el.children;
    const childCount = children.length;

    // 레이아웃 유형 판별
    let type = 'block';
    if(cs.display === 'flex') type = 'flex-' + cs.flexDirection;
    else if(cs.display === 'grid') {
      const cols = cs.gridTemplateColumns;
      type = 'grid-' + (cols.split(' ').length) + 'col';
    }
    layoutTypes.add(type);

    // asymmetry 감지
    let hasAsymmetry = false;
    if(cs.display === 'grid') {
      const cols = cs.gridTemplateColumns.split(' ').map(v => parseFloat(v));
      hasAsymmetry = cols.length > 1 && new Set(cols).size > 1;
    }

    layoutPatterns.push({
      tag: el.tagName,
      class: el.className?.toString().substring(0, 40),
      display: cs.display,
      layoutType: type,
      childCount,
      hasAsymmetry,
      width: el.getBoundingClientRect().width + 'px',
      padding: `${cs.paddingTop} ${cs.paddingRight}`
    });
  });

  // 쿠키 커터 패턴 비율 (card+navbar+sidebar 표준 구성)
  const standardPatterns = document.querySelectorAll(
    '.card, [class*="card"], nav, .sidebar, [class*="sidebar"], .navbar, [class*="navbar"]'
  ).length;
  const totalElements = document.querySelectorAll('section, div[class], main > *').length;
  const cookieCutterRatio = totalElements > 0 ? +(standardPatterns / totalElements * 100).toFixed(1) : 0;

  // 시각적 흐름 방향 추론
  const firstSection = sections[0];
  const lastSection = sections[sections.length - 1];
  let flowPattern = 'unknown';
  if(firstSection && lastSection) {
    const firstRect = firstSection.getBoundingClientRect();
    const lastRect = lastSection.getBoundingClientRect();
    if(firstRect.left < lastRect.left) flowPattern = 'left-to-right';
    else if(firstRect.top < lastRect.top) flowPattern = 'top-to-bottom';
  }

  // Spacing 그리드 위반 수
  let spacingViolations = 0;
  Array.from(sections).slice(0, 20).forEach(el => {
    const cs = window.getComputedStyle(el);
    [cs.marginTop, cs.marginBottom, cs.paddingTop, cs.paddingBottom, cs.gap].forEach(v => {
      const px = parseFloat(v);
      if(px > 0 && px % 4 !== 0) spacingViolations++;
    });
  });

  return {
    sectionCount: sections.length,
    layoutTypes: [...layoutTypes],
    layoutDiversity: layoutTypes.size,
    layoutDiversityPass: layoutTypes.size >= 3,
    patterns: layoutPatterns.slice(0, 8),
    cookieCutterRatio: cookieCutterRatio + '%',
    cookieCutterPass: cookieCutterRatio <= 60,
    hasAsymmetry: layoutPatterns.some(p => p.hasAsymmetry),
    flowPattern,
    spacingViolations,
    spacingPass: spacingViolations <= 5
  };
})()
```

### DQ-4: Brand Token Usage (브랜드 토큰 커버리지)

> 담당 TM: TM19 (Layout & Brand + Memorability)
> 체크리스트: S-08, T-05~T-08, T-14~T-16

```javascript
(function(){
  // CSS 변수 vs 하드코딩 비율
  let cssVarCount = 0;
  let inlineColorCount = 0;
  let inlineBorderRadiusCount = 0;
  let inlineShadowCount = 0;
  const borderRadiusValues = new Set();
  const shadowValues = new Set();

  // :root CSS 변수 수집
  const rootVars = [];
  try {
    for(const sheet of document.styleSheets) {
      try {
        for(const rule of sheet.cssRules) {
          const text = rule.cssText || '';
          // CSS 변수 정의 카운트
          const varMatches = text.match(/--[\w-]+/g);
          if(varMatches) {
            varMatches.forEach(v => {
              if(!rootVars.includes(v)) rootVars.push(v);
            });
          }
          // 하드코딩 색상 감지 (hex, rgb, hsl)
          const hardcodedColors = text.match(/#[0-9a-fA-F]{3,8}|rgb\([^)]+\)|hsl\([^)]+\)/g);
          if(hardcodedColors) inlineColorCount += hardcodedColors.length;
          // var() 사용 카운트
          const varUsages = text.match(/var\(--[\w-]+/g);
          if(varUsages) cssVarCount += varUsages.length;
        }
      } catch(e) {}
    }
  } catch(e) {}

  // border-radius 분석
  Array.from(document.querySelectorAll('*')).slice(0, 200).forEach(el => {
    const cs = window.getComputedStyle(el);
    if(cs.borderRadius && cs.borderRadius !== '0px') {
      borderRadiusValues.add(cs.borderRadius);
    }
    if(cs.boxShadow && cs.boxShadow !== 'none') {
      shadowValues.add(cs.boxShadow.substring(0, 60));
    }
  });

  // 아이콘 라이브러리 감지
  const iconLibraries = new Set();
  document.querySelectorAll('svg[class], i[class], span[class*="icon"]').forEach(el => {
    const cls = el.className?.toString() || '';
    if(cls.includes('lucide')) iconLibraries.add('lucide');
    else if(cls.includes('heroicon')) iconLibraries.add('heroicons');
    else if(cls.includes('fa-') || cls.includes('fas ') || cls.includes('fab ')) iconLibraries.add('font-awesome');
    else if(cls.includes('material')) iconLibraries.add('material-icons');
    else if(cls.includes('feather')) iconLibraries.add('feather');
    else if(cls.includes('tabler')) iconLibraries.add('tabler');
    else if(el.tagName === 'SVG') iconLibraries.add('inline-svg');
  });

  const totalStyles = cssVarCount + inlineColorCount;
  const tokenCoverage = totalStyles > 0 ? +(cssVarCount / totalStyles * 100).toFixed(1) : 0;
  const inlineRatio = totalStyles > 0 ? +(inlineColorCount / totalStyles * 100).toFixed(1) : 0;

  return {
    cssVariables: {
      defined: rootVars.length,
      used: cssVarCount,
      samples: rootVars.slice(0, 15)
    },
    hardcodedColors: {
      count: inlineColorCount,
      inlineRatio: inlineRatio + '%',
      pass: inlineRatio <= 5
    },
    tokenCoverage: tokenCoverage + '%',
    borderRadius: {
      uniqueValues: [...borderRadiusValues],
      count: borderRadiusValues.size,
      pass: borderRadiusValues.size <= 4
    },
    boxShadow: {
      uniqueValues: [...shadowValues].slice(0, 5),
      count: shadowValues.size,
      pass: shadowValues.size <= 3
    },
    iconLibraries: {
      detected: [...iconLibraries],
      count: iconLibraries.size,
      pass: iconLibraries.size <= 2
    }
  };
})()
```

### DQ-5: Motion Strategy (모션 전략 분석)

> 담당 TM: TM19 (Layout & Brand + Memorability)
> 체크리스트: U-03, U-08~U-10

```javascript
(function(){
  const allEls = document.querySelectorAll('*');
  const entryMotions = []; // staggered reveal, fade-in 등
  const hoverMotions = [];
  const scrollAnimations = [];
  let hasCustomCursor = false;
  let hasGrainOverlay = false;
  let hasGradientBg = false;
  let hasNoiseTexture = false;

  Array.from(allEls).slice(0, 300).forEach(el => {
    const cs = window.getComputedStyle(el);

    // 진입 모션 감지
    if(cs.animationName && cs.animationName !== 'none') {
      const name = cs.animationName.toLowerCase();
      if(name.includes('fade') || name.includes('slide') || name.includes('reveal') ||
         name.includes('enter') || name.includes('appear') || name.includes('stagger')) {
        entryMotions.push({
          tag: el.tagName, class: el.className?.toString().substring(0, 30),
          animation: cs.animationName, duration: cs.animationDuration, delay: cs.animationDelay
        });
      }
    }

    // 트랜지션 분석
    if(cs.transitionProperty && cs.transitionProperty !== 'none') {
      hoverMotions.push({
        tag: el.tagName,
        property: cs.transitionProperty.substring(0, 40),
        duration: cs.transitionDuration
      });
    }

    // 스크롤 애니메이션 감지
    if(el.getAttribute('data-aos') || el.classList.contains('animate-on-scroll') ||
       cs.animationPlayState === 'paused') {
      scrollAnimations.push({ tag: el.tagName, class: el.className?.toString().substring(0, 30) });
    }

    // 커스텀 커서
    if(cs.cursor && !['auto','default','pointer','text','not-allowed','grab','grabbing','move','crosshair','wait'].includes(cs.cursor)) {
      hasCustomCursor = true;
    }

    // 배경 분위기
    if(cs.backgroundImage && cs.backgroundImage !== 'none') {
      if(cs.backgroundImage.includes('gradient')) hasGradientBg = true;
      if(cs.backgroundImage.includes('noise') || cs.backgroundImage.includes('grain')) hasNoiseTexture = true;
    }

    // grain overlay 감지
    if(el.className?.toString().includes('grain') || el.className?.toString().includes('noise')) {
      hasGrainOverlay = true;
    }
  });

  // 모션 분산도 (다양한 요소에 적용 여부)
  const motionTargets = new Set([...entryMotions.map(m => m.tag), ...hoverMotions.map(m => m.tag)]);
  const motionDiversity = motionTargets.size;

  // prefers-reduced-motion 대응 여부
  const reducedMotionQuery = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  return {
    entryMotions: {
      count: entryMotions.length,
      hasStaggeredReveal: entryMotions.some(m => m.delay && parseFloat(m.delay) > 0),
      samples: entryMotions.slice(0, 5),
      pass: entryMotions.length >= 1
    },
    hoverMotions: {
      count: hoverMotions.length,
      samples: hoverMotions.slice(0, 5)
    },
    scrollAnimations: {
      count: scrollAnimations.length,
      samples: scrollAnimations.slice(0, 3)
    },
    atmosphere: {
      hasGradientBg,
      hasNoiseTexture,
      hasGrainOverlay,
      hasCustomCursor,
      solidOnly: !hasGradientBg && !hasNoiseTexture && !hasGrainOverlay,
      pass: hasGradientBg || hasNoiseTexture || hasGrainOverlay
    },
    motionDiversity,
    prefersReducedMotion: reducedMotionQuery
  };
})()
```

### DQ-6: Signature Elements (시그니처 요소 감지)

> 담당 TM: TM19 (Layout & Brand + Memorability)
> 체크리스트: U-01, U-02, U-04~U-07, U-13~U-15

```javascript
(function(){
  const allEls = document.querySelectorAll('*');
  const signatureElements = [];
  let hasCustomScrollbar = false;
  let hasBlobShape = false;
  let hasClipPath = false;
  let hasBackdropBlur = false;
  let hasMixBlendMode = false;
  let hasTextGradient = false;

  // z-index 스택 분석
  const zIndexStack = [];
  Array.from(allEls).slice(0, 300).forEach(el => {
    const cs = window.getComputedStyle(el);

    // z-index 높은 요소 (시각적 레이어링)
    const z = parseInt(cs.zIndex);
    if(!isNaN(z) && z > 1) {
      zIndexStack.push({ tag: el.tagName, class: el.className?.toString().substring(0, 30), zIndex: z });
    }

    // transform 사용 (회전, 기울기 등)
    if(cs.transform && cs.transform !== 'none') {
      if(cs.transform.includes('rotate') || cs.transform.includes('skew')) {
        signatureElements.push({
          type: 'transform',
          tag: el.tagName, class: el.className?.toString().substring(0, 30),
          value: cs.transform.substring(0, 50)
        });
      }
    }

    // clip-path (비표준 형태)
    if(cs.clipPath && cs.clipPath !== 'none') {
      hasClipPath = true;
      signatureElements.push({ type: 'clip-path', tag: el.tagName, value: cs.clipPath.substring(0, 50) });
    }

    // backdrop-filter (glassmorphism)
    if(cs.backdropFilter && cs.backdropFilter !== 'none') {
      hasBackdropBlur = true;
      signatureElements.push({ type: 'backdrop-filter', tag: el.tagName, value: cs.backdropFilter });
    }

    // mix-blend-mode
    if(cs.mixBlendMode && cs.mixBlendMode !== 'normal') {
      hasMixBlendMode = true;
    }

    // text gradient (background-clip: text)
    if(cs.webkitBackgroundClip === 'text' || cs.backgroundClip === 'text') {
      hasTextGradient = true;
      signatureElements.push({ type: 'text-gradient', tag: el.tagName, text: el.textContent?.substring(0, 20) });
    }

    // 커스텀 스크롤바
    if(cs.scrollbarWidth && cs.scrollbarWidth !== 'auto') {
      hasCustomScrollbar = true;
    }

    // blob/organic 형태 감지
    if(cs.borderRadius) {
      const values = cs.borderRadius.split(' ');
      const uniqueValues = new Set(values.map(v => parseFloat(v)));
      if(uniqueValues.size >= 3 && [...uniqueValues].some(v => v > 30)) {
        hasBlobShape = true;
      }
    }
  });

  // 첫 3초 인상 요소
  const hero = document.querySelector('[class*="hero"], [class*="banner"], main > *:first-child, header + *');
  const heroAnalysis = hero ? {
    found: true,
    tag: hero.tagName,
    hasImage: !!hero.querySelector('img, picture, video'),
    hasAnimation: window.getComputedStyle(hero).animationName !== 'none',
    hasCTA: !!hero.querySelector('a, button'),
    hasHeading: !!hero.querySelector('h1, h2'),
    height: hero.getBoundingClientRect().height + 'px'
  } : { found: false };

  // 시그니처 점수
  const signatureScore = [
    hasClipPath, hasBackdropBlur, hasMixBlendMode,
    hasTextGradient, hasCustomScrollbar, hasBlobShape,
    signatureElements.length > 0
  ].filter(Boolean).length;

  return {
    signatureElements: signatureElements.slice(0, 10),
    signatureCount: signatureElements.length,
    features: {
      hasClipPath,
      hasBackdropBlur,
      hasMixBlendMode,
      hasTextGradient,
      hasCustomScrollbar,
      hasBlobShape
    },
    signatureScore,
    signaturePass: signatureScore >= 1,
    zIndexStack: zIndexStack.sort((a,b) => b.zIndex - a.zIndex).slice(0, 5),
    heroAnalysis
  };
})()
```

---

## 스니펫 매핑 테이블

| ID | 이름 | 담당 TM | 관련 카테고리 | 주요 측정 |
|:--:|------|:-------:|:------------:|-----------|
| T-1 | Body Font Size | TM1 | A | 본문 >= 16px |
| T-2 | Heading Ratio | TM1 | A | H1-H3 크기 비율 |
| T-3 | Input Font Size | TM1 | A | iOS 줌 방지 |
| T-4 | Line-Height Ratios | TM2 | B | 행간 비율 |
| T-5 | Paragraph Max-Width | TM2 | B | 줄당 35-80자 |
| S-1 | Component Padding | TM3 | C | 패딩 일관성 |
| S-2 | Grid/Spacing System | TM3 | C | 4px/8px 배수 |
| C-1 | Text Contrast | TM4 | D | WCAG 4.5:1 |
| C-2 | Focus Ring | TM4 | D | 포커스 가시성 |
| M-1 | Modal/Dialog | TM9 | H | 모달 ARIA |
| M-2 | Component Variety | TM14 | M | DOM 컴포넌트 분포 |
| ANIM-1 | Animation Metrics | TM8 | G | 전환/애니메이션 지표 |
| DS-1 | Design System | TM14 | M | 변형 일관성 + CSS 변수 |
| NAV-1 | Navigation | TM10 | I | 내비게이션 구조 |
| FORM-1 | Form UX | TM13 | L | 폼 라벨/유효성 |
| A-1 | CSS Snapshot | Lead | 전체 | 종합 지표 수집 |
| **DQ-1** | **Font Quality** | **TM7** | **S** | **폰트 품질/페어링/스케일** |
| **DQ-2** | **Color Distribution** | **TM7** | **S** | **주조색/Accent/팔레트** |
| **DQ-3** | **Layout Pattern** | **TM19** | **T** | **레이아웃 다양성/쿠키커터** |
| **DQ-4** | **Brand Token Usage** | **TM19** | **T** | **토큰 커버리지/아이콘/radius** |
| **DQ-5** | **Motion Strategy** | **TM19** | **T+U** | **진입 모션/분위기/grain** |
| **DQ-6** | **Signature Elements** | **TM19** | **U** | **시그니처/glassmorphism/hero** |

---

## 실행 순서

Stage 1에서 Lead는 다음 순서로 실행:

1. **A-1** — 종합 CSS 스냅샷 (전 TM 공유)
2. **T-1 ~ T-5** — 타이포그래피 기초 (TM1, TM2)
3. **S-1, S-2** — 스페이싱 (TM3)
4. **C-1, C-2** — 접근성 핵심 (TM4)
5. **ANIM-1** — 애니메이션 (TM8)
6. **M-1, M-2** — 모달/컴포넌트 (TM9, TM14)
7. **DS-1** — 디자인 시스템 (TM14)
8. **NAV-1** — 네비게이션 (TM10)
9. **FORM-1** — 폼 UX (TM13)
10. **DQ-1, DQ-2** — 폰트/색상 품질 (TM7) *(신규)*
11. **DQ-3, DQ-4** — 레이아웃/토큰 (TM19) *(신규)*
12. **DQ-5, DQ-6** — 모션/시그니처 (TM19) *(신규)*

> 각 스니펫 결과는 `.qa-audit/run-{ts}/data/snippets/` 디렉토리에 `{id}.json`으로 저장.
> TM은 자신의 담당 스니펫 결과만 읽어 분석한다.
