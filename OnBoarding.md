具体的な実行例

anthropics/skillsリポジトリ（https://github.com/anthropics/skills）を参考に、
グローバルに使える新しいスキルを作成してください。

【スキル仕様】
- スキル名: commit-message-generator
- 目的: Git commitメッセージを規約に従って生成
- グローバル用途: 全てのリポジトリで使用可能

【要件】
1. https://github.com/anthropics/skills/blob/main/template/SKILL.md をテンプレートとして使用
2. 以下の形式でコミットメッセージを生成：
   - 形式: <type>(<scope>): <subject>
   - タイプ: feat, fix, docs, style, refactor, test, chore
   - 1行目は50文字以内
   - 本文は72文字で折り返し
3. 既存のスキル例（https://github.com/anthropics/skills/tree/main/skills）を参考にフォーマット

【配置場所】
グローバルスキルとして ~/.claude/skills/commit-message-generator/ に配置可能な形式で生成

【出力】
1. 完全なSKILL.mdの内容
2. 配置手順
3. 使用例

必ずanthropics/skillsリポジトリのテンプレートとサンプルを確認してください。
