# Multi-Agent Code Review Skill 設計計画

## 概要

Claude Codeから複数のAIエージェント（OpenAI Codex CLI、Google Gemini CLI、**Claude Code Task agent**）をサブエージェントとして呼び出すスキルを作成する。
MCPではなくSkillとして実装することで、リアルタイム出力と進捗表示を実現する。
最終的には**3並列実行**と結果統合により、複数視点からの高品質なコードレビューを提供する。

## 参考記事

- Codex CLI Skill移行事例: https://zenn.dev/owayo/articles/63d325934ba0de
- Gemini CLI公式: https://github.com/google-gemini/gemini-cli
- Gemini CLI ドキュメント: https://developers.google.com/gemini-code-assist/docs/gemini-cli

## CLI比較表

| 機能 | Codex CLI | Gemini CLI | Claude Code Task Agent |
|------|-----------|------------|------------------------|
| 非対話モード | `codex exec "..."` | `gemini "..."` ※`-p`は非推奨 | Task tool (subagent) |
| 自動承認 | `--full-auto` ※workspace-write含む | `--yolo` / `-y` | プロンプト指示で制御 |
| sandbox | `--sandbox <mode>` | `-s` / `--sandbox` | プロンプトで明示指示 |
| sandbox値 | `read-only`, `workspace-write`, `danger-full-access` | 環境変数`GEMINI_SANDBOX=true\|docker\|sandbox-exec`も可 | N/A |
| 出力形式 | `--json` でJSON可 | `--output-format json` でJSON可 | テキスト出力 |
| コードレビュー拡張 | なし（汎用プロンプト） | `code-review` 拡張（別途インストール必要） | 組み込み分析機能 |
| 無料枠 | なし（API課金） | 60req/min, 1000req/day | Claude Code契約に含む |

### 重要な注意事項（実機検証済み）

1. **Codex `--full-auto`の挙動**:
   - `--full-auto`は自動的に`workspace-write`サンドボックスを適用します
   - **検証結果**: `--full-auto --sandbox read-only`を併用した場合、`read-only`は**無視され`workspace-write`が適用される**
   - 読み取り専用のコードレビューには`--sandbox read-only`を**単独で**使用してください

2. **Gemini `-p`フラグの非推奨**: `-p, --prompt`フラグは非推奨（deprecated）です。代わりに位置引数を使用してください。

3. **Gemini code-review拡張**: code-reviewは組み込み機能ではなく、別途インストールが必要な拡張機能です。

### 検証環境

| CLI | バージョン | モデル | 検証日 |
|-----|-----------|--------|--------|
| Codex CLI | 0.87.0 | gpt-5.2-codex | 2026-01-18 |
| Gemini CLI | 0.24.0 | Gemini 2.0 Flash (Experimental) ※ | 2026-01-18 |

※ 設定では `gemini-3-pro-preview` だが、CLIモードでは `Gemini 2.0 Flash` が使用される（下記参照）

**Gemini CLIモデル設定について:**
- デフォルトモデルは `~/.gemini/settings.json` で確認可能
- `-m` / `--model` フラグで明示的に指定可能
- **注意**: 非対話モード（`-y`）の出力にはモデル名が表示されない
- **モデル確認方法**:
  1. `--output-format json` でJSON出力し、メタデータを確認
  2. `-m <model-name>` で明示的に指定
  3. プロンプト内で「使用モデルを回答に含めて」と依頼

**⚠️ Gemini 3 モデルのアクセス制限（2026-01-18 Perplexity調査）:**

| アクセス方法 | 価格 | Waitlist | 備考 |
|-------------|------|----------|------|
| Google AI Ultra | $20-$50/月 | 不要 | 即時アクセス |
| **Gemini API キー** | 従量課金（~$20/月以下） | **不要** | **推奨：最も手軽** |
| Google AI Pro | 低価格 | 必要 | 承認まで数日〜数週間 |
| Free tier | 無料 | 必要 | 段階的ロールアウト中 |

**✅ 推奨対応策: Gemini API キー（従量課金）**
- Google Cloud から API キーを取得すれば即時アクセス可能
- Ultra サブスクリプション不要、Waitlist 不要
- 使用量に応じた課金（月$20以下で十分な場合が多い）
- 参考: https://ai.google.dev/pricing

**アクセス権がない場合の挙動:**
- `-m gemini-3-pro-preview` を指定しても **Gemini 2.0 Flash** にフォールバック
- エラーにはならず、自動的に利用可能なモデルが選択される

**アクセス権がある場合の有効化手順:**
1. 対話モードで `/settings` → Preview Features を `true`
2. `/model` → Auto (Gemini 3) を選択
3. CLI: `gemini -m gemini-3-pro-preview "<prompt>"`

**参考ドキュメント:**
- [Gemini 3 on Gemini CLI](https://github.com/google-gemini/gemini-cli/blob/main/docs/get-started/gemini-3.md)
- [Perplexity調査結果](https://www.perplexity.ai/search/gemini-cli-gemini-3-pro-previe-kRW92OKRTtmHO.i.F6WGJQ)

### 並列レビュー検証結果（2026-01-18）

対象リポジトリ: `/Users/ryotakadowaki/git/setup`（Brewfile管理）

#### 検証結果サマリー

| 検証項目 | 結果 |
|---------|------|
| 並列実行 | ✅ 3エージェントがバックグラウンドで同時実行可能 |
| 結果取得 | ✅ 各エージェントの出力をファイルに保存・取得可能 |
| 結果統合 | ✅ Claude Codeが全結果を分析・統合可能 |
| 相互補完 | ✅ 異なる観点からの指摘で網羅性向上 |

#### 3-Way並列レビュー検証（2026-01-18）

**実行コマンド:**
```bash
# Codex CLI（バックグラウンド）
codex exec --sandbox read-only "Brewfile, apps/Brewfile.apps, cli/Brewfile.cliをレビュー..." > /tmp/codex_review3.txt 2>&1 &

# Gemini CLI（バックグラウンド）
gemini -s -y "Brewfile, apps/Brewfile.apps, cli/Brewfile.cliをレビュー...ファイルの修正は絶対に行わないでください..." > /tmp/gemini_review3.txt 2>&1 &

# Claude Code Task agent（バックグラウンド）
Task tool: subagent_type=general-purpose, run_in_background=true
```

#### エージェント比較（3-Way）

| 観点 | Codex CLI | Gemini CLI | Claude Code |
|------|-----------|------------|-------------|
| モデル | gpt-5.2-codex | Gemini 2.0 Flash | Claude Opus 4.5 |
| 指摘数 | 4件（重要度付き） | 4件（カテゴリ別） | 4件（構造化） |
| フォーカス | 技術的リスク・依存関係 | 構造・インストール問題 | 全体評価・改善提案 |
| アプローチ | 行番号付き詳細指摘 | カテゴリ別評価 | 優先度付き整理 |

#### 指摘内容の分類（3-Way統合）

**全エージェント共通（最高優先度）:**
| 指摘 | Codex | Gemini | Claude |
|------|:-----:|:------:|:------:|
| `spectacle` 開発終了 → Rectangle推奨 | ✅ | ✅ | ✅ |

**2エージェント以上（高優先度）:**
| 指摘 | Codex | Gemini | Claude |
|------|:-----:|:------:|:------:|
| `zoxide` 自動インストールコメント誤り | ✅ | - | ✅ |
| `mas` 依存問題（単独実行時エラー） | ✅ | - | ✅ |

**単独指摘（中優先度）:**
| 指摘 | エージェント |
|------|-------------|
| `warpd` Cask登録確認必要 | Gemini |
| `kiro` インストールエラー可能性 | Gemini |
| `gcc` ビルド時間長い（Xcode CLT代替可） | Gemini |
| `flux` Night Shift代替可 | Codex |

**肯定的評価（全エージェント共通）:**
- ✅ ファイル分割設計が優秀（Bootstrap/CLI/Apps）
- ✅ mise と Homebrew の役割分担が明確
- ✅ カテゴリ分けが適切で保守性が高い

#### 各エージェントの強み分析

| エージェント | 強み | 適したレビュー対象 |
|-------------|------|-------------------|
| **Codex CLI** | 行番号付き詳細指摘、依存関係分析 | Brewfile、設定ファイル、エラー検出 |
| **Gemini CLI** | インストール問題検出、ベストプラクティス | パッケージ管理、構造評価 |
| **Claude Code** | 全体俯瞰、優先度付け、改善提案 | 結果統合、最終判断 |

#### 結論

3並列実行と結果統合は実用的に機能することを確認。
- **Codex**: 技術的リスク・依存関係エラー検出に強い
- **Gemini**: 構造的健全性・インストール問題検出に強い
- **Claude Code**: 全体俯瞰と優先度付け・改善提案に強い

3エージェント統合により、**単一エージェントでは見落としがちな問題**（spectacleの非推奨、zoxideコメント誤り等）を網羅的に検出可能。

## 目的

- コードレビューと分析の自動化
- 複雑な問題解決を外部エージェントに委託
- Claude Codeが行き詰まった場面での代替視点提供

## MCPからSkillへの移行メリット

| 項目 | 従来（MCP） | 改良後（Skill） |
|------|-----------|----------------|
| 進捗表示 | 見えない | リアルタイム出力で確認可能 |
| 応答時間 | 数十分〜1時間以上の無応答 | ターミナル出力で進捗把握 |
| 制御性 | 中断判断が困難 | 出力を見て中断可能 |

## スキル仕様

### Phase 1: Codex Skill（単体）

#### 基本情報

- **スキル名**: `codex`
- **呼び出し方法**: `/codex`
- **配置場所**: `~/.claude/skills/codex/SKILL.md`

#### 使用コマンド

```bash
# 読み取り専用コードレビュー（推奨）
codex exec --sandbox read-only -C <project_directory> "<request>"

# 書き込みを許可する自動化タスク
codex exec --full-auto -C <project_directory> "<request>"
```

#### パラメータ

| パラメータ | 短縮形 | 説明 |
|-----------|--------|------|
| `--sandbox read-only` | `-s read-only` | 読み取り専用で安全な分析実施 |
| `--sandbox workspace-write` | - | ワークスペースへの書き込み許可 |
| `--full-auto` | - | 低摩擦自動化プリセット（workspace-write + on-request approvals） |
| `--cd` | `-C` | 対象プロジェクトのディレクトリ指定 |
| `--json` | - | JSON形式で出力 |

**⚠️ 検証済み注意事項**:
- `--full-auto`と`--sandbox read-only`を併用した場合、`read-only`は無視され`workspace-write`が適用されます
- 読み取り専用レビューには必ず`--sandbox read-only`を単独で使用してください

---

### Phase 2: Gemini Skill（単体）

#### 基本情報

- **スキル名**: `gemini`
- **呼び出し方法**: `/gemini`
- **配置場所**: `~/.claude/skills/gemini/SKILL.md`

#### 使用コマンド

```bash
# 読み取り専用コードレビュー（推奨）
# -s (sandbox) で隔離環境、-y なしで対話モード（修正を防ぐ）
gemini -s "<request>。ファイルの修正は行わず、レビュー結果のみ出力してください。"

# 非対話モードで読み取り専用レビュー
# プロンプトで明示的に修正禁止を指示
gemini -s -y "<request>。ファイルの修正は絶対に行わないでください。レビュー結果のみ出力してください。"

# パイプでdiffを渡す方法（拡張機能不要）
git diff HEAD~1..HEAD | gemini -s -y "Review these code changes for bugs, security issues, and code quality. Do NOT modify any files."

# JSON出力（スクリプト連携用）
gemini -s -y "<request>" --output-format json
```

**⚠️ 重要: レビュー時のファイル修正防止**
- `-y` (YOLO) モードはツール実行を自動承認するため、**意図しないファイル修正が発生する可能性がある**
- レビュー目的では**プロンプトで明示的に「修正禁止」を指示**することを推奨
- 実装はClaude Codeが担当し、Codex/Geminiは**レビュー専用**として使用する設計

**code-review拡張機能を使用する場合:**
```bash
# 拡張機能のインストール（初回のみ）
gemini extensions install https://github.com/gemini-cli-extensions/code-review

# 拡張機能を使ったコードレビュー
gemini -y "/code-review" > code-review.md
```

#### パラメータ

| パラメータ | 短縮形 | 説明 |
|-----------|--------|------|
| 位置引数 | - | 非対話モードでプロンプトを直接渡す（推奨） |
| `--yolo` | `-y` | ツール実行の確認を全て自動承認 |
| `--sandbox` | `-s` | 隔離環境で実行（`--yolo`使用時は自動有効） |
| `--output-format json` | - | JSON形式で出力（スクリプト連携用） |
| `--output-format stream-json` | - | リアルタイムイベントストリーミング |

**非推奨オプション:**
- `-p` / `--prompt`: 将来削除予定。位置引数を使用してください。

#### sandboxモードの有効化方法

1. **コマンドラインフラグ**: `gemini --sandbox "..."`
2. **環境変数**:
   - `GEMINI_SANDBOX=true` （デフォルト）
   - `GEMINI_SANDBOX=docker` （Dockerベース）
   - `GEMINI_SANDBOX=sandbox-exec` （macOS）

**✅ 検証済み**: `gemini -s -y "prompt"` 形式で正常動作を確認（v0.24.0）

#### Gemini CLI特有の機能

- `code-review` 拡張: 別途インストールが必要な専用コードレビュー機能
  - リポジトリ: https://github.com/gemini-cli-extensions/code-review
- GitHub Action連携: `google-github-actions/run-gemini-cli`
- スラッシュコマンド: `/code-review`（拡張機能インストール後に使用可能）

---

### Phase 3: 並列レビュー Skill（3-Way）

#### 基本情報

- **スキル名**: `multi-review`
- **呼び出し方法**: `/multi-review`
- **配置場所**: `~/.claude/skills/multi-review/SKILL.md`

#### 実行フロー（3-Way）

```
┌─────────────────────────────────────────────────────────────────────┐
│                       /multi-review 実行                             │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
         ┌─────────────────────┼─────────────────────┐
         ▼                     ▼                     ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   Codex CLI     │  │   Gemini CLI    │  │  Claude Code    │
│  (gpt-5.2)      │  │  (Gemini 2.0)   │  │  (Task Agent)   │
│  (並列実行)      │  │  (並列実行)      │  │  (並列実行)      │
└────────┬────────┘  └────────┬────────┘  └────────┬────────┘
         │                    │                    │
         └────────────────────┼────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                 Claude Code による結果統合                           │
│  1. 3エージェントの結果を分析                                        │
│  2. 全エージェント共通指摘 → 最高優先度                               │
│  3. 2エージェント以上の指摘 → 高優先度                                │
│  4. 単独指摘 → 中優先度（内容精査）                                   │
│  5. 統合レビュー案を作成                                             │
└──────────────────────────────┬──────────────────────────────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                 ユーザーへの提示と最終判断                            │
│  - 優先度付き統合案を提示                                            │
│  - 各エージェントの個別見解も参照可能                                 │
│  - ユーザーが最終的に採用内容を決定                                   │
└─────────────────────────────────────────────────────────────────────┘
```

#### 並列実行の実装方法（3-Way）

```bash
# バックグラウンドで3並列実行（読み取り専用コードレビュー）
codex exec --sandbox read-only -C <project_directory> "<request>" > /tmp/codex_result.txt 2>&1 &
gemini -s -y "<request>。ファイルの修正は絶対に行わないでください。" > /tmp/gemini_result.txt 2>&1 &
# Claude Code Task agent はTask toolで run_in_background=true として実行
wait

# JSON出力での並列実行（結果統合しやすい）
codex exec --sandbox read-only --json -C <project_directory> "<request>" > /tmp/codex_result.json 2>&1 &
gemini -s -y "<request>" --output-format json > /tmp/gemini_result.json 2>&1 &
# Claude Code Task agent はテキスト出力
wait
```

#### 結果統合ロジック

| 統合基準 | 説明 |
|---------|------|
| 共通指摘 | 両方が指摘 → 高優先度として採用 |
| 単独指摘 | 片方のみ指摘 → 内容を精査して提示 |
| 相反指摘 | 矛盾する指摘 → 両方の根拠を提示しユーザー判断 |

#### ユースケース

1. **重要なPRレビュー**: 複数視点での品質チェック
2. **アーキテクチャ決定**: 異なるAIからの設計提案比較
3. **デバッグ**: 複数エージェントでの問題分析
4. **セカンドオピニオン**: Claude Codeの判断を他エージェントで検証

## ユースケース

1. **コードレビュー**: プロジェクト全体のコード品質分析
2. **バグ調査**: 特定のエラーや問題の原因調査
3. **リファクタリング提案**: 改善点の洗い出し
4. **セカンドオピニオン**: Claude Codeとは異なる視点からの分析

## 実行フロー

1. ユーザーが `/multi-review` でスキル呼び出し
2. 依頼内容を受け取る
3. 現在のプロジェクトディレクトリを特定
4. 3エージェントを並列実行（Codex CLI + Gemini CLI + Claude Code Task）
5. 各エージェントの結果を収集
6. Claude Code（メイン）が結果を統合・優先度付け
7. 統合レビュー結果を報告

---

## Skill作成方針

### ディレクトリ構造

```
~/.claude/skills/
└── multi-review/
    └── SKILL.md          # 3-Way並列レビュースキル
```

### SKILL.mdテンプレート構造

```yaml
---
name: multi-review
description: 200文字以内の説明（Claudeの起動判断に使用）
---

# Overview
スキルの概要説明

# Scope
対象となるユースケース

# Usage
使用方法とコマンド例

# Examples
## Input
ユーザー入力例

## Output
期待される出力例

# Guidelines
実行時のガイドライン・制約
```

### 設計原則

| 原則 | 説明 |
|------|------|
| **description重要** | Claudeがスキル起動を判断する基準（max 200文字） |
| **500行以内** | コンテキストトークン節約のため |
| **汎用性** | リポジトリ非依存で設計 |
| **最小依存** | 外部依存を最小限に |
| **Progressive Disclosure** | メタデータ(~100語)→本文(<5k語)→リソース(オンデマンド) |

### 参考リソース

- **テンプレート**: https://github.com/anthropics/skills/blob/main/template/SKILL.md
- **公式ドキュメント**: https://support.claude.com/en/articles/12512198-creating-custom-skills
- **skill-creator**: `/plugin marketplace add anthropics/skills` でインストール可能

---

## 実装ロードマップ

### 方針変更: 直接 `/multi-review` を実装

検証結果から、単体スキル（`/codex`, `/gemini`）を経由せず、**直接 `/multi-review`（3-Way統合版）を実装**する方針に変更。

**理由:**
- 3-Way並列実行の検証が完了し、実用性が確認済み
- 単体スキルは `/multi-review` の内部ロジックとして包含される
- 開発工数の削減と早期実用化を優先

### Phase 1: multi-review スキル開発（直接実装）

| タスク | 状態 | 備考 |
|--------|------|------|
| SKILL.md作成 | [ ] | 3-Way並列レビュー機能 |
| `~/.claude/skills/multi-review/` 配置 | [ ] | |
| 動作確認テスト | [ ] | Codex + Gemini + Claude Code Task |
| ドキュメント整備 | [ ] | 使用方法・例の記載 |

### Phase 2: 将来拡張（検討中）

- 他のcoding agent追加（Copilot CLI、Aider、Cursor等）
- N-way並列レビュー（4エージェント以上）
- 結果の永続化・履歴管理
- プロジェクト固有の設定対応
- CI/CD連携（GitHub Actions等）
- レビュー結果のスコアリング・可視化

## 注意事項

### 前提条件

| エージェント | インストール要件 |
|-------------|-----------------|
| Codex CLI | `npm install -g @openai/codex` またはbrew |
| Gemini CLI | `npm install -g @google/gemini-cli` |

### 安全性

**役割分担の原則:**
- **Claude Code（メイン）**: 実装・修正を担当、結果統合
- **Codex/Gemini/Claude Code Task**: **レビュー専用**（ファイル修正は行わない）

**理由:**
- 意図しない修正が入るリスクを回避
- レビューの本来の目的（問題の指摘）を維持
- 修正の判断はユーザーとClaude Code（メイン）が行う

**sandboxモードの使用:**
- Codex: `--sandbox read-only` で読み取り専用（`--full-auto`は使用しない）
- Gemini: `--sandbox` + プロンプトで「修正禁止」を明示指示
- Claude Code Task: プロンプトで「レビューのみ、変更禁止」を明示指示
- 全エージェントが本番環境への書き込みを行わない設計

### パフォーマンス

- 各エージェントは数十秒〜数分かかる可能性
- 並列実行により合計時間を短縮
- ターミナル出力で進捗確認可能

## 特記事項

- 曖昧なものは『AskUserQuestionTool』を使って必ずヒヤリングする
- 計画時に事前調査が必要なものは調べること
- 調査時にエビデンスが不足しているのであれば https://www.perplexity.ai/ で 調査すること　(claude in chromeでwebアクセスして調査できる)

---

*作成日: 2026-01-18*
*最終更新: 2026-01-18（直接/multi-review実装方針・Skill作成方針追加）*

## 調査ソース

- [OpenAI Codex CLI - GitHub](https://github.com/openai/codex/tree/main/codex-cli)
- [OpenAI Codex CLI - 公式ドキュメント](https://developers.openai.com/codex/cli/reference)
- [Google Gemini CLI - GitHub](https://github.com/google-gemini/gemini-cli)
- [Google Gemini CLI - Headless Mode](https://google-gemini.github.io/gemini-cli/docs/cli/headless.html)
- [Gemini CLI code-review拡張](https://github.com/gemini-cli-extensions/code-review)
