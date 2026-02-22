<!-- PR のタイトルには， LeetCode の問題タイトルを含める．-->
<!-- レビュー依頼定型文
[問題とそのリンク]を解きました．
[Pull Request の URL]
レビューをお願いします．
 -->
# Two Sum <!-- omit in toc -->

## 1. 問題

### 1.1. リンク

<https://leetcode.com/problems/two-sum/>

### 1.2. 問題概要 (閲覧制限のある問題の場合のみ)

## 2. 次に取り組む問題のリンク

<https://leetcode.com/problems/search-insert-position>

## 3. ステップ1

### 3.1. コード

```python
class Solution:
    def twoSum(self, nums: List[int], target: int) -> List[int]:
        num2idx = {}
        for i, num in enumerate(nums):
            required = target - num
            if required in num2idx:
                return [i, num2idx[required]]
            num2idx[num] = i

```

### 3.2. 時間・空間計算量

引数に与えられる配列のサイズを$N$, 配列中のユニークな要素の総数を$M (\le N)$とする．

時間$O(N)$, 空間$O(M)\; ( = O(N))$．

## 4. ステップ2

### 4.1. コード

解が見つからなかった場合の例外処理を追加；

```python
class Solution:
    def twoSum(self, nums: List[int], target: int) -> List[int]:
        num2idx = {}
        for i, num in enumerate(nums):
            required = target - num
            if required in num2idx:
                return [i, num2idx[required]]
            num2idx[num] = i
        raise ValueError("no two sum solution")

```

### 4.2. 講師陣のコメントとして想定されること

- 辞書と線形探索の速度比較
- 組み込み関数 `enumerate` の詳細(？)

### 4.3. 改善するときに考えたこと

- 問題では答えの存在を仮定してよかったが，見つからなかった場合の処理をどうしよう．
  - step1時点のコードではNoneが返される．
  - 選択肢
    - `None`を返す(そのまま)．(返り値の型ヒントを`Optional[List[int]]`に変える)
    - `[None, None]` とかにする．(返り値の型ヒントを`List[Optional[int]]`に変える)
    - 例外を出す．
      - どんな例外が適切だっけ，Javaなら`NoSuchElementException`, `IllegalArgumentException` あたりだろうけど．
      - <https://docs.python.org/ja/3/library/exceptions.html#exception-hierarchy>見る→`ValueError("No two sum solution")` くらいかな．
        - エラーメッセージって小文字始まりのほうがいい気がしてきた；

```python
>>> [][100]
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
IndexError: list index out of range
```

- 検討
  - `None` 系統は見つからなかった場合のこの関数の挙動を知らない人にとっては，呼び出し側で実際にエラーが出る箇所が`twoSum`の呼び出しとは違う・パッと見でなぜそのエラーが引き起こされたか(`None`が返ってきているから)を理解しにくいエラーメッセージが出そう．この点では例外投げるほうはその点では親切かなぁ．エラーメッセージで最低限自然言語で説明できるし．
    - 実際の業務で書くなら`None`にせよ例外にせよdocstringに仕様を書く前提．

### 4.4. 他の人のコードを読んで考えたこと

- uehara さん <https://github.com/X-XsleepZzz/leetcode/pull/12/changes>, Mari さん <https://github.com/mt2324/leetcode/pull/2/changes/4cbafe39511752cc9076d060199e4099748f0a39>
  - やっぱり例外処理派かぁ

## 5. ステップ3

ステップ2と同じ．
