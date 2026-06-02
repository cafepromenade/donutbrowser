param(
  [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"

$contributorsWorkflow = Join-Path $Root ".github/workflows/contributors.yml"
if (Test-Path -LiteralPath $contributorsWorkflow) {
  Remove-Item -LiteralPath $contributorsWorkflow
}

function Update-TextFile {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][scriptblock]$Update
  )

  $fullPath = Join-Path $Root $Path
  if (!(Test-Path -LiteralPath $fullPath)) {
    return
  }

  $before = Get-Content -LiteralPath $fullPath -Raw
  $after = & $Update $before
  if ($after -ne $before) {
    Set-Content -LiteralPath $fullPath -Value $after -NoNewline
  }
}

Update-TextFile "src-tauri/src/cloud_auth.rs" {
  param($text)
  $text = $text -replace '(?s)pub async fn has_active_paid_subscription\(&self\) -> bool \{.*?\n  \}', "pub async fn has_active_paid_subscription(&self) -> bool {`n    true`n  }"
  $text = $text -replace '(?s)pub fn has_active_paid_subscription_sync\(&self\) -> bool \{.*?\n  \}', "pub fn has_active_paid_subscription_sync(&self) -> bool {`n    true`n  }"
  $text = $text -replace '(?s)pub async fn is_fingerprint_os_allowed\(&self, fingerprint_os: Option<&str>\) -> bool \{.*?\n  \}', "pub async fn is_fingerprint_os_allowed(&self, _fingerprint_os: Option<&str>) -> bool {`n    true`n  }"
  $text = $text -replace '(?s)pub async fn is_on_team_plan\(&self\) -> bool \{.*?\n  \}', "pub async fn is_on_team_plan(&self) -> bool {`n    true`n  }"
  $text
}

Update-TextFile "src-tauri/src/api_client.rs" {
  param($text)
  $text -replace '/repos/[^/]+/camoufox/releases', '/repos/cafepromenade/camoufox/releases'
}

Update-TextFile "README.md" {
  param($text)
  $text = $text -replace 'https://camoufox\.com', 'https://github.com/cafepromenade/camoufox'
  $contributors = @'
## Contributors

<p align="center">
  <a href="https://claude.ai" target="_blank">
    <img src="https://cdn.simpleicons.org/claude" width="72" height="72" alt="Claude AI logo">
  </a>
  &nbsp;&nbsp;&nbsp;
  <a href="https://openai.com/codex" target="_blank">
    <img src="https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/openai.svg" width="72" height="72" alt="Codex logo">
  </a>
  &nbsp;&nbsp;&nbsp;
  <a href="https://www.deepseek.com" target="_blank">
    <img src="https://cdn.simpleicons.org/deepseek" width="72" height="72" alt="Deepseek logo">
  </a>
  <br>
  <strong>Made with <span aria-label="heart">♥</span> by Claude, Codex, and Deepseek</strong>
</p>
'@
  $text -replace '(?s)## (Credits|Contributors)\r?\n.*?(?=\r?\n## Contact)', "$contributors`n"
}

Get-ChildItem -LiteralPath $Root -Recurse -File |
  Where-Object {
    $_.FullName -notmatch '\\.git\\' -and
    $_.FullName -notmatch '\\node_modules\\' -and
    $_.FullName -notmatch '\\target\\' -and
    $_.Extension -in @(".md", ".yml", ".yaml", ".toml", ".rs", ".tsx", ".ts", ".json", ".sh", ".nix")
  } |
  ForEach-Object {
    $before = Get-Content -LiteralPath $_.FullName -Raw
    $after = $before `
      -replace 'zhom/donutbrowser', 'cafepromenade/donutbrowser' `
      -replace 'github\.com/zhom/donutbrowser', 'github.com/cafepromenade/donutbrowser' `
      -replace 'github:zhom/donutbrowser', 'github:cafepromenade/donutbrowser' `
      -replace 'github\.com/zhom', 'github.com/cafepromenade' `
      -replace 'zhom@github', 'cafepromenade@github' `
      -replace ' Requires an active Pro subscription\.', '.' `
      -replace ' Requires Pro subscription\.', '.' `
      -replace ' Requires paid subscription\.', '.'
    if ($after -ne $before) {
      Set-Content -LiteralPath $_.FullName -Value $after -NoNewline
    }
  }
