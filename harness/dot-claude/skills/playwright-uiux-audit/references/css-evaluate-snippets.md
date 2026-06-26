# CSS Evaluate Snippets (16개)

> Lead가 Stage 1 데이터 수집 시 `browser_evaluate`로 실행하는 JavaScript 스니펫.
> 각 스니펫 ID는 토큰 파일 매핑과 일치한다.

---

## T-1: Body Font Size (>=16px 검증)

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

## T-2: Heading Ratio (H1:2-2.5x, H2:1.5-1.75x, H3:1.25-1.5x)

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

## T-3: Input Font Size (>=16px, iOS 줌 방지)

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

## T-4: Line-Height Ratios

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

## T-5: Paragraph Max-Width (35-80 chars)

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

## S-1: Component Padding Consistency

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

## S-2: Grid/Spacing System (4px/8px)

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

## C-1: Text-Background Contrast (WCAG 4.5:1)

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

## C-2: Focus Ring Visibility

```javascript
(function(){
  const interactive = document.querySelectorAll('a, button, input, select, textarea, [tabindex]');
  const results = [];
  Array.from(interactive).slice(0, 10).forEach(el => {
    const cs = window.getComputedStyle(el);
    const focusCs = window.getComputedStyle(el, ':focus');
    results.push({
      tag: el.tagName, type: el.type || '',
      outline: cs.outline, outlineOffset: cs.outlineOffset,
      boxShadow: cs.boxShadow !== 'none' ? cs.boxShadow?.substring(0,50) : 'none'
    });
  });
  return { interactiveCount: interactive.length, samples: results };
})()
```

## M-1: Modal/Dialog Detection

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

## M-2: Component Variety

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

## ANIM-1: Animation/Transition Metrics

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

## DS-1: Design System Consistency

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
    const root = getComputedStyle(document.documentElement);
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

## NAV-1: Navigation Structure

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

## FORM-1: Form UX Analysis

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

## A-1: Comprehensive CSS Snapshot

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
