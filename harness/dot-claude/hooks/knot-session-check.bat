@echo off
REM knot SessionStart 훅 Windows 래퍼 — 같은 폴더의 .sh를 Git bash로 실행.
REM %~dp0 = 이 .bat의 위치(설치 경로 무관 이식성). Git bash 없으면 PATH의 bash로 폴백.
set "SH=%~dp0knot-session-check.sh"
if exist "C:\Program Files\Git\bin\bash.exe" (
  "C:\Program Files\Git\bin\bash.exe" "%SH%"
) else (
  bash "%SH%"
)
