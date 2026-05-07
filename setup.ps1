<#
.SYNOPSIS
  AI Coding Agent Skills 一键安装 (opencode / Codex 通用)
.DESCRIPTION
  自动检测 opencode 或 Codex，将 skills 克隆到对应的配置目录。
  两者使用相同的 SKILL.md 标准格式，无需转换。
.NOTES
  github.com/1658205453qq-dot/opencode-skills
#>

param(
  [ValidateSet("codex", "opencode", "both", "auto")]
  [string]$Tool = "auto"
)

$ErrorActionPreference = "Stop"
$repoUrl = "https://github.com/1658205453qq-dot/opencode-skills.git"

# 检测已安装的工具
$hasOpencode = $null -ne (Get-Command opencode -ErrorAction SilentlyContinue)
$hasCodex    = $null -ne (Get-Command codex    -ErrorAction SilentlyContinue)

# 工具 → 目录映射
$toolDirs = @{
  codex    = "$env:USERPROFILE\.agents\skills"
  opencode = "$env:USERPROFILE\.opencode\skills"
}

function Install-To($toolName) {
  $targetDir = $toolDirs[$toolName]

  if (Test-Path $targetDir) {
    Write-Host "  SKIP $targetDir 已存在" -ForegroundColor DarkYellow
    return
  }

  $parent = Split-Path $targetDir -Parent
  if (-not (Test-Path $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }

  Write-Host "  克隆 → $targetDir" -ForegroundColor Yellow
  git clone $repoUrl $targetDir 2>&1 | Out-Null

  if ($LASTEXITCODE -eq 0) {
    $count = (Get-ChildItem $targetDir -Directory | Measure-Object).Count
    Write-Host "  OK   $count 个 skills 已安装 ($toolName)" -ForegroundColor Green
  } else {
    Write-Host "  ERR  克隆失败" -ForegroundColor Red
  }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " AI Agent Skills 一键安装"              -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 选择安装目标
if ($Tool -ne "auto") {
  # 手动指定
  if ($Tool -eq "both") {
    Install-To "codex"
    Install-To "opencode"
  } else {
    Install-To $Tool
  }
} else {
  # 自动检测
  switch ($true) {
    ($hasCodex -and $hasOpencode) {
      Write-Host "  检测到 Codex + opencode 均已安装" -ForegroundColor Cyan
      Write-Host "  将同时安装到两个目录" -ForegroundColor Cyan
      Write-Host ""
      Install-To "codex"
      Install-To "opencode"
    }
    $hasCodex {
      Write-Host "  检测到 Codex" -ForegroundColor Cyan
      Install-To "codex"
    }
    $hasOpencode {
      Write-Host "  检测到 opencode" -ForegroundColor Cyan
      Install-To "opencode"
    }
    default {
      Write-Host "  未检测到 codex 或 opencode" -ForegroundColor Yellow
      Write-Host "  将安装到 Codex 默认路径 (~\.agents\skills)" -ForegroundColor Yellow
      Write-Host "  如果使用 opencode，请重新运行: .\setup.ps1 -Tool opencode" -ForegroundColor DarkGray
      Write-Host ""
      Install-To "codex"
    }
  }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  完成！Codex 或 opencode 下次启动将自动加载" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
