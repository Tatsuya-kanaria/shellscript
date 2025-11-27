# Copilot instructions for this repository

Short, actionable guidance for AI coding agents working in this repo.

- **Project type**: tiny collection of PowerShell utility scripts. Primary files: `directry_sort.ps1`, `Directory_FileCount.ps1`.
- **Platform**: author uses macOS; scripts are PowerShell (`.ps1`) so `pwsh` (PowerShell Core) is expected to run them on macOS.

- **How to run**:
  - Ensure PowerShell Core is installed: `pwsh --version`.
  - Run scripts from repo root with an explicit command, e.g.: 
    - `pwsh -NoProfile -ExecutionPolicy Bypass -File "./directry_sort.ps1"`
    - `pwsh -NoProfile -ExecutionPolicy Bypass -File "./Directory_FileCount.ps1"`

- **Big picture / why these scripts exist**:
  - These are small helpers for working with files under a directory tree: counting files per directory and producing a `result.txt` list filtered by extension `.jww`.
  - There is no larger application framework here—treat changes as small, self-contained improvements to scripts.

- **Key patterns & conventions (explicit to this repo)**
  - Scripts use `Get-ChildItem` with `-Recurse` and operate on `-File` items.
  - `directry_sort.ps1` (note the filename typo) filters files by extension `.jww` and appends lines to `result.txt` in the current working directory; it deletes `result.txt` at start if present.
  - The sorting in `directry_sort.ps1` calls `Sort-Object -Property { $_.split("/")[4] }, { $_.split("/")[5] }, { $_.split("/")[6] }` — this expects POSIX-style `/` separators and a particular path depth; be careful when altering this logic (Windows `\\` paths behave differently).
  - `Directory_FileCount.ps1` sets `$targetDir` to `‘~/test'` (typographic quotes in the current file) and then enumerates `-Recurse -Directory`; the output uses `Write-Host` with a mixture of Japanese labels.

- **Common pitfalls to avoid**
  - Do not assume a project README or tests exist—changes should include clear usage examples in commit messages or an updated README if you add new behavior.
  - Watch for hard-coded or platform-specific assumptions: path-splitting on `/`, hard-coded `~/test`, writing `result.txt` into CWD.
  - The file `Directory_FileCount.ps1` currently uses typographic single quotes (`‘`/`’`) which may break PowerShell parsing; if editing, normalize to ASCII single quotes `'` or double quotes `"`.

- **If you change behavior**
  - Add a short usage example at top of the modified file showing the exact `pwsh -File` command and expected output (one-liner). This repo has no tests; examples help users run scripts.
  - Preserve existing filenames (e.g., `directry_sort.ps1`) unless you also update documentation/usage; the typo is part of the repo and may be referred to externally.

- **Files to inspect for context**: `./directry_sort.ps1`, `./Directory_FileCount.ps1`.

- **Conventions for commits by AI**
  - Keep edits minimal and focused. If fixing cross-platform issues (path separators, quote characters), include a brief justification in the commit message and update the usage example.

If anything is unclear or you want the file to include a brief README addition or example changes (e.g., normalizing quotes or making path-splitting portable), tell me which change to make next.
