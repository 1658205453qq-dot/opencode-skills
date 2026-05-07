<#
.SYNOPSIS
  opencode skills 一键安装脚本
.DESCRIPTION
  将 skills 克隆到 opencode 配置目录，使 opencode 可以识别使用
.NOTES
  在笔记本上运行此脚本即可安装所有 skills
#>

$ErrorActionPreference = "Stop"

$targetDir = "$env:USERPROFILE\.opencode\skills"
$repoUrl   = "https://github.com/1658205453qq-dot/opencode-skills.git"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " opencode skills 一键安装"              -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查目标位置
if (Test-Path $targetDir) {
  Write-Host "  SKIP $targetDir 已存在，跳过" -ForegroundColor DarkYellow
  Write-Host "  如需更新请手动运行：" -ForegroundColor DarkGray
  Write-Host "    git -C `"$targetDir`" pull" -ForegroundColor DarkGray
  exit 0
}

# 确保父目录存在
$parent = Split-Path $targetDir -Parent
if (-not (Test-Path $parent)) {
  New-Item -ItemType Directory -Path $parent -Force | Out-Null
}

# 克隆
Write-Host "[1/1] 克隆 skills 到 opencode 配置目录..." -ForegroundColor Yellow
git clone $repoUrl $targetDir

if ($LASTEXITCODE -eq 0) {
  Write-Host ""
  Write-Host "========================================" -ForegroundColor Cyan
  Write-Host "  Skills 安装完成！"                    -ForegroundColor Cyan
  Write-Host "========================================" -ForegroundColor Cyan
  Write-Host ""
  Write-Host "  共安装 $(Get-ChildItem $targetDir -Directory | Measure-Object | Select-Object -ExpandProperty Count) 个 skill 目录" -ForegroundColor Green
  Write-Host "  opencode 下次启动将自动加载这些 skills" -ForegroundColor Green
} else {
  Write-Host "  ERR 克隆失败" -ForegroundColor Red
  exit 1
}
