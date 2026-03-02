# 35. Search Insert Position  <!-- omit in toc -->

## 1. 問題

### 1.1. リンク

<https://leetcode.com/problems/search-insert-position/description/>

### 1.2. 問題概要 (閲覧制限のある問題の場合のみ)

## 3. ステップ1

### 3.1. コード

標準ライブラリ使うなら；

```python
import bisect
class Solution:
    def searchInsert(self, nums: List[int], target: int) -> int:
        return bisect.bisect_left(nums, target)

```

再実装するなら；

```python
class Solution:
    def searchInsert(self, nums: List[int], target: int) -> int:
        if len(nums) == 0 or target <= nums[0]:
            return 0
        if nums[-1] < target:
            return len(nums)
        if nums[-1] == target:
            return len(nums) - 1
        smaller, greater = 0, len(nums) - 1
        while greater - smaller > 1:
            mid = smaller + (greater - smaller) // 2
            if nums[mid] == target:
                return mid
            if nums[mid] < target:
                smaller = mid
            else:
                greater = mid
        return smaller + 1

```

以下の自然言語の説明を念頭に置いていた；

1. `target` より真に小さいやつと真に大きいやつが居ることを確認して(最初の3つのif文)
   1. いなければ答えはすぐ返せる．
   2. 空配列のときは新たにその要素が挿入されると考えると0を返すのが自然に思えた．
2. そいつらの間に求めたいものが居るんだから，間に1個以上要素がある限り探す．(while文)
   1. 真ん中を調べてみて，もし`target`が見つかったら即座に答えを返す．
   2. 真に小さいか真に大きいかで，対応するインデックスの変数`smaller`, `greater`に記録する．
3. `target`がいなかったんだから，真に小さい要素の次に`target`は挿入されるべきです，と報告する．

### 3.2. 時間・空間計算量

引数`nums` のサイズを$N$として，
時間$O(\log N)$, 空間 $O(1)$．
$N$があまりに巨大なら`smaller`, `greater`, `mid` あたりのサイズがでかくなって空間$O(\log N)$に．

## 4. ステップ2

### 4.1. コード

```python
class Solution:
    def searchInsert(self, nums: List[int], target: int) -> int:
        lo, hi = 0, len(nums)
        while lo < hi:
            mid = lo + (hi - lo) // 2
            if nums[mid] < target:
                lo = mid + 1
            else:
                hi = mid
        return lo
```

### 4.2. 講師陣のコメントとして想定されること

### 4.3. 他の人のコードを読んで考えたこと

標準ライブラリ`bisect.py`の実装

```python
def bisect_left(a, x, lo=0, hi=None, *, key=None):
    """Return the index where to insert item x in list a, assuming a is sorted.

    The return value i is such that all e in a[:i] have e < x, and all e in
    a[i:] have e >= x.  So if x already appears in the list, a.insert(i, x) will
    insert just before the leftmost x already there.

    Optional args lo (default 0) and hi (default len(a)) bound the
    slice of a to be searched.
    """

    if lo < 0:
        raise ValueError('lo must be non-negative')
    if hi is None:
        hi = len(a)
    # Note, the comparison uses "<" to match the
    # __lt__() logic in list.sort() and in heapq.
    if key is None:
        while lo < hi:
            mid = (lo + hi) // 2
            if a[mid] < x:
                lo = mid + 1
            else:
                hi = mid
    else:
        while lo < hi:
            mid = (lo + hi) // 2
            if key(a[mid]) < x:
                lo = mid + 1
            else:
                hi = mid
    return lo

```

- このいきなりwhile文突入の実装，以前見たっきり忘れていた．
  - `bisect_left`
    1. $x \le a[i]$なる最小の$i$が欲しくて，$0\le i\le len(a)$ なのと，条件$x < a[i]$が$i$についての単調性を持つのは知ってる．
       - $a[len(a)]$は適当な番兵が入ってるとみなしておく．実際には$lo=hi=len(a)$にはならないので$a[len(a)]$はアクセスされない．
    2. 求めたい$i$の最小値$lo$と最大値$hi$を管理しよう．
    3. 単調性を使って今後の探索範囲を半々に分けたいから真ん中取って$mid$へ代入．
    4. $x \le a[mid]$ なら$i$の最大値$hi$は$mid$で抑えられるね．そうじゃないときは$i$の最小値$lo$は$mid+1$で抑えられるね．
    5. $lo < hi$ の限りは答えが一つに絞れてないから探索を続けるね．
        - $lo > hi$にはならなそうだし，whileの条件を`lo != hi` にしても動きそうだな〜って思ってLLMに聞いたら以下の2点を指摘され，2つ目は大事なので納得した．
          1. $lo$, $hi$ は答えの最小値・最大値っていう自然に順序を持つ量だからそう宣言するほうが理解しやすい
          2. 呼び出し側が $lo > hi$ になるように呼び出した場合でも無限ループにならずに終了できる(正しい答えは返せないけど)
    6. 最小の$i$が欲しかったんだから$lo$返すね．
  - `bisect_right`
    - `bisect_left` の条件 $x \le a[i]$ が $x < a[i]$ に変わっただけ．
  - 内省；`bisect_left`の子項目にした部分が思い出せないからステップ1みたいな自分が素直にわかる実装をとった
- `#Note, ~` のコメントについて
  - `__lt__` だけあれば他の演算子オーバーロード用のメソッドなくても動くようにしたほうが良いよね，ソートとかが`<`を採用してるからこっちも併せとけばユーザの負担が少ないよね，という話と理解．
  - コードを書く側としては`bisect_left` を実装するときはそのまま `x <= a[i]` と記述したくなるけど， ユーザに`__le__`の実装までも要求したくないから，自然言語で説明の順序が逆転するけど `a[i] < x` を使うのね．
  - 全順序が成り立つなら `functools.total_ordering` で演算子オーバーロード用のメソッドの量を減らせるよと(ただし遅いらしい) <https://docs.python.org/ja/3/library/functools.html#functools.total_ordering>．
- `functools.cmp_to_key` との直接の併用はできないのか．
- `bisect.bisect`って `bisect_right` のエイリアスなんだ．ref. docstring
  - 二分探索後にlistに挿入するケースを考えると後ろに近いインデックスを返すほうが計算量がちょっといいからかな？
  - 二分探索して挿入までやる`bisect.insort`なんてのもあるんだ

- gt32 さん <https://github.com/5103246/LeetCode_Arai60/pull/39/changes>
  - 色々試行錯誤した後，標準ライブラリ`bisect.py` とほぼ同じ実装に収束してる
  - 空配列のときに`-1`を返すのは関数名と相性悪いな〜と思ったらコメントがついていた．
  - 条件を満たすところと満たさないところが切り替わるポイントが配列中にたかだか1個ある，って見方で思い出したこと；
    - 区間の端点として条件を満たす点と満たさない点を保持し続ければ，それらの間に"条件の真偽かの切り替わるタイミングが1個"の制約をはずしても，そのうちの一つを見つけられる．科学計算で$f(x) = 0$ の根を見つけるときとか．

### 4.4. 改善するときに考えたこと

- 標準ライブラリを使った例と違って，targetと等しいような要素が複数含まれていたときに，それらのインデックスのうちの一つを返す実装になっていることに組んでから気づいた．
  - 問題の条件的にはこのケースはないけど考える．
  - while内で見つかったら早期リターンするのは，書く側は楽でいいけど任意の一つを返す実装になる．
  - 呼び出し側としては 1)`bisect_left`, 2) `bisect_right`， 3) 重複要素については任意の一つを返す，を選べたほうがより嬉しいだろうけど，それでもデフォルトは 1 or 2 にしてよさそう．一意に定まるほうが扱いやすそうなので．
  - 今回の問題は`bisect_left`が求められているので，`bisect_left`を実装しましょう．

## 5. ステップ3

ステップ2と同じ．

```python
class Solution:
    def searchInsert(self, nums: List[int], target: int) -> int:
        lo, hi = 0, len(nums)
        while lo < hi:
            mid = lo + (hi - lo) // 2
            if nums[mid] < target:
                lo = mid + 1
            else:
                hi = mid
        return lo
```
