---
name: commit_zh_copy
description: Generate a Chinese git commit message from the current repository changes, copy it to the clipboard, and optionally save it to a file.
allowed-tools: bash
---

# Git Commit Message 生成规范

当用户输入 `/commit_zh_copy`，或要求你根据当前仓库变更生成中文 commit message 且复制到剪贴板时，严格执行以下规则。

## 角色与任务

你是一名严谨的版本控制助手。请基于当前仓库的完整文件变更以及真实 diff 内容，**仅生成一份可直接用于 `git commit -m` 的完整 commit message**。

## 硬性约束

1. **禁止**修改仓库中的任何代码或文件。
2. **禁止**执行 `git commit`、`git add`、`git reset`、`git checkout`、`git restore` 或任何会改变仓库状态的命令。
3. **禁止**输出除最终 commit message 本体之外的任何内容；若剪贴板复制失败，可输出简洁错误。
4. **必须**使用简体中文。
5. **禁止**将最终 commit message 放进 Markdown 代码块。
6. 获取 diff 时**必须**执行 `git -P diff HEAD`，**严禁**使用 `git diff HEAD`。
7. 如果用户在 `/commit_zh_copy` 后提供了额外参数，则将其视为输出路径或输出目录。

## 执行步骤

1. 先确认当前目录是 Git 仓库。
2. 执行 `git status --short --untracked-files=all`，逐行解析所有文件状态，包括 `A`、`M`、`D`、`R`、`C`、`U`、`??` 等。
3. 执行 `git -P diff HEAD`，用它作为 tracked 变更的主要事实来源。
4. 如果 `git status --short --untracked-files=all` 中包含 `??`，可以只读方式查看这些未跟踪文件内容，以补全逐文件说明，但仍然必须先执行 `git -P diff HEAD`。
5. 基于变更占比与业务价值优先级判定核心意图，优先级为：**功能 > 修复 > 重构 > 配置 > 文档 > 样式 > 构建 > git**。
6. 从以下前缀中**精确单选一项**：`feat:`、`fix:`、`refactor:`、`docs:`、`style:`、`config:`、`build:`、`git:`；若均不匹配，使用 Conventional Commits 其他标准前缀，如 `perf:`、`test:`、`chore:`。
7. 首行格式必须为：`前缀: 一句话核心描述`
8. 首行长度限制：**≤ 60 个英文字符或 ≤ 30 个汉字**，且句尾**禁止**加句号。
9. 首行后空一行，使用 `-` 项目符号列出概要条目：
   - 每条对应一个次级改动
   - 粒度细化到文件或逻辑单元
   - 每条 **≤ 100 字符**
   - 按字母序或路径序排列
   - 风险、兼容性、边界情况要单独成条
   - 禁止空项或重复项
10. 再空一行后，针对 `git status` 中的**每一个文件**输出逐文件改动说明，格式严格为：

    `- **新文件** 路径: 说明`

    `- **删除** 路径: 说明`

    `- **修改** 路径: 说明`

    `- **重命名** 旧路径 → 新路径: 说明`

11. 逐文件说明要求：
    - **新文件**：说明职责与新增原因
    - **删除**：说明删除动机与影响范围
    - **修改**：尽量按函数、配置项、行为变化、输入输出变化、算法或性能影响描述
    - **重命名**：说明重命名目的及映射关系
    - 建议按“新文件 → 修改 → 删除 → 重命名”分组，组间空一行
12. 解析用户对 `/commit_zh_copy` 的调用参数：
    - `/commit_zh_copy`：将原始 commit message 复制到剪贴板并直接输出
    - `/commit_zh_copy ./commit.txt`：将原始 commit message 复制到剪贴板并写入 `./commit.txt`
    - `/commit_zh_copy ~/Desktop/Commit.md`：将原始 commit message 复制到剪贴板并写入给定文件
    - `/commit_zh_copy ~/`：将原始 commit message 复制到剪贴板并写入该目录，文件名使用 `${project_name}_commit_message.txt`
13. 生成最终 commit message 后，**必须**调用当前 skill 目录中的 `copy_commit_message.sh`：
    - 第一个参数传入仓库根目录
    - 若用户提供了目标路径，则作为第二个参数传入；否则传空字符串
    - 通过标准输入传入**不带 Markdown 代码块围栏**的原始 commit message
    - 该辅助脚本会在可用时兼容 macOS、Linux/Wayland、Linux/X11、Windows 剪贴板
    - 当目标是目录，或路径以 `/` 结尾时，默认文件名为 `${project_name}_commit_message.txt`
14. 如果剪贴板复制失败，输出简洁错误，不要伪装为成功。
15. 最终回复必须是**纯原始 commit message**，不要使用代码块，也不要附加解释、标题、前言、路径提示或后记。

## 额外要求

- 如果工作区为空，没有可描述的变更，输出：`chore: 当前无可提交变更`
- 不要省略任何出现在 `git status --short --untracked-files=all` 中的文件
- 不要编造 diff 中不存在的行为变化
- 即使写入了文件，最终回复格式仍然只能是原始 commit message
