# Project Adoption

This note gives the bounded routes for bringing ai-collaboration into a real
project. Each route names the project root, the authorization needed for real
writes and the verification it supports. A fixture run or a package check is
not a real deployment, and neither proves host loading or business acceptance.

Use absolute paths in every command. Replace `E:\Projects\your-project` with
the actual project root and run the package manager from the package directory.

## Before Any Route

1. Confirm the target project root and the exact package version.
2. Read the project's own `AGENTS.md` and any other active controller
   documents. Note which entries an agent actually reads.
3. Back up every entry file that a route will touch, outside the project if the
   content is sensitive. Record its SHA256.
4. Do not commit to Git, change global tool settings or start a business run as
   part of adoption.

## Route A: Full Package, Managed Ownership

Use this when the project should receive the whole package and the manager
should own the installed files and managed blocks.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\manage.ps1 -Action CheckVersion -ProjectRoot 'E:\Projects\your-project'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\manage.ps1 -Action Install -ProjectRoot 'E:\Projects\your-project' -WorkflowMode optional
powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'E:\Projects\your-project\docs\ai-collaboration\scripts\doctor.ps1' -WorkspaceRoot 'E:\Projects\your-project' -PackageRoot 'E:\Packages\engrelay-1.7.0'
```

`CheckVersion` is read-only. It reports the installed version, workflow mode and
whether an upgrade is possible. `Install` stops before any write when a
preexisting file differs from the package copy. Resolve that conflict with a
bounded comparison, not a forced overwrite.

Upgrading a manager-owned installation from packageVersion 1.2.0 to 1.4.0 adds
the three diagnostic files (`scripts/doctor.ps1`, `host-capabilities.md`,
`project-adoption.md`) and `scripts/find-solutions.ps1`; from 1.3.0 it adds only
`scripts/find-solutions.ps1`. The manager refuses the upgrade unless every add or
retire is registered for the installed version. A project file that already
exists with identical bytes becomes project-owned; different bytes refuse the
upgrade before any write.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\manage.ps1 -Action Upgrade -ProjectRoot 'E:\Projects\your-project'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'E:\Projects\your-project\docs\ai-collaboration\scripts\doctor.ps1' -WorkspaceRoot 'E:\Projects\your-project' -PackageRoot 'E:\Packages\engrelay-1.7.0' -Host codex
```

If an upgrade is interrupted, the manifest phase becomes `upgrading`. Later
management actions refuse to report success. Keep the retained recovery files
in `.ai-collaboration-install/` (`manifest-upgrade-*.json`, `upgrade-files-*.json`),
compare them with the current bytes, and restore each named file individually.
Doctor reports the interrupted phase as a required failure.

Change the mode with `SetMode`, not by editing the managed block. Remove the
installation with `Uninstall`, which deletes only unchanged package-created
files and managed blocks; project-owned files, later outside edits and runtime
evidence are kept.

## Route B: Selective Generic Rules

Use this when the project only wants to absorb generic collaboration rules and
does not want the manager to own any file.

1. Copy the wanted rule text into a project-owned section of its own `AGENTS.md`
   or into its own document, with a clear heading and a source note.
2. Do not add the package managed markers and do not create `.ai-collaboration-install/`.
3. Keep the project's existing rules, task evidence and any other workflow
   documents unchanged; do not delete the whole file.
4. Run the read-only doctor. Ownership is reported as not installed and the
   entry facts show what is present:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'E:\Packages\engrelay-1.7.0\payload\docs\ai-collaboration\scripts\doctor.ps1' -WorkspaceRoot 'E:\Projects\your-project' -PackageRoot 'E:\Packages\engrelay-1.7.0'
```

This route gives no manager ownership, no automatic upgrade and no managed
uninstall. Later changes must be made by hand and reviewed as project content.

## Known Legacy Adoption

For version 1.5.3, the catalogue also recognizes the reviewed retired notice profile. It requires the exact normalized hash of `docs/ai-collaboration/README.md`; the former core files and old entry controls may be absent. The known `docs/solutions/solution.template.md` remains optional and hash checked when present. All unknown existing payload paths and residual old activation or partial managed markers remain conflicts.

如果项目已有本包 catalogue 中的完整旧 profile，按下面的包命令请求有界接管。`Preview` 只读；它会先验证完整 profile、旧入口的唯一精确已知片段、路径类型和冲突，然后才允许 Adopt。旧入口文件可以有换行、BOM 或片段外项目内容变化；未知、重复或部分片段仍拒绝。命中后，canonical 文件会保存原始字节并纳入管理；`docs/reviews/README.md` 与 `docs/solutions/README.md` 始终留在原位置并允许项目后续编辑。不要手写 manifest、标记或迁移脚本，也不要把项目索引搬到别处。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\manage.ps1 -Action Adopt -Preview -ProjectRoot 'E:\Projects\your-project' -WorkflowMode optional
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\manage.ps1 -Action Adopt -ProjectRoot 'E:\Projects\your-project' -WorkflowMode optional
powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'E:\Projects\your-project\docs\ai-collaboration\scripts\doctor.ps1' -WorkspaceRoot 'E:\Projects\your-project' -PackageRoot 'E:\Packages\engrelay-1.7.0'
```

若已有 `.ai-collaboration-install/manifest.json`，使用 `Upgrade` 或先保留现场人工协调；Git 恢复留下的清单、未知入口、部分 profile 和任意不匹配文件都会拒绝接管。拒绝时只处理报告的具体冲突，不使用 Force。

## Unmanaged Legacy Integration

Use this when an entry already contains older collaboration instructions with
no trustworthy package ownership record. The package never claims those lines.

1. Save a private backup of each entry and of any `.ai` or review evidence that
   the new route might change. Record the path, byte count and SHA256.
2. Separate active legacy routing from project safety, test, module and OpenSpec
   constraints. Stop the legacy routing with a bounded edit of the named lines;
   do not delete the whole `AGENTS.md`.
3. Check every actual entry the tools read. Only stop the duplicate controller
   that the current task does not select.
4. Keep history files and label them as historical instead of deleting them.
5. Only after the legacy entry is clean may Route A `Install` add managed
   ownership. The manager refuses an unmarked legacy rules section.

Manual reconciliation is one bounded change set with a single summary. Do not
restore the whole project from the original backup over later edits.

## Verification Boundary

- Fixture runs in disposable temporary roots show package behavior only.
- A doctor report shows files and ownership facts. It does not run the host.
- Real project adoption, pilot, host loading, business runtime and release each
  need their own authorized task and evidence. Until then they remain
  unperformed.
