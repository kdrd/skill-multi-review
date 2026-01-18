# タスク：グローバルに有効化可能な新しいスキルを作成

## 目標

- anthropics/skills リポジトリ（https://github.com/anthropics/skills）を参考にスキルを作成
- Claude Code のグローバルスキルとして設定し、全てのリポジトリで使用可能にする

## ステップ 1：anthropics/skills のテンプレートを確認

1. テンプレート確認: https://github.com/anthropics/skills/blob/main/template/SKILL.md
2. サンプル確認: https://github.com/anthropics/skills/tree/main/skills
3. 既存のグローバルスキル（document-skills, example-skills）の構造を理解

## ステップ 2：グローバルスキル用のフォルダ作成

Claude Code のグローバルスキル配置場所：

```
~/.claude/skills/my-skill-name/
└── SKILL.md
```

または、複数スキルをまとめる場合：

```
~/.claude/skills/
├── skill-1/
│   └── SKILL.md
├── skill-2/
│   └── SKILL.md
└── skill-3/
    └── SKILL.md
```

## ステップ 3：SKILL.md を作成

https://github.com/anthropics/skills/blob/main/template/SKILL.md のテンプレートを使用：

```yaml
---
name: your-skill-name
description: このスキルの明確な説明と使用タイミング（200文字以内）
---

# スキルタイトル

## 概要
このスキルの目的と、Claudeが使用すべき状況

## 適用範囲
このスキルは全てのリポジトリで使用可能です。
特に以下の状況で有効：
- ユースケース1
- ユースケース2

## 使用方法
[具体的な使い方]

## 例
### 入力
[入力例]

### 出力
[期待される出力]

## ガイドライン
- ルール1
- ルール2
- ルール3
```

## ステップ 4：グローバルスキルとして配置

### 方法 A：ローカルディレクトリに配置

```bash
# スキルフォルダを作成
mkdir -p ~/.claude/skills/my-skill-name

# SKILL.mdを配置
# （このファイルを ~/.claude/skills/my-skill-name/SKILL.md として保存）
```

### 方法 B：既存のマーケットプレイスに追加

anthropics/skills が既にインストールされている場合、そこに追加することも可能

## ステップ 5：スキルの有効化確認

Claude Code で以下を実行：

```bash
/plugin
```

インストール済みプラグインとスキルが表示され、作成したスキルが含まれているか確認

## ステップ 6：任意のリポジトリでテスト

1. 任意のリポジトリを開く
2. スキルを呼び出すプロンプトを実行
3. Claude がスキルを認識して実行するか確認

## 参考：anthropics/skills の構造

https://github.com/anthropics/skills の構造：

```
skills/
├── .claude-plugin/
│   └── plugin.yml          # プラグイン設定
├── skills/
│   ├── docx/
│   │   └── SKILL.md
│   ├── pdf/
│   │   └── SKILL.md
│   └── [その他のスキル]/
├── template/
│   └── SKILL.md            # テンプレート
└── README.md
```

## 出力要件

以下を生成してください：

1. スキル名とフォルダ名を決定
2. SKILL.md の完全な内容を生成
3. グローバル配置のためのパス指示
4. テスト方法の説明

## 重要事項

- 必ず https://github.com/anthropics/skills のテンプレートを参照
- description は明確に「いつ使うか」を記載（Claude の判断基準）
- グローバルスキルとして、特定のリポジトリに依存しない汎用的な内容にする

グローバル配置の実践手順

# 1. グローバルスキルディレクトリを作成

mkdir -p ~/.claude/skills/your-skill-name

# 2. SKILL.md をコピー（Claude Code が生成したファイル）

cp /path/to/generated/SKILL.md ~/.claude/skills/your-skill-name/

# 3. Claude Code を再起動または設定を再読み込み

# 4. 確認：任意のリポジトリで動作テスト

cd ~/any-repository

# Claude Code でスキルを使用

```

---

## 🔍 グローバルスキルのベストプラクティス

### ✅ 推奨事項
- **汎用性**: 特定のリポジトリに依存しない内容
- **明確な用途**: どんな状況で使うか明示
- **例の充実**: 多様なユースケースの例を含める
- **依存性の最小化**: 外部ツールへの依存を減らす

### 🎯 グローバルスキルに適した例
- コミットメッセージ生成
- コードレビューチェックリスト
- ドキュメント作成
- PR説明文生成
- 命名規則チェッカー
- セキュリティスキャン
- パフォーマンス最適化提案

---

## 💡 最終的な構成イメージ
```

~/.claude/skills/
├── commit-message/
│ └── SKILL.md
├── code-review/
│ └── SKILL.md
├── pr-description/
│ └── SKILL.md
└── docs-generator/
└── SKILL.md
