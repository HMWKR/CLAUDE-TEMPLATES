#!/usr/bin/env node
/**
 * validate-journals.js v1.0
 *
 * .prompts/*.md 저널 파일의 형식을 검증합니다.
 * GitHub Actions에서 CI 검증용으로 사용됩니다.
 *
 * 사용법: node scripts/validate-journals.js
 * 종료 코드: 0 (성공), 1 (검증 실패)
 */

import { readFileSync, readdirSync, existsSync } from 'fs';
import { join, basename } from 'path';

// YAML frontmatter 필수 필드
const REQUIRED_YAML_FIELDS = [
  'date',
  'domain',
  'complexity'
];

// YAML frontmatter 권장 필드
const RECOMMENDED_YAML_FIELDS = [
  'commit',
  'quality_score',
  'grade'
];

// 마크다운 필수 섹션
const REQUIRED_SECTIONS = [
  '원본 프롬프트',
  '사고 여정',
  '최적화된 프롬프트'
];

// 마크다운 권장 섹션
const RECOMMENDED_SECTIONS = [
  '품질 분석',
  '핵심 학습',
  '결과'
];

// 유효한 domain 값
const VALID_DOMAINS = [
  'backend', 'frontend', 'devops', 'docs', 'test',
  'refactor', 'security', 'performance', 'general'
];

// 유효한 complexity 값
const VALID_COMPLEXITIES = ['low', 'medium', 'high'];

// 유효한 grade 값
const VALID_GRADES = ['S', 'A+', 'A', 'B+', 'B', 'C', 'F'];

/**
 * YAML frontmatter 파싱
 */
function parseYamlFrontmatter(content) {
  const frontmatterMatch = content.match(/^---\n([\s\S]*?)\n---/);
  if (!frontmatterMatch) {
    return { found: false, data: {} };
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
        value = value.slice(1, -1).split(',').map(s => s.trim());
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

  return { found: true, data: result };
}

/**
 * 마크다운 섹션 존재 여부 확인
 */
function hasSection(content, sectionName) {
  const escapedName = sectionName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const regex = new RegExp(`#+\\s*(?:[^\\n]*)?${escapedName}`, 'i');
  return regex.test(content);
}

/**
 * 파일명 형식 검증 (YYYY-MM-DD-*.md)
 */
function validateFilename(filename) {
  const pattern = /^\d{4}-\d{2}-\d{2}-.+\.md$/;
  return pattern.test(filename);
}

/**
 * 날짜 형식 검증 (YYYY-MM-DD)
 */
function validateDateFormat(date) {
  if (typeof date !== 'string') return false;
  const pattern = /^\d{4}-\d{2}-\d{2}$/;
  return pattern.test(date);
}

/**
 * 단일 저널 파일 검증
 */
function validateJournal(filePath) {
  const filename = basename(filePath);
  const errors = [];
  const warnings = [];

  try {
    const content = readFileSync(filePath, 'utf8');

    // 1. 파일명 형식 검증
    if (!validateFilename(filename)) {
      warnings.push(`파일명 형식 권장: YYYY-MM-DD-{topic}.md (현재: ${filename})`);
    }

    // 2. YAML frontmatter 검증
    const { found, data } = parseYamlFrontmatter(content);

    if (!found) {
      errors.push('YAML frontmatter가 없습니다');
    } else {
      // 필수 필드 검증
      for (const field of REQUIRED_YAML_FIELDS) {
        if (data[field] === undefined || data[field] === null) {
          errors.push(`필수 YAML 필드 누락: ${field}`);
        }
      }

      // 권장 필드 검증
      for (const field of RECOMMENDED_YAML_FIELDS) {
        if (data[field] === undefined || data[field] === null) {
          warnings.push(`권장 YAML 필드 누락: ${field}`);
        }
      }

      // date 형식 검증
      if (data.date && !validateDateFormat(data.date)) {
        errors.push(`잘못된 날짜 형식: ${data.date} (YYYY-MM-DD 필요)`);
      }

      // domain 값 검증
      if (data.domain && !VALID_DOMAINS.includes(data.domain)) {
        warnings.push(`알 수 없는 domain 값: ${data.domain} (유효: ${VALID_DOMAINS.join(', ')})`);
      }

      // complexity 값 검증
      if (data.complexity && !VALID_COMPLEXITIES.includes(data.complexity)) {
        errors.push(`잘못된 complexity 값: ${data.complexity} (유효: ${VALID_COMPLEXITIES.join(', ')})`);
      }

      // grade 값 검증
      if (data.grade && !VALID_GRADES.includes(data.grade)) {
        warnings.push(`알 수 없는 grade 값: ${data.grade} (유효: ${VALID_GRADES.join(', ')})`);
      }

      // quality_score 범위 검증
      if (data.quality_score !== null && data.quality_score !== undefined) {
        if (typeof data.quality_score !== 'number' || data.quality_score < 0 || data.quality_score > 48) {
          errors.push(`잘못된 quality_score: ${data.quality_score} (0-48 범위)`);
        }
      }
    }

    // 3. 마크다운 섹션 검증
    for (const section of REQUIRED_SECTIONS) {
      if (!hasSection(content, section)) {
        errors.push(`필수 섹션 누락: ${section}`);
      }
    }

    for (const section of RECOMMENDED_SECTIONS) {
      if (!hasSection(content, section)) {
        warnings.push(`권장 섹션 누락: ${section}`);
      }
    }

    // 4. 최소 내용 검증
    const contentWithoutFrontmatter = content.replace(/^---[\s\S]*?---/, '').trim();
    if (contentWithoutFrontmatter.length < 100) {
      warnings.push('내용이 너무 짧습니다 (100자 미만)');
    }

    return { filename, errors, warnings, valid: errors.length === 0 };

  } catch (error) {
    return {
      filename,
      errors: [`파일 읽기 오류: ${error.message}`],
      warnings: [],
      valid: false
    };
  }
}

/**
 * 모든 저널 파일 검증
 */
function validateAllJournals() {
  const promptsDir = '.prompts';
  const results = [];

  // .prompts 폴더 존재 확인
  if (!existsSync(promptsDir)) {
    console.log('📁 .prompts/ 폴더가 없습니다. 검증 건너뜀.\n');
    return { success: true, results: [] };
  }

  // .md 파일 목록 가져오기
  const files = readdirSync(promptsDir)
    .filter(f => f.endsWith('.md') && f !== '.gitkeep')
    .map(f => join(promptsDir, f));

  if (files.length === 0) {
    console.log('📁 .prompts/ 폴더에 저널 파일이 없습니다.\n');
    return { success: true, results: [] };
  }

  console.log(`📋 ${files.length}개의 저널 파일 검증 중...\n`);

  // 각 파일 검증
  for (const filePath of files) {
    const result = validateJournal(filePath);
    results.push(result);
  }

  return {
    success: results.every(r => r.valid),
    results
  };
}

/**
 * 검증 결과 출력
 */
function printResults(results) {
  let hasErrors = false;

  for (const result of results) {
    const status = result.valid ? '✅' : '❌';
    console.log(`${status} ${result.filename}`);

    if (result.errors.length > 0) {
      hasErrors = true;
      for (const error of result.errors) {
        console.log(`   ❌ 오류: ${error}`);
      }
    }

    if (result.warnings.length > 0) {
      for (const warning of result.warnings) {
        console.log(`   ⚠️  경고: ${warning}`);
      }
    }

    console.log('');
  }

  return hasErrors;
}

/**
 * 메인 함수
 */
function main() {
  console.log('');
  console.log('================================================');
  console.log('  프롬프트 저널 검증기 v1.0');
  console.log('================================================');
  console.log('');

  const { success, results } = validateAllJournals();

  if (results.length === 0) {
    console.log('검증할 저널 파일이 없습니다.');
    process.exit(0);
  }

  const hasErrors = printResults(results);

  // 통계 출력
  const validCount = results.filter(r => r.valid).length;
  const totalCount = results.length;
  const warningCount = results.reduce((sum, r) => sum + r.warnings.length, 0);
  const errorCount = results.reduce((sum, r) => sum + r.errors.length, 0);

  console.log('================================================');
  console.log('  검증 결과 요약');
  console.log('================================================');
  console.log(`  총 파일: ${totalCount}개`);
  console.log(`  통과: ${validCount}개`);
  console.log(`  실패: ${totalCount - validCount}개`);
  console.log(`  오류: ${errorCount}개`);
  console.log(`  경고: ${warningCount}개`);
  console.log('================================================');
  console.log('');

  if (hasErrors) {
    console.log('❌ 검증 실패: 필수 항목 오류가 있습니다.\n');
    process.exit(1);
  } else {
    console.log('✅ 모든 저널 검증 통과!\n');
    process.exit(0);
  }
}

// 실행
main();
