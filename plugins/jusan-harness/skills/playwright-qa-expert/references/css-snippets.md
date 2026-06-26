## 12. browser_evaluate CSS 검증 스니펫 레퍼런스

> 체크리스트 항목 중 CSS computed style 검증이 필요한 항목에 대한 **즉시 사용 가능한** 코드 스니펫.
> `browser_evaluate` 또는 `browser_run_code` 도구에서 사용한다.

### 12.1 타이포그래피 (Typography)

#### 📝 스니펫 T-1: 본문 폰트 크기 검증 (항목 #1)
```javascript
// browser_evaluate: 본문 텍스트 16px 이상 확인
(function() {
  const body = document.querySelector('body');
  const p = document.querySelector('p') || document.querySelector('main') || body;
  const fontSize = window.getComputedStyle(p).fontSize;
  const size = parseFloat(fontSize);
  return {
    element: p.tagName,
    fontSize: fontSize,
    pass: size >= 16,
    note: size < 16 ? `⚠️ ${fontSize} < 16px 권장 기준 미달` : `✅ ${fontSize} 충족`
  };
})()
```

#### 📝 스니펫 T-2: 제목 크기 비율 검증 (항목 #2)
```javascript
// browser_evaluate: H1이 본문의 2-2.5배인지 확인
(function() {
  const body = document.querySelector('p') || document.querySelector('body');
  const h1 = document.querySelector('h1');
  const h2 = document.querySelector('h2');
  const h3 = document.querySelector('h3');
  const base = parseFloat(window.getComputedStyle(body).fontSize);
  const results = [];
  if (h1) {
    const s = parseFloat(window.getComputedStyle(h1).fontSize);
    const ratio = (s / base).toFixed(2);
    results.push({ tag: 'H1', size: s + 'px', ratio, pass: ratio >= 2 && ratio <= 2.5 });
  }
  if (h2) {
    const s = parseFloat(window.getComputedStyle(h2).fontSize);
    const ratio = (s / base).toFixed(2);
    results.push({ tag: 'H2', size: s + 'px', ratio, pass: ratio >= 1.5 && ratio <= 1.75 });
  }
  if (h3) {
    const s = parseFloat(window.getComputedStyle(h3).fontSize);
    const ratio = (s / base).toFixed(2);
    results.push({ tag: 'H3', size: s + 'px', ratio, pass: ratio >= 1.25 && ratio <= 1.5 });
  }
  return { baseFontSize: base + 'px', headings: results };
})()
```

#### 📝 스니펫 T-3: input 필드 16px 검증 (항목 #7)
```javascript
// browser_evaluate: iOS 줌 방지 — input 폰트 16px 이상 확인
(function() {
  const inputs = document.querySelectorAll('input, textarea, select');
  const results = [];
  inputs.forEach((el, i) => {
    const size = parseFloat(window.getComputedStyle(el).fontSize);
    results.push({
      index: i,
      type: el.type || el.tagName.toLowerCase(),
      fontSize: size + 'px',
      pass: size >= 16,
      note: size < 16 ? '⚠️ iOS 자동 줌 발생 위험' : '✅ OK'
    });
  });
  return { total: inputs.length, issues: results.filter(r => !r.pass).length, details: results };
})()
```

#### 📝 스니펫 T-4: 행간(line-height) 검증 (항목 #19)
```javascript
// browser_evaluate: 본문 행간 1.5-1.75 확인
(function() {
  const targets = [
    { sel: 'p', label: '본문(p)', min: 1.4, max: 1.75 },
    { sel: 'h1', label: '제목(h1)', min: 1.1, max: 1.3 },
    { sel: 'h2', label: '부제목(h2)', min: 1.1, max: 1.3 },
    { sel: 'li', label: '리스트(li)', min: 1.4, max: 1.75 }
  ];
  return targets.map(t => {
    const el = document.querySelector(t.sel);
    if (!el) return { ...t, found: false };
    const lh = window.getComputedStyle(el).lineHeight;
    const fs = parseFloat(window.getComputedStyle(el).fontSize);
    const ratio = lh === 'normal' ? 1.2 : (parseFloat(lh) / fs);
    return {
      label: t.label,
      lineHeight: lh,
      fontSize: fs + 'px',
      ratio: ratio.toFixed(2),
      pass: ratio >= t.min && ratio <= t.max
    };
  });
})()
```

#### 📝 스니펫 T-5: 문단 최대 너비 검증 (항목 #25)
```javascript
// browser_evaluate: 본문 최대 너비 60-75자(영문) / 35-45자(한글) 확인
(function() {
  const p = document.querySelector('p');
  if (!p) return { found: false };
  const style = window.getComputedStyle(p);
  const width = p.offsetWidth;
  const fontSize = parseFloat(style.fontSize);
  const charsPerLine = Math.round(width / (fontSize * 0.6)); // 근사치
  const maxWidth = style.maxWidth;
  return {
    elementWidth: width + 'px',
    fontSize: fontSize + 'px',
    estimatedCharsPerLine: charsPerLine,
    maxWidth: maxWidth,
    pass: charsPerLine >= 35 && charsPerLine <= 80,
    note: charsPerLine > 80 ? '⚠️ 줄당 글자 수 과다 — max-width 설정 권장' : '✅ OK'
  };
})()
```

### 12.2 간격 & 레이아웃 (Spacing & Layout)

#### 📝 스니펫 S-1: 컴포넌트 패딩 일관성 (항목 #32)
```javascript
// browser_evaluate: 주요 컴포넌트 패딩 일관성 확인
(function() {
  const selectors = ['button', '.card', '[class*="card"]', '[class*="btn"]', 'a[class]'];
  const results = {};
  selectors.forEach(sel => {
    const els = document.querySelectorAll(sel);
    if (els.length === 0) return;
    const paddings = new Set();
    els.forEach(el => {
      const s = window.getComputedStyle(el);
      paddings.add(`${s.paddingTop} ${s.paddingRight} ${s.paddingBottom} ${s.paddingLeft}`);
    });
    results[sel] = {
      count: els.length,
      uniquePaddings: [...paddings],
      consistent: paddings.size <= 2,
      note: paddings.size > 2 ? '⚠️ 패딩 불일관' : '✅ 일관됨'
    };
  });
  return results;
})()
```

#### 📝 스니펫 S-2: 그리드/간격 시스템 분석 (항목 #41)
```javascript
// browser_evaluate: margin/gap 값이 4px 또는 8px 배수인지 확인
(function() {
  const els = document.querySelectorAll('main *, [class*="container"] *');
  const gaps = {};
  const sample = Array.from(els).slice(0, 50);
  sample.forEach(el => {
    const s = window.getComputedStyle(el);
    ['marginTop', 'marginBottom', 'gap', 'rowGap', 'columnGap', 'paddingTop', 'paddingLeft'].forEach(prop => {
      const val = parseFloat(s[prop]);
      if (val > 0 && val !== NaN) {
        const is4 = val % 4 === 0;
        const is8 = val % 8 === 0;
        if (!gaps[val]) gaps[val] = { count: 0, is4xMultiple: is4, is8xMultiple: is8 };
        gaps[val].count++;
      }
    });
  });
  const sorted = Object.entries(gaps).sort((a, b) => b[1].count - a[1].count).slice(0, 10);
  const total = sorted.reduce((sum, [, v]) => sum + v.count, 0);
  const aligned = sorted.filter(([, v]) => v.is4xMultiple).reduce((sum, [, v]) => sum + v.count, 0);
  return {
    topSpacingValues: Object.fromEntries(sorted),
    gridAlignmentRate: ((aligned / total) * 100).toFixed(1) + '%',
    pass: (aligned / total) >= 0.7,
    note: (aligned / total) < 0.7 ? '⚠️ 4px 그리드 정렬률 낮음' : '✅ 그리드 정렬 양호'
  };
})()
```

### 12.3 색상 & 대비 (Color & Contrast)

#### 📝 스니펫 C-1: 텍스트-배경 색상 대비 검증 (항목 #56)
```javascript
// browser_evaluate: 텍스트 색상 대비 4.5:1 확인
(function() {
  function luminance(r, g, b) {
    const a = [r, g, b].map(v => { v /= 255; return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4); });
    return a[0] * 0.2126 + a[1] * 0.7152 + a[2] * 0.0722;
  }
  function parseColor(c) {
    const m = c.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/);
    return m ? [+m[1], +m[2], +m[3]] : [0, 0, 0];
  }
  function contrastRatio(fg, bg) {
    const l1 = luminance(...fg), l2 = luminance(...bg);
    const lighter = Math.max(l1, l2), darker = Math.min(l1, l2);
    return ((lighter + 0.05) / (darker + 0.05)).toFixed(2);
  }
  const textEls = document.querySelectorAll('p, span, a, h1, h2, h3, h4, li, label, button');
  const issues = [];
  const checked = new Set();
  Array.from(textEls).slice(0, 30).forEach(el => {
    const text = el.textContent.trim().substring(0, 20);
    if (!text || checked.has(text)) return;
    checked.add(text);
    const s = window.getComputedStyle(el);
    const fg = parseColor(s.color);
    let bgEl = el;
    let bg = parseColor(s.backgroundColor);
    while (bgEl && s.backgroundColor === 'rgba(0, 0, 0, 0)') {
      bgEl = bgEl.parentElement;
      if (bgEl) bg = parseColor(window.getComputedStyle(bgEl).backgroundColor);
      else bg = [255, 255, 255];
      break;
    }
    const ratio = contrastRatio(fg, bg);
    const fontSize = parseFloat(s.fontSize);
    const threshold = fontSize >= 18 ? 3.0 : 4.5;
    if (ratio < threshold) {
      issues.push({ text, ratio: ratio + ':1', required: threshold + ':1', fontSize: fontSize + 'px' });
    }
  });
  return { totalChecked: checked.size, issues: issues.length, failures: issues };
})()
```

#### 📝 스니펫 C-2: 포커스 링 가시성 검증 (항목 #61)
```javascript
// browser_evaluate: 포커스 링 스타일 존재 여부 확인
(function() {
  const interactiveEls = document.querySelectorAll('a, button, input, select, textarea, [tabindex]');
  const results = [];
  Array.from(interactiveEls).slice(0, 15).forEach((el, i) => {
    const before = window.getComputedStyle(el);
    const outline = before.outlineStyle;
    const outlineColor = before.outlineColor;
    const boxShadow = before.boxShadow;
    el.focus();
    const after = window.getComputedStyle(el);
    const hasOutlineChange = after.outlineStyle !== 'none' && after.outlineWidth !== '0px';
    const hasShadowChange = after.boxShadow !== 'none' && after.boxShadow !== boxShadow;
    results.push({
      index: i,
      tag: el.tagName,
      type: el.type || '',
      focusOutline: after.outline,
      focusBoxShadow: after.boxShadow !== 'none' ? 'exists' : 'none',
      visible: hasOutlineChange || hasShadowChange,
      note: !(hasOutlineChange || hasShadowChange) ? '⚠️ 포커스 표시 없음' : '✅ OK'
    });
    el.blur();
  });
  return { total: results.length, issues: results.filter(r => !r.visible).length, details: results };
})()
```

### 12.4 모바일 특화 (Mobile)

#### 📝 스니펫 M-1: 터치 타겟 크기 검증 (항목 #141)
```javascript
// browser_evaluate: 인터랙티브 요소 44x44px 최소 크기 확인
(function() {
  const els = document.querySelectorAll('a, button, input, select, textarea, [role="button"], [onclick]');
  const issues = [];
  Array.from(els).slice(0, 30).forEach((el, i) => {
    const rect = el.getBoundingClientRect();
    if (rect.width === 0 && rect.height === 0) return;
    const w = Math.round(rect.width);
    const h = Math.round(rect.height);
    if (w < 44 || h < 44) {
      issues.push({
        index: i,
        tag: el.tagName,
        text: (el.textContent || el.getAttribute('aria-label') || '').trim().substring(0, 20),
        width: w + 'px',
        height: h + 'px',
        note: `⚠️ ${w}x${h} < 44x44px`
      });
    }
  });
  return {
    totalChecked: els.length,
    issues: issues.length,
    failures: issues,
    note: issues.length === 0 ? '✅ 모든 터치 타겟 44x44px 이상' : `⚠️ ${issues.length}개 미달`
  };
})()
```

#### 📝 스니펫 M-2: 뷰포트 메타 태그 검증 (항목 #147)
```javascript
// browser_evaluate: viewport 메타 태그 설정 확인
(function() {
  const meta = document.querySelector('meta[name="viewport"]');
  if (!meta) return { found: false, note: '⚠️ viewport 메타 태그 없음' };
  const content = meta.getAttribute('content');
  const hasWidth = content.includes('width=device-width');
  const hasScale = content.includes('initial-scale=1');
  const hasMaxScale = content.includes('maximum-scale=1');
  return {
    found: true,
    content: content,
    hasDeviceWidth: hasWidth,
    hasInitialScale: hasScale,
    hasMaximumScale: hasMaxScale,
    pass: hasWidth && hasScale,
    note: !hasWidth || !hasScale ? '⚠️ 필수 설정 누락' : '✅ OK',
    a11yWarning: hasMaxScale ? '⚠️ maximum-scale=1은 접근성 위반 (확대 제한)' : null
  };
})()
```

### 12.5 종합 검사 (All-in-One)

#### 📝 스니펫 A-1: 핵심 CSS 지표 종합 수집
```javascript
// browser_evaluate: 한 번에 핵심 CSS 지표 수집
(function() {
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

### 12.6 스니펫 사용 가이드

| 스니펫 | 대상 항목 | 사용 도구 | 용도 |
|--------|:---------:|----------|------|
| T-1 | #1 | `browser_evaluate` | 본문 폰트 크기 ≥16px |
| T-2 | #2,#3,#4 | `browser_evaluate` | 제목 크기 비율 검증 |
| T-3 | #7 | `browser_evaluate` | input 16px (iOS 줌 방지) |
| T-4 | #19,#20 | `browser_evaluate` | 행간 1.5-1.75 검증 |
| T-5 | #25 | `browser_evaluate` | 문단 너비 60-75자 |
| S-1 | #32 | `browser_evaluate` | 패딩 일관성 확인 |
| S-2 | #41,#31 | `browser_evaluate` | 4px/8px 그리드 정렬 |
| C-1 | #56,#57 | `browser_evaluate` | WCAG 색상 대비 4.5:1 |
| C-2 | #61,#108 | `browser_evaluate` | 포커스 링 가시성 |
| M-1 | #141,#142 | `browser_evaluate` | 터치 타겟 44x44px |
| M-2 | #147 | `browser_evaluate` | viewport 메타 태그 |
| A-1 | 종합 | `browser_evaluate` | 핵심 지표 한 번에 수집 |

> **사용법**: 각 스니펫의 JavaScript 코드를 `browser_evaluate`의 `function` 파라미터에 전달.
> 결과는 JSON 객체로 반환되며, `pass` 필드로 합격/불합격 판정 가능.

---

