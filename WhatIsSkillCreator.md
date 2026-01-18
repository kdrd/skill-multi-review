# skill-creator について

## 概要
skill-creatorはAnthropicが公開しているAgent Skillsリポジトリ内の1つのSkillで、「新しいSkillを設計・初期化・パッケージングするガイド兼ウィザード」です。対話形式でSkill作成プロセス全体を誘導してくれます。

## インストール確認
```
/skills
```
一覧にskill-creatorが表示されていれば利用可能。

## インストール手順（未導入の場合）
```
/plugin marketplace add anthropics/skills
/plugin install example-skills@anthropic-agent-skills
```
その後Claude Codeを再起動。

## Skillの基本構造
```
my-skill/
├── SKILL.md          # 必須：概要・説明・リンク
├── references/       # 任意：詳細リファレンスなど
│   └── reference.md
├── scripts/          # 任意：ユーティリティスクリプトなど
│   └── helper.py
└── assets/           # 任意：テンプレート、画像など
```

## SKILL.mdの構成
```yaml
---
name: my-skill-name
description: スキルの説明と、いつ使うべきかを詳しく書く（トリガー条件として重要）
---

# My Skill Name

## 使い方
（Markdownで手順や参照を記述）
```

- `name`: スキルの一意な識別子（小文字、ハイフン区切り）
- `description`: Claudeがスキルを使うかどうかの判断に使用される最重要フィールド

## skill-creatorの対話フロー

### Step 1: 具体例で理解する
「どんな機能が必要か」「どう使われるか」を自然言語で伝える。
例: 「画像編集スキルを作りたい。回転や赤目除去ができるようにしたい」

### Step 2: 再利用可能なリソースを計画する
- scripts/: 繰り返し使うコード（例: rotate_pdf.py）
- references/: 参照ドキュメント（例: schema.md, api_docs.md）
- assets/: 出力に使うファイル（例: テンプレート、ロゴ）

### Step 3: 初期化する
```
scripts/init_skill.py <skill-name> --path <output-directory>
```
テンプレートフォルダが自動生成される。

### Step 4: SKILL.mdを編集する
- descriptionにトリガー条件を詳しく書く
- 本文はMarkdownで指示・例・ガイドラインを記載
- 500行以下に抑える（コンテキストは公共財）

### Step 5: パッケージ化する
```
scripts/package_skill.py <path/to/skill-folder>
```
.skillファイル（zip形式）が生成される。

### Step 6: イテレーション
実際に使ってみて改善を繰り返す。

## 重要な原則

### コンテキストは公共財
- SKILL.mdは短く（500行以下）
- Claudeはすでに賢い。本当に必要な情報だけ追加する
- 「この段落はトークンコストに見合うか？」を常に問う

### 自由度の設定
- 高自由度: テキストベースの指示（複数アプローチが有効な場合）
- 中自由度: 擬似コードやパラメータ付きスクリプト（パターンはあるが変動あり）
- 低自由度: 具体的スクリプト（操作が脆弱でエラーしやすい場合）

### Progressive Disclosure（段階的開示）
1. メタデータ（name + description）: 常にコンテキストに存在（〜100語）
2. SKILL.md本文: スキル発動時のみ読み込み（<5k語）
3. バンドルリソース: 必要時のみ読み込み（無制限）

## 使用例

### 対話でSkillを作成開始
Claude Codeで以下のように伝える：
- 「新しいSkillを作りたい」
- 「BigQueryクエリを書くSkillを作りたい」
- 「PDF編集のSkillを作成したい」

skill-creatorが質問しながら適切なSkillを生成してくれる。

## 参考リンク
- リポジトリ: https://github.com/anthropics/skills
- skill-creator: https://github.com/anthropics/skills/tree/main/skills/skill-creator
- 公式ドキュメント: https://support.claude.com/en/articles/12512198-creating-custom-skills
