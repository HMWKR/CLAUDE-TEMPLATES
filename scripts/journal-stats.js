#!/usr/bin/env node
/**
 * journal-stats.js v2.0
 *
 * .prompts/*.md 저널 + .thoughts/*.md CE 사고 여정 통계를 생성합니다.
 *
 * 사용법:
 *   node scripts/journal-stats.js           # 콘솔 출력
 *   node scripts/journal-stats.js --json    # JSON 출력
 */

import { readFileSync, readdirSync, existsSync, writeFileSync } from 'fs';
import { join, basename } from 'path';

/**
 * YAML frontmatter 파싱
 */
function parseYamlFrontmatter(content) {
  const frontmatterMatch = content.match(/^---\n([\s\S]*?)\n---/);
  if (!frontmatterMatch) {
    return {};
  }

  const yaml = frontmatterMatch[1];
  const result = {};

  const lines = yaml.split('\n');
  for (const line of lines) {
    if (line.trim().startsWith('#')) continue;

    const match = line.match(/^(\w+):\s*(.*)$/);
    if (match) {
      const key = match[1];
      let value = match[2].trim();

      // 배열 처리
      if (value.startsWith('[') && value.endsWith(']')) {
        value = value.slice(1, -1).split(',').map(s => s.trim()).filter(s => s);
      }
      // 숫자 처리
      else if (!isNaN(value) && value !== '') {
        value = Number(value);
      }
      // null 처리
      else if (value === 'null' || value === '') {
        value = null;
      }
      // 문자열 따옴표 제거
      else if ((value.startsWith('"') && value.endsWith('"')) ||
               (value.startsWith("'") && value.endsWith("'"))) {
        value = value.slice(1, -1);
      }

      result[key] = value;
    }
  }

  return result;
}

/**
 * 월별 그룹핑 키 생성 (YYYY-MM)
 */
function getMonthKey(date) {
  if (!date) return 'unknown';
  return date.substring(0, 7);
}

/**
 * 등급 → 점수 변환 (정렬용)
 */
function gradeToScore(grade) {
  const scores = { 'S': 7, 'A+': 6, 'A': 5, 'B+': 4, 'B': 3, 'C': 2, 'F': 1 };
  return scores[grade] || 0;
}

/**
 * 모든 저널 파일 파싱
 */
function parseAllJournals() {
  const promptsDir = '.prompts';
  const journals = [];

  if (!existsSync(promptsDir)) {
    return journals;
  }

  const files = readdirSync(promptsDir)
    .filter(f => f.endsWith('.md') && f !== '.gitkeep')
    .map(f => join(promptsDir, f));

  for (const filePath of files) {
    try {
      const content = readFileSync(filePath, 'utf8');
      const frontmatter = parseYamlFrontmatter(content);

      journals.push({
        filename: basename(filePath),
        ...frontmatter
      });
    } catch (error) {
      console.error(`Error parsing ${filePath}: ${error.message}`);
    }
  }

  return journals;
}

/**
 * 통계 계산
 */
function calculateStats(journals) {
  if (journals.length === 0) {
    return {
      totalJournals: 0,
      byMonth: {},
      byDomain: {},
      byComplexity: {},
      avgQualityScore: null,
      gradeDistribution: {},
      topTags: [],
      recentJournals: []
    };
  }

  // 월별 통계
  const byMonth = {};
  for (const j of journals) {
    const month = getMonthKey(j.date);
    byMonth[month] = (byMonth[month] || 0) + 1;
  }

  // 도메인별 통계
  const byDomain = {};
  for (const j of journals) {
    const domain = j.domain || 'unknown';
    byDomain[domain] = (byDomain[domain] || 0) + 1;
  }

  // 복잡도별 통계
  const byComplexity = {};
  for (const j of journals) {
    const complexity = j.complexity || 'unknown';
    byComplexity[complexity] = (byComplexity[complexity] || 0) + 1;
  }

  // 평균 품질 점수
  const scores = journals
    .filter(j => typeof j.quality_score === 'number')
    .map(j => j.quality_score);
  const avgQualityScore = scores.length > 0
    ? Math.round((scores.reduce((a, b) => a + b, 0) / scores.length) * 10) / 10
    : null;

  // 등급 분포
  const gradeDistribution = {};
  for (const j of journals) {
    if (j.grade) {
      gradeDistribution[j.grade] = (gradeDistribution[j.grade] || 0) + 1;
    }
  }

  // 태그 집계
  const tagCounts = {};
  for (const j of journals) {
    if (Array.isArray(j.tags)) {
      for (const tag of j.tags) {
        tagCounts[tag] = (tagCounts[tag] || 0) + 1;
      }
    }
  }
  const topTags = Object.entries(tagCounts)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 10)
    .map(([tag, count]) => ({ tag, count }));

  // 최근 저널 5개
  const recentJournals = journals
    .filter(j => j.date)
    .sort((a, b) => b.date.localeCompare(a.date))
    .slice(0, 5)
    .map(j => ({
      filename: j.filename,
      date: j.date,
      domain: j.domain,
      grade: j.grade
    }));

  // 품질 트렌드 (월별 평균)
  const qualityTrend = {};
  for (const j of journals) {
    if (typeof j.quality_score === 'number' && j.date) {
      const month = getMonthKey(j.date);
      if (!qualityTrend[month]) {
        qualityTrend[month] = { sum: 0, count: 0 };
      }
      qualityTrend[month].sum += j.quality_score;
      qualityTrend[month].count += 1;
    }
  }
  const monthlyAvgQuality = {};
  for (const [month, data] of Object.entries(qualityTrend)) {
    monthlyAvgQuality[month] = Math.round((data.sum / data.count) * 10) / 10;
  }

  return {
    totalJournals: journals.length,
    byMonth,
    byDomain,
    byComplexity,
    avgQualityScore,
    gradeDistribution,
    topTags,
    recentJournals,
    monthlyAvgQuality
  };
}

/**
 * 통계 콘솔 출력
 */
function printStats(stats) {
  console.log('');
  console.log('================================================');
  console.log('  프롬프트 저널 통계');
  console.log('================================================');
  console.log('');

  console.log(`📊 총 저널: ${stats.totalJournals}개`);
  console.log(`📈 평균 품질 점수: ${stats.avgQualityScore || 'N/A'}/48`);
  console.log('');

  // 월별 분포
  console.log('📅 월별 분포:');
  const months = Object.entries(stats.byMonth).sort((a, b) => b[0].localeCompare(a[0]));
  for (const [month, count] of months) {
    const bar = '█'.repeat(Math.min(count * 2, 20));
    console.log(`   ${month}: ${bar} (${count})`);
  }
  console.log('');

  // 도메인별 분포
  console.log('🏷️  도메인별 분포:');
  const domains = Object.entries(stats.byDomain).sort((a, b) => b[1] - a[1]);
  for (const [domain, count] of domains) {
    console.log(`   ${domain}: ${count}개`);
  }
  console.log('');

  // 등급 분포
  console.log('🎯 등급 분포:');
  const grades = ['S', 'A+', 'A', 'B+', 'B', 'C', 'F'];
  for (const grade of grades) {
    if (stats.gradeDistribution[grade]) {
      console.log(`   ${grade}: ${stats.gradeDistribution[grade]}개`);
    }
  }
  console.log('');

  // 복잡도 분포
  console.log('⚙️  복잡도 분포:');
  for (const [complexity, count] of Object.entries(stats.byComplexity)) {
    console.log(`   ${complexity}: ${count}개`);
  }
  console.log('');

  // 인기 태그
  if (stats.topTags.length > 0) {
    console.log('🔖 인기 태그:');
    for (const { tag, count } of stats.topTags.slice(0, 5)) {
      console.log(`   #${tag} (${count})`);
    }
    console.log('');
  }

  // 최근 저널
  if (stats.recentJournals.length > 0) {
    console.log('📝 최근 저널:');
    for (const j of stats.recentJournals) {
      const gradeStr = j.grade ? `[${j.grade}]` : '';
      console.log(`   ${j.date} ${j.domain} ${gradeStr}`);
    }
    console.log('');
  }

  console.log('================================================');
}

/**
 * .thoughts/ CE 사고 여정 파싱
 */
function parseAllThinkingLogs() {
  const thoughtsDir = '.thoughts';
  const logs = [];

  if (!existsSync(thoughtsDir)) return logs;

  const files = readdirSync(thoughtsDir)
    .filter(f => f.endsWith('.md') && f !== '.gitkeep')
    .map(f => join(thoughtsDir, f));

  for (const filePath of files) {
    try {
      const content = readFileSync(filePath, 'utf8');
      const fm = parseYamlFrontmatter(content);

      // CE 전략 추출
      const strategies = [];
      if (/\[x\] Write/i.test(content)) strategies.push('write');
      if (/\[x\] Select/i.test(content)) strategies.push('select');
      if (/\[x\] Compress/i.test(content)) strategies.push('compress');
      if (/\[x\] Isolate/i.test(content)) strategies.push('isolate');

      logs.push({ filename: basename(filePath), ...fm, ceStrategies: strategies });
    } catch (e) {
      console.error(`Error parsing ${filePath}: ${e.message}`);
    }
  }

  return logs;
}

/**
 * CE 사고 여정 통계
 */
function calculateThinkingStats(logs) {
  if (logs.length === 0) return { total: 0 };

  const strategyCounts = { write: 0, select: 0, compress: 0, isolate: 0 };
  for (const log of logs) {
    for (const s of (log.ceStrategies || [])) {
      if (strategyCounts[s] !== undefined) strategyCounts[s]++;
    }
  }

  const byType = {};
  for (const log of logs) {
    const type = log.type || 'unknown';
    byType[type] = (byType[type] || 0) + 1;
  }

  return {
    total: logs.length,
    ceStrategyCounts: strategyCounts,
    byType,
  };
}

/**
 * 메인 함수
 */
function main() {
  const args = process.argv.slice(2);
  const jsonMode = args.includes('--json');
  const outputFile = args.find(a => a.startsWith('--output='))?.split('=')[1];

  const journals = parseAllJournals();
  const journalStats = calculateStats(journals);

  const thinkingLogs = parseAllThinkingLogs();
  const thinkingStats = calculateThinkingStats(thinkingLogs);

  const combined = { journals: journalStats, thinking: thinkingStats };

  if (jsonMode) {
    const output = JSON.stringify(combined, null, 2);
    if (outputFile) {
      writeFileSync(outputFile, output);
      console.log(`Stats written to ${outputFile}`);
    } else {
      console.log(output);
    }
  } else {
    printStats(journalStats);
    if (thinkingStats.total > 0) {
      console.log(`\nCE 사고 여정: ${thinkingStats.total}개`);
      console.log(`  CE 전략: Write(${thinkingStats.ceStrategyCounts.write}) Select(${thinkingStats.ceStrategyCounts.select}) Compress(${thinkingStats.ceStrategyCounts.compress}) Isolate(${thinkingStats.ceStrategyCounts.isolate})`);
    }
  }

  return combined;
}

export { parseAllJournals, calculateStats, parseAllThinkingLogs, calculateThinkingStats };

main();
