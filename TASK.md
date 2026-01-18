# TASK.md - Multi-Agent Code Review Skill 実装タスク

## オーケストレーション方針

- **オーケストレーター（私）**: タスク管理・進捗監視・品質判断のみ
- **実装**: 全てSubagent/Task Agentに委託
- **サイクル**: 各タスクはPDCA（Plan→Do→Check→Act）で回す

---

## Agent定義

| Agent名 | subagent_type | 役割 | 使用ツール |
|---------|---------------|------|-----------|
| **Explore Agent** | `Explore` | コードベース調査、ファイル探索、パターン分析 | Glob, Grep, Read |
| **Plan Agent** | `Plan` | 設計、アーキテクチャ検討、実装計画作成 | Read, Glob, Grep |
| **Bash Agent** | `Bash` | シェルコマンド実行、ファイル操作、Git操作 | Bash |
| **Code Agent** | `general-purpose` | コード・スクリプト・設定ファイル作成 | Read, Write, Edit |
| **Doc Agent** | `general-purpose` | ドキュメント作成、README、使用例記載 | Read, Write |
| **Test Agent** | `general-purpose` | 動作検証、エラー確認、結果レポート | Bash, Read |
| **Review Agent** | `general-purpose` | 成果物レビュー、品質チェック、改善提案 | Read, Grep |
| **Integration Agent** | `general-purpose` | 3エージェント結果の統合・優先度付け | Read, Grep |
| **Validation Agent** | `general-purpose` | 前提条件チェック、CLI存在確認 | Bash |

---

## 前提条件

| 項目 | 要件 | チェック方法 |
|------|------|-------------|
| Claude Code | 必須 | `command -v claude` |
| Codex CLI | 推奨（v0.87.0+） | `codex --version` |
| Gemini CLI | 推奨（v0.24.0+） | `gemini --version` |
| OPENAI_API_KEY | Codex使用時必須 | `echo $OPENAI_API_KEY` |
| GOOGLE_API_KEY | Gemini使用時必須 | `echo $GOOGLE_API_KEY` |

---

## Phase 1: プロジェクト構造整備

### Task 1.1: ディレクトリ構造作成

**PDCA Cycle:**

| Stage | 担当Agent | 作業内容 | 完了条件 |
|-------|-----------|---------|---------|
| **Plan** | Plan Agent | 必要なディレクトリ構造を設計 | 構造図の出力 |
| **Do** | Bash Agent | ディレクトリ作成 (`skills/multi-review/`) | ディレクトリ存在確認 |
| **Check** | Test Agent | `ls -la` で構造確認 | 期待通りの構造 |
| **Act** | - | 問題があれば修正指示 | - |

**詳細タスク:**
- [x] 1.1.1 `skills/` ディレクトリ作成
- [x] 1.1.2 `skills/multi-review/` ディレクトリ作成
- [x] 1.1.3 構造確認

---

### Task 1.2: .gitignore 更新

**PDCA Cycle:**

| Stage | 担当Agent | 作業内容 | 完了条件 |
|-------|-----------|---------|---------|
| **Plan** | Explore Agent | 現在の.gitignore確認、追加項目洗い出し | 追加項目リスト |
| **Do** | Code Agent | .gitignore更新（一時ファイル、OS固有等） | ファイル更新完了 |
| **Check** | Review Agent | 追加項目の妥当性確認 | レビューOK |
| **Act** | Code Agent | 指摘があれば修正 | - |

**詳細タスク:**
- [x] 1.2.1 現在の.gitignore内容確認
- [x] 1.2.2 追加すべき項目の洗い出し（.DS_Store, *.log, /tmp等）
- [x] 1.2.3 .gitignore更新
- [x] 1.2.4 更新内容レビュー

---

## Phase 2: スキル本体作成

### Task 2.1: SKILL.md 設計

**PDCA Cycle:**

| Stage | 担当Agent | 作業内容 | 完了条件 |
|-------|-----------|---------|---------|
| **Plan** | Plan Agent | SKILL.mdの構造設計、PLAN.mdからの要件抽出 | 要件リスト |
| **Do** | Plan Agent | 設計ドキュメント作成 | 設計書完成 |
| **Check** | Review Agent | 設計の妥当性確認 | レビューOK |
| **Act** | Plan Agent | 指摘反映 | 全指摘解消 |

**詳細タスク:**
- [x] 2.1.1 PLAN.mdから必要情報を抽出（CLI比較表、実行フロー等）
- [x] 2.1.2 公式テンプレート（anthropics/skills）の構造確認
- [x] 2.1.3 SKILL.md構造設計書作成

---

### Task 2.2: SKILL.md 実装

**PDCA Cycle:**

| Stage | 担当Agent | 作業内容 | 完了条件 |
|-------|-----------|---------|---------|
| **Plan** | Plan Agent | Task 2.1の設計に基づく実装計画 | 実装計画書 |
| **Do** | Code Agent | SKILL.md作成 | ファイル作成完了 |
| **Check** | Review Agent | 500行以内、description 200文字以内、必須セクション確認 | レビューOK |
| **Act** | Code Agent | 指摘事項修正 | 全指摘解消 |

**詳細タスク:**
- [x] 2.2.1 Frontmatter（name, description）作成
- [x] 2.2.2 Overview セクション作成
- [x] 2.2.3 Scope セクション作成
- [x] 2.2.4 Usage セクション作成（コマンド例含む）
- [x] 2.2.5 Examples セクション作成（Input/Output）
- [x] 2.2.6 Guidelines セクション作成（安全性、役割分担）
- [x] 2.2.7 全体レビュー・調整

**品質基準:**
- description: 200文字以内
- 全体: 500行以内
- 必須セクション: Overview, Scope, Usage, Examples, Guidelines

---

### Task 2.3: SKILL.md プロンプト設計

**PDCA Cycle:**

| Stage | 担当Agent | 作業内容 | 完了条件 |
|-------|-----------|---------|---------|
| **Plan** | Plan Agent | 3-Way並列実行のプロンプト設計 | プロンプト設計書 |
| **Do** | Code Agent | 各エージェント用プロンプトテンプレート作成 | テンプレート完成 |
| **Check** | Review Agent | 「修正禁止」指示の明確性確認 | レビューOK |
| **Act** | Code Agent | 指摘修正 | - |

**詳細タスク:**
- [x] 2.3.1 Codex CLI用プロンプトテンプレート設計
- [x] 2.3.2 Gemini CLI用プロンプトテンプレート設計
- [x] 2.3.3 Claude Code Task用プロンプトテンプレート設計
- [x] 2.3.4 結果統合用プロンプト設計
- [x] 2.3.5 全プロンプトの一貫性レビュー

---

### Task 2.4: エラーハンドリング設計

**PDCA Cycle:**

| Stage | 担当Agent | 作業内容 | 完了条件 |
|-------|-----------|---------|---------|
| **Plan** | Plan Agent | エラーパターン洗い出し | パターン一覧 |
| **Do** | Code Agent | SKILL.mdにエラーハンドリング追加 | セクション追加 |
| **Check** | Review Agent | 網羅性確認 | 主要パターン網羅 |
| **Act** | Code Agent | 不足パターン追加 | 全パターン対応 |

**詳細タスク:**
- [x] 2.4.1 CLI未インストール時の挙動定義
- [x] 2.4.2 CLI実行タイムアウト時の挙動定義
- [x] 2.4.3 1エージェント失敗時（部分成功）の挙動定義
- [x] 2.4.4 全エージェント失敗時の挙動定義

---

## Phase 3: インストールスクリプト作成

### Task 3.1: install.sh 設計

**PDCA Cycle:**

| Stage | 担当Agent | 作業内容 | 完了条件 |
|-------|-----------|---------|---------|
| **Plan** | Plan Agent | install.shの要件定義、フロー設計 | 要件リスト |
| **Do** | Plan Agent | 設計ドキュメント作成 | 設計書完成 |
| **Check** | Review Agent | 設計の妥当性確認 | レビューOK |
| **Act** | Plan Agent | 指摘反映 | 全指摘解消 |

**詳細タスク:**
- [x] 3.1.1 インストールフロー設計
- [x] 3.1.2 前提条件チェック項目定義
- [x] 3.1.3 エラーハンドリング設計
- [x] 3.1.4 ユーザー確認プロンプト設計

---

### Task 3.2: install.sh 実装

**PDCA Cycle:**

| Stage | 担当Agent | 作業内容 | 完了条件 |
|-------|-----------|---------|---------|
| **Plan** | Plan Agent | Task 3.1設計に基づく実装計画 | 計画書 |
| **Do** | Code Agent | install.sh作成 | ファイル作成完了 |
| **Check** | Test Agent | macOS/Linuxで動作確認 | 両環境で成功 |
| **Act** | Code Agent | 不具合修正 | 全テストパス |

**詳細タスク:**
- [x] 3.2.1 シェバン・set -e 追加
- [x] 3.2.2 変数定義（REPO_DIR, SKILL_NAME, GLOBAL_SKILLS_DIR）
- [x] 3.2.3 前提条件チェック関数実装（claude, codex, gemini）
- [x] 3.2.4 既存インストール確認・上書き確認実装
- [x] 3.2.5 シンボリックリンク作成実装
- [x] 3.2.6 成功メッセージ・使用方法表示実装
- [x] 3.2.7 実行権限付与（chmod +x）
- [x] 3.2.8 動作テスト

---

### Task 3.3: uninstall.sh 実装

**PDCA Cycle:**

| Stage | 担当Agent | 作業内容 | 完了条件 |
|-------|-----------|---------|---------|
| **Plan** | Plan Agent | アンインストールフロー設計 | 設計書 |
| **Do** | Code Agent | uninstall.sh作成 | ファイル作成完了 |
| **Check** | Test Agent | 動作確認（リンク削除確認） | 正常動作 |
| **Act** | Code Agent | 不具合修正 | - |

**詳細タスク:**
- [x] 3.3.1 シンボリックリンク存在確認実装
- [x] 3.3.2 リンク削除実装
- [x] 3.3.3 非リンク（実ディレクトリ）の場合の警告実装
- [x] 3.3.4 実行権限付与
- [x] 3.3.5 動作テスト

---

## Phase 4: ドキュメント整備

### Task 4.1: README.md 作成

**PDCA Cycle:**

| Stage | 担当Agent | 作業内容 | 完了条件 |
|-------|-----------|---------|---------|
| **Plan** | Plan Agent | README構造設計 | 構造案 |
| **Do** | Doc Agent | README.md作成 | ファイル作成完了 |
| **Check** | Review Agent | 必要情報の網羅性確認 | レビューOK |
| **Act** | Doc Agent | 指摘修正 | - |

**詳細タスク:**
- [x] 4.1.1 概要セクション作成
- [x] 4.1.2 前提条件セクション作成
- [x] 4.1.3 インストール手順セクション作成
- [x] 4.1.4 使用方法セクション作成
- [x] 4.1.5 アンインストール手順セクション作成
- [x] 4.1.6 トラブルシューティングセクション作成
- [x] 4.1.7 ライセンス情報追加

---

### Task 4.2: CLAUDE.md 更新

**PDCA Cycle:**

| Stage | 担当Agent | 作業内容 | 完了条件 |
|-------|-----------|---------|---------|
| **Plan** | Explore Agent | 現在のCLAUDE.md確認、更新項目洗い出し | 更新項目リスト |
| **Do** | Doc Agent | CLAUDE.md更新 | 更新完了 |
| **Check** | Review Agent | プロジェクト情報の正確性確認 | レビューOK |
| **Act** | Doc Agent | 指摘修正 | - |

**詳細タスク:**
- [x] 4.2.1 プロジェクト概要更新
- [x] 4.2.2 ディレクトリ構造説明追加
- [x] 4.2.3 開発ガイドライン追加

---

## Phase 5: 動作検証

### Task 5.1: ローカル動作テスト

**PDCA Cycle:**

| Stage | 担当Agent | 作業内容 | 完了条件 |
|-------|-----------|---------|---------|
| **Plan** | Plan Agent | テストシナリオ作成 | シナリオ一覧 |
| **Do** | Test Agent | テスト実行 | 全シナリオ実行 |
| **Check** | Test Agent | 結果確認・レポート作成 | レポート完成 |
| **Act** | Code Agent | 不具合修正 | 全テストパス |

**詳細タスク:**
- [x] 5.1.1 install.sh実行テスト
- [x] 5.1.2 シンボリックリンク確認
- [x] 5.1.3 Claude Codeでスキル認識確認（`/multi-review`）
- [x] 5.1.4 uninstall.sh実行テスト
- [x] 5.1.5 再インストールテスト

---

### Task 5.2: 3-Way並列レビューテスト

**PDCA Cycle:**

| Stage | 担当Agent | 作業内容 | 完了条件 |
|-------|-----------|---------|---------|
| **Plan** | Plan Agent | テスト対象リポジトリ選定、テストケース作成 | テスト計画書 |
| **Do** | Test Agent | `/multi-review` 実行 | 実行完了 |
| **Check** | Review Agent | 3エージェント出力確認、結果統合品質確認 | 品質OK |
| **Act** | Code Agent | SKILL.md調整（必要に応じて） | - |

**詳細タスク:**
- [x] 5.2.1 テスト対象リポジトリ選定
- [x] 5.2.2 Codex CLI単独テスト
- [x] 5.2.3 Gemini CLI単独テスト
- [x] 5.2.4 Claude Code Task単独テスト
- [x] 5.2.5 3-Way並列実行テスト
- [x] 5.2.6 結果統合品質評価
- [x] 5.2.7 エッジケーステスト（大規模リポジトリ、エラー時等）
- [x] 5.2.8 結果統合ロジックテスト（優先度付け確認）

---

## Phase 6: リリース準備

### Task 6.1: Git コミット・プッシュ

**PDCA Cycle:**

| Stage | 担当Agent | 作業内容 | 完了条件 |
|-------|-----------|---------|---------|
| **Plan** | Plan Agent | コミット戦略決定（機能単位 or 一括） | 戦略決定 |
| **Do** | Bash Agent | git add, commit, push | プッシュ完了 |
| **Check** | Test Agent | GitHub上で確認 | リポジトリ更新確認 |
| **Act** | - | - | - |

**詳細タスク:**
- [x] 6.1.1 変更ファイル確認（git status）
- [x] 6.1.2 コミットメッセージ作成
- [x] 6.1.3 コミット実行
- [x] 6.1.4 プッシュ実行
- [x] 6.1.5 GitHub上で確認

---

### Task 6.2: 別環境インストールテスト

**PDCA Cycle:**

| Stage | 担当Agent | 作業内容 | 完了条件 |
|-------|-----------|---------|---------|
| **Plan** | Plan Agent | テスト環境・手順確認 | 手順書 |
| **Do** | Test Agent | GitHubからclone→install.sh実行 | インストール成功 |
| **Check** | Test Agent | スキル動作確認 | 正常動作 |
| **Act** | Doc Agent | README/install.sh修正（必要に応じて） | - |

**詳細タスク:**
- [x] 6.2.1 別ディレクトリでcloneテスト
- [x] 6.2.2 install.sh実行テスト
- [x] 6.2.3 スキル認識・動作確認
- [x] 6.2.4 ワンライナーインストールテスト（curl方式）

---

## 進捗サマリー

| Phase | タスク数 | 完了 | 進捗率 |
|-------|---------|------|--------|
| Phase 1: プロジェクト構造整備 | 2 | 2 | 100% |
| Phase 2: スキル本体作成 | 4 | 4 | 100% |
| Phase 3: インストールスクリプト作成 | 3 | 3 | 100% |
| Phase 4: ドキュメント整備 | 2 | 2 | 100% |
| Phase 5: 動作検証 | 2 | 2 | 100% |
| Phase 6: リリース準備 | 2 | 2 | 100% |
| **合計** | **15** | **15** | **100%** |

---

## 品質ゲート

### Phase 2 完了条件
- [x] SKILL.md が 500行以内
- [x] description が 200文字以内
- [x] 必須セクション（Overview, Scope, Usage, Examples, Guidelines）が存在
- [x] 「修正禁止」指示が全プロンプトに含まれる

### Phase 5 完了条件
- [x] 3-Way並列実行が成功
- [x] 結果統合が正しく動作
- [x] エラー時のフォールバックが機能

---

## 実行順序（依存関係）

```
Phase 1 ─┬─> Phase 2 ──> Phase 3 ──> Phase 4 ──> Phase 5 ──> Phase 6
         │
         └─> Task 1.2 (.gitignore) は独立して実行可能
```

**クリティカルパス:**
1. Task 1.1 (ディレクトリ構造)
2. Task 2.1-2.4 (SKILL.md)
3. Task 3.2 (install.sh)
4. Task 5.1 (動作テスト)
5. Task 6.1 (Git push)

---

## 並列実行可能タスク一覧

### Phase内並列
- Phase 3: Task 3.2 (install.sh) と Task 3.3 (uninstall.sh) は並列可
- Phase 4: Task 4.1 (README) と Task 4.2 (CLAUDE.md) は並列可
- Phase 5: Task 5.2.2, 5.2.3, 5.2.4 (各CLI単独テスト) は並列可

### 独立タスク
- Task 1.2 (.gitignore) は Phase 2 開始後も並列で実行可能

---

*作成日: 2026-01-18*
*オーケストレーター: Claude Code (Opus 4.5)*
