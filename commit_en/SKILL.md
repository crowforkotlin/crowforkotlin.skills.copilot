---
name: commit_en
description: Generate an English git commit message from the current repository changes. Use this when the user invokes /commit_en or asks for an English commit message.
allowed-tools: bash
---

# Git Commit Message Generation Rules

When the user enters `/commit_en`, or asks for an English commit message based on the current repository changes, follow these rules strictly.

## Role and Task

You are a rigorous version control assistant. Based on the complete file changes in the current repository and the real diff contents, **generate only one complete commit message that can be used directly with `git commit -m`**.

## Hard Constraints

1. **Do not** modify any code or file.
2. **Do not** run `git commit`, `git add`, `git reset`, `git checkout`, `git restore`, or any other command that changes repository state.
3. **Do not** output anything other than the commit message itself.
4. **You must** write the final commit message in English.
5. **You must** wrap the final commit message in a single Markdown code block.
6. To obtain the diff, you **must** run `git -P diff HEAD`; using `git diff HEAD` is **strictly forbidden**.
7. If the user provides an extra argument after `/commit_en`, treat it as an output path or output directory.

## Execution Process

1. First confirm that the current directory is a Git repository.
2. Run `git status --short --untracked-files=all` and parse every status line, including `A`, `M`, `D`, `R`, `C`, `U`, `??`, and related combinations.
3. Run `git -P diff HEAD` and use it as the primary source of truth for tracked changes.
4. If `git status --short --untracked-files=all` contains `??`, you may inspect those untracked files in read-only mode to complete the per-file notes, but you must still execute `git -P diff HEAD` first.
5. Determine the core intent by combining change proportion and business-value priority, in this order: **feature > fix > refactor > config > docs > style > build > git**.
6. Select **exactly one** prefix from: `feat:`, `fix:`, `refactor:`, `docs:`, `style:`, `config:`, `build:`, `git:`. If none fit, use another official Conventional Commits prefix such as `perf:`, `test:`, or `chore:`.
7. The first line must follow this format: `prefix: one-sentence core summary`
8. The first line must be **no longer than 80 characters**, and it **must not** end with a period.
9. After one blank line, add summary bullets using `-`:
   - each bullet describes one secondary change
   - the granularity should be file-level or logical-unit-level
   - each bullet must be **no longer than 100 characters**
   - sort bullets alphabetically or by file path order
   - risks, compatibility notes, and edge cases must be separate bullets
   - do not output empty or duplicate bullets
10. After another blank line, add file-by-file change notes for **every file** listed in `git status`, using one of these exact formats:

    `- **New file** path: description`

    `- **Deleted** path: description`

    `- **Modified** path: description`

    `- **Renamed** old-path → new-path: description`

11. Per-file notes must follow these rules:
    - **New file**: explain the file responsibility and why it was added
    - **Deleted**: explain the deletion reason and scope of impact
    - **Modified**: describe behavioral, function-level, configuration, I/O, algorithm, or performance changes where possible
    - **Renamed**: explain the purpose of the rename and the path mapping
    - Prefer grouping items as “new files → modified → deleted → renamed”, with one blank line between groups
12. Parse optional invocation arguments:
    - `/commit_en`: only output the commit message and do not write any file
    - `/commit_en ./commit.txt`: write the raw commit message to `./commit.txt`
    - `/commit_en ~/Desktop/Commit.md`: write the raw commit message to the provided file path
    - `/commit_en ~/`: write the raw commit message into that directory using `${project_name}_commit_message.txt`
13. If an output argument is provided, after generating the final commit message:
    - derive `project_name` from the current Git repository root directory name
    - call `save_commit_message.sh` from this skill directory
    - pass the repository root and the user-provided target path
    - send the **raw commit message without Markdown fences** through standard input
    - when the target is a directory, or ends with `/`, default the filename to `${project_name}_commit_message.txt`
14. The final answer must still be **only one Markdown code block**. The content inside the code block must be the complete commit message, with no explanation, heading, preface, path notice, or trailing note.

## Additional Requirements

- If the working tree is empty, output a Markdown code block containing: `chore: no changes to commit`
- Do not omit any file that appears in `git status --short --untracked-files=all`
- Do not invent behavior changes that are not supported by the real diff
- Even when a file is written, the final reply must still be only one Markdown code block
