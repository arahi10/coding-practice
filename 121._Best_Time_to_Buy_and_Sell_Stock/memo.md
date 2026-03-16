# 121. Best Time to Buy and Sell Stock  <!-- omit in toc -->

## 1. 問題

### 1.1. リンク

<https://leetcode.com/problems/best-time-to-buy-and-sell-stock/description/>

### 1.2. 問題概要 (閲覧制限のある問題の場合のみ)

## 2. 次に取り組む問題のリンク

<>
<!-- markdownlint-disable-file MD033 -->

## 3. ステップ1

愚直解は買う日と売る日の全探索で，与えられるストックプライスが$N$日分だとして$O(N^2)$．
これより計算量が良いアルゴリズムはいろいろある．

<details>
<summary> 素直な線形時間アルゴリズム</summary>
売る日を固定したとき，買う日を全探索しなくても，売る日までの最低価格がわかれば達成できる最大利益が計算できる．
更に，ある日の前日までの最低価格が分かっているなら，その日までの最低価格はすぐにわかる；前日までの最低価格とその日の価格のうち小さいほう．

よって，各日で売る場合の最大利益が効率的に計算できるので，あとは日付順にループを回せば全体としての最大利益が線形時間でわかる．
</details>

時間計算量 $O(N)$ ・空間計算量 $O(1)$ ．

```python
class Solution:
    def maxProfit(self, prices: List[int]) -> int:
        acc_min = float("inf")
        ans = 0
        for price in prices:
            acc_min = min(acc_min, price)
            ans = max(ans, price - acc_min)
        return ans

```

<details>
<summary> 分割統治による $O(N \log N)$ 時間アルゴリズム </summary>

- [アルゴリズムイントロダクション](https://www.amazon.co.jp/%E3%82%A2%E3%83%AB%E3%82%B4%E3%83%AA%E3%82%BA%E3%83%A0%E3%82%A4%E3%83%B3%E3%83%88%E3%83%AD%E3%83%80%E3%82%AF%E3%82%B7%E3%83%A7%E3%83%B3-%E7%AC%AC3%E7%89%88-%E7%B7%8F%E5%90%88%E7%89%88-%E4%B8%96%E7%95%8C%E6%A8%99%E6%BA%96MIT%E6%95%99%E7%A7%91%E6%9B%B8-%E3%82%B3%E3%83%AB%E3%83%A1%E3%83%B3/dp/476490408X), CLRS, の分割統治の章で見たことある．
- 階差を作って部分配列の和の最大化問題に言い換え→"真ん中"をまたぐ部分配列なら線形で最適解を計算出来て，またがない奴は部分問題の解になるから，(またぐやつ, またがない左右の部分問題) の3つに分割して統治する，という方針だったはず．
- 思い出してみる；
  1. ストックプライス列 $\text{prices}$ の長さ$N$ に対して，元問題は$$
  \begin{align*}
   &\underset{0\le i \le j < N} {\text{maximize}}  & \text{prices}[j]-\text{prices}[i].
  \end{align*}
  $$ ここで，階差数列 $\text{diffs}[i] := \text{prices}[i+1]-\text{prices}[i]\ (i=0,\dots,N-2)$ を用いると， $\text{prices}[i] = \text{prices}[0]+\sum_{k=0}^{i-1}\text{diffs}[k]\ (i=0, \dots, N-1)$より， $$
  \begin{align*}
   &\underset{0\le i \le j < N} {\text{maximize}}  & \sum_{k=i}^{j-1}\text{diffs}[k]
  \end{align*}$$ と書き換えられる．すなわち，部分配列の和の最大化問題に帰着できる．
  1. ある部分配列$\text{diffs}[i:j]$に対して，その部分配列$\text{diffs}[k:l]$は，以下の3通りに分類できる
     1. 真ん中より左側 ($l\le \lfloor\frac{i+j}{2}\rfloor$)
        - これは部分問題で，再帰的に解ける
     2. 真ん中より右側 ($\lfloor\frac{i+j}{2}\rfloor\le k$)
        - これも部分問題で，再帰的に解ける
     3. 真ん中を含む ($k<\lfloor\frac{i+j}{2}\rfloor< l$)
        - これは$j-i$に対して線形時間で解ける
  1. ii. の性質により，効率的に解ける．$N$に対する時間計算量を$T(N)$としたとき$$
  \begin{align*}
  T(N) = 2T\left(\frac{N}{2}\right) + \Theta(N)
  \end{align*}
  $$を満たすので，$T(N) = O(N\log N)$.

</details>

時間計算量 $O(N \log N)$・空間計算量 $O(N)$ ．

```python
class Solution:
    def maxProfit(self, prices: List[int]) -> int:
        diffs = [prices[i + 1] - prices[i] for i in range(len(prices) - 1)]
        return self.__max_profit(diffs, 0, len(diffs))

    def __max_profit(self, diffs: List[int], begin: int, end: int) -> int:
        if begin == end:
            return 0
        if end - begin == 1:
            return max(0, diffs[begin])
        center = (begin + end) // 2
        left = self.__max_profit(diffs, begin, center)
        right = self.__max_profit(diffs, center, end)
        center_crossing = self.__find_center_crossing_max_profit(diffs, begin, center, end)
        return max(left, right, center_crossing)

    def __find_center_crossing_max_profit(self, diffs: List[int], begin: int, center: int, end: int) -> int:
        assert begin < center < end

        left_sum = diffs[center - 1]
        left_max_sum = left_sum
        for i in range(center - 2, begin - 1, -1):
            left_sum += diffs[i]
            left_max_sum = max(left_max_sum, left_sum)

        right_sum = diffs[center]
        right_max_sum = right_sum
        for i in range(center + 1, end):
            right_sum += diffs[i]
            right_max_sum = max(right_max_sum, right_sum)

        return left_max_sum + right_max_sum

```

<details>
<summary> 名前がついてる線形時間アルゴリズム</summary>

- なんか線形で解くやつに名前が付いていて，最大化問題を適宜書き換えると帰着できたはず
  - $$
  \begin{align*}
  &\underset{0\le i < j < N} {\text{maximize}}  & \sum_{k=i}^{j-1}\text{diffs}[k]\\
  =&\underset{0< j < N} {\text{maximize}}  & \left\{\underset{0\le i < j} {\text{maximize}}\sum_{k=i}^{j-1}\text{diffs}[k]\right\}\\
  =&\underset{0< j < N} {\text{maximize}}  & P_{j},
  \end{align*}
  $$ where $P_{j}:= \underset{0\le i < j } {\text{maximize}}   \sum_{k=i}^{j-1}\text{diffs}[k]$.
  - $P_{1} = \text{diffs}[0]$ かつ $j>1$に対して$$
\begin{align*}
P_{j} &= \underset{0\le i < j } {\text{maximize}}   \sum_{k=i}^{j-1}\text{diffs}[k]&\\
&=  \max\left(\underset{0\le i < j-1 } {\text{maximize}}   \sum_{k=i}^{j-1}\text{diffs}[k],\; \sum_{k=j-1}^{j-1}\text{diffs}[k]\right)&(i\neq j-1\text{と}i=j-1\text{に分割})\\
&= \max\left(\underset{0\le i < j-1 } {\text{maximize}}   \sum_{k=i}^{j-1}\text{diffs}[k],\; \text{diffs}[j-1]\right)&\\
&= \max\left(\underset{0\le i < j-1 } {\text{maximize}}  \left\{ \sum_{k=i}^{j-2}\text{diffs}[k] + \text{diffs}[j-1]\right\},\; \text{diffs}[j-1]\right),&(k\le j-2\text{と}k=j-1\text{に分割})\\
\therefore P_{j} &= \max\left(P_{j-1} + \text{diffs}[j-1],\; \text{diffs}[j-1]\right).
\end{align*}$$
  - 得られた $P_{j}$ の漸化式から，$\{P_{j}\}_{j=1}^{N-1}$ の計算は全体で $O(N)$ で行える．
  - Kadane's Algorithm.
  - 実装量は少ないだろうが，この流れで思い出すのに紙とペンが必要．
    - ほかの思い出し方としては，ある日$i$に売るときの最大利益が分かっているなら，その次の日$i+1$に売るときの最大利益はすぐに計算できる；日$i$の最大利益を達成する売買と同じ日に買うか，買う日も変えるか．
      - 同じ日に買うときの利益は，$\text{diff}[i]$を日$i$の最大利益に足せば求められる．
        - 利益は買う日を$j$として$\text{prices}[i+1] - \text{prices}[j] = (\text{prices}[i] - \text{prices}[j]) + (\text{prices}[i+1] - \text{prices}[i]) $で，第一項は前日の最大利益，第二項は$\text{diff}[i]$とそれぞれ等しい．
      - 違う日に買うときの最大利益は，日$i$の利益の最大性より，買う日を日$i$にするときしか達成しえない．もし日$k<i$があって，$$\text{prices}[i+1] - \text{prices}[k] > \text{prices}[i+1] - \text{prices}[j]$$ならば，両辺に$\text{prices}[i] - \text{prices}[i+1]$を足せば$$
      \text{prices}[i] - \text{prices}[k] > \text{prices}[i] - \text{prices}[j]$$となるが，これは日$i$で売るときの右辺の最大性に反する．よってこのような日$k < i$は存在しないから，日$i$で買うとするしかない．
      - 動的計画法チックな論法だから思い出しやすいだけで，説明なしに初見で理解できる気がしない．処理の説明は簡単だが，アルゴリズムの正当性の説明は普通に面倒くさい．

</details>

時間計算量 $O(N)$ ・空間計算量 $O(N)$．

```python
class Solution:
    def maxProfit(self, prices: List[int]) -> int:
        # kadane's algorithm
        if len(prices) <= 1:
            return 0
        diffs = [prices[i + 1] - prices[i] for i in range(len(prices) - 1)]
        sell_today = diffs[0]
        max_prof = sell_today
        for j in range(1, len(diffs)):
            sell_today = max(sell_today + diffs[j], diffs[j])
            max_prof = max(max_prof, sell_today)
        return max(0, max_prof)

```

`diffs`を$N$日分すべて同時に記憶しておく必要はないのでジェネレータ式で空間計算量 $O(1)$ にもできる;

```python
class Solution:
    def maxProfit(self, prices: List[int]) -> int:
        # kadane's algorithm
        if len(prices) <= 1:
            return 0
        # 変更開始
        diffs = (prices[i + 1] - prices[i] for i in range(len(prices) - 1))
        sell_today = next(diffs)
        max_prof = sell_today
        for diff in diffs:
            sell_today = max(sell_today + diff, diff)
            # 変更終わり
            max_prof = max(max_prof, sell_today)
        return max(0, max_prof)

```

## 4. ステップ2

### 4.1. コードと改善するときに考えたこと

- 処理を関心で分離するために，`itertools.accumulate` を使う
  - ステップ1のコードでは最大利益の計算とその日までの最低価格の計算が同じ for ループにあり，分離できると思いやってみた
  - ステップ1のコードくらいの処理量だったら分けなくてもよい？と思っていたが，書いてみたら自然言語の説明により近づいていて結構好みだった．
  - `itertools.accumulate`からジェネレータ(とおよそ等価なやつ, [cf](https://docs.python.org/ja/3/library/itertools.html#itertools.accumulate))でもらえるから，空間計算量のオーダーは増えない．
- 変数名の英単語を変に省略しない

```python
import itertools


class Solution:
    def maxProfit(self, prices: List[int]) -> int:
        acc_min_prices = itertools.accumulate(prices, func=min)
        max_profit = 0
        for selling, buying in zip(prices, acc_min_prices):
            max_profit = max(max_profit, selling - buying)
        return max_profit

```

- ロジックを追いやすくするためにエッジケースを早めに処理する
  - `prices` が空配列のときと`len(prices) == 1`のときの扱いを `maxProfit` で明示的に扱うようにした．
    - ステップ1のときは `__max_profit`の `if begin == end: ~` が陰に扱っていた
- わかりやすくするためにインデックスの細々したところをなくす
  - 階差数列`price_changes`の計算に`itertools.pairwise`を使い，for each で書く．
- なるだけ広いユースケースでメソッドを使えるようにする
  - `maxProfit` の `if begin == end` → `if begin >= end: ~` に変更し， (`maxProfit`側でチェック済みだけれども)残しておく
    - カバレッジは減ってしまう（この点では`assert begin < end` のほうが良い）
  - `__find_center_crossing_max_profit` の assert をやめて`float("-inf")`を返す．
    - `left_sum = 0`, `left_max_sum = float("-inf")` (`right_~`も同様)と初期化してfor文の開始インデックスを`center - 1`(`right_~`では`center`)にすれば同様の挙動をするが，エッジケースを早めに処理する意図でこちらを採用．
- なんかのPEPで1行79文字以下推奨だったはずなので多めに改行しておく
  - [PEP8](https://peps.python.org/pep-0008/)でした．
- `__find_center_crossing_max_profit` で`itertools.islice`は以下の2点を理由として使わない．
  - 時間計算量が$O(stop)$っぽいので([cf](https://docs.python.org/3/library/itertools.html#itertools.islice))，全体の計算量を悪化させてしまう．
  - `itertools.islice` は`start, stop`に非負整数，`step` に正整数を要求する．今回の実装は`step = -1`あるいは`stop = -1`(`begin = 0` のとき)とした呼び出しでこの要求に違反する．
    - `begin = 0` のとき，スライスで書いたとしても，`arr[center - 1 : -1 : -1] = []`となってしまい，今回ほしいものである`[arr[center - 1], ..., arr[1], arr[0]]` は取れない．
      - こうなる理由は要調査．
      - 理解では以下の挙動をするから；
        1. $N=len(arr)$としてインデックス `start`,`stop`の評価 ($[-N, N]$にクリップしてから負の数は$+N$して非負にする)
        2. `start`と`step`が等しい，`step`が0，あるいは，$\text{stop} - \text{start}$と`step`が異符号であるときは空配列を返す．
        3. そうでなければ指定されたインデックスの要素を取り出して配列にして返す．

```python
import itertools


class Solution:
    def maxProfit(self, prices: List[int]) -> int:
        if len(prices) < 2:
            return 0
        price_changes = [
            today - yesterday for yesterday, today in itertools.pairwise(prices)
        ]
        return self.__max_profit(price_changes, 0, len(price_changes))

    def __max_profit(self, price_changes: List[int], begin: int, end: int) -> int:
        if begin >= end:
            return 0
        if end - begin == 1:
            return max(0, price_changes[begin])
        center = (begin + end) // 2
        left = self.__max_profit(price_changes, begin, center)
        right = self.__max_profit(price_changes, center, end)
        center_crossing = self.__find_center_crossing_max_profit(
            price_changes, begin, center, end
        )
        return max(left, right, center_crossing)

    def __find_center_crossing_max_profit(
        self,
        price_changes: List[int],
        begin: int,
        center: int,
        end: int,
    ) -> int | float:
        if not begin < center < end:
            return float("-inf")
        left_acc_sums = itertools.accumulate(
            price_changes[i] for i in range(center - 1, begin - 1, -1)
        )
        right_acc_sums = itertools.accumulate(
            price_changes[i] for i in range(center, end)
        )
        return max(left_acc_sums) + max(right_acc_sums)

```

- ロジックを追いやすくするためにエッジケースを早めに処理する
  - (取り除いても期待通り動くけど) `if len(prices) < 2` のif文を残しておく．
- わかりやすくするためにインデックスの細々したところをなくす
  - 階差数列`price_changes`の計算に`itertools.pairwise`を使い，for each で書く．
- 変数名の英単語を変に省略しない

```python
import itertools


class Solution:
    def maxProfit(self, prices: List[int]) -> int:
        # kadane's algorithm
        if len(prices) < 2:
            return 0
        today_max_profit = 0
        max_profit = 0
        price_changes = (
            today - yesterday for yesterday, today in itertools.pairwise(prices)
        )
        for change in price_changes:
            today_max_profit = max(today_max_profit + change, change)
            max_profit = max(max_profit, today_max_profit)
        return max_profit

```

### 4.2. 講師陣のコメントとして想定されること

### 4.3. 他の人のコードを読んで考えたこと

## 5. ステップ3

```python
import itertools


class Solution:
    def maxProfit(self, prices: List[int]) -> int:
        acc_mins = itertools.accumulate(prices, min)
        max_profit = 0
        for buying, selling in zip(acc_mins, prices):
            profit = selling - buying
            max_profit = max(max_profit, profit)
        return max_profit

```

```python
import itertools


class Solution:
    def maxProfit(self, prices: List[int]) -> int:
        if len(prices) < 2:
            return 0
        price_changes = [
            today - yesterday for yesterday, today in itertools.pairwise(prices)
        ]
        max_profit = self.__max_profit(price_changes, 0, len(price_changes))
        return max_profit

    def __max_profit(self, price_changes: List[int], begin: int, end: int) -> int:
        if begin >= end:
            return 0
        if end - begin == 1:
            return max(0, price_changes[begin])
        center = (begin + end) // 2
        left = self.__max_profit(price_changes, begin, center)
        right = self.__max_profit(price_changes, center, end)
        center_crossing = self.__center_crossing_max_profit(
            price_changes, begin, center, end
        )
        return max(left, right, center_crossing)

    def __center_crossing_max_profit(
        self,
        price_changes: List[int],
        begin: int,
        center: int,
        end: int,
    ) -> int | float:
        if not begin < center < end:
            return float("-inf")
        left_acc_sums = itertools.accumulate(
            price_changes[i] for i in range(center - 1, begin - 1, -1)
        )
        right_acc_sums = itertools.accumulate(
            price_changes[i] for i in range(center, end)
        )
        return max(left_acc_sums) + max(right_acc_sums)

```

```python
import itertools


class Solution:
    def maxProfit(self, prices: List[int]) -> int:
        if len(prices) < 2:
            return 0
        today_max_profit = 0
        max_profit = 0
        price_changes = (
            today - yesterday for yesterday, today in itertools.pairwise(prices)
        )
        for change in price_changes:
            today_max_profit = max(today_max_profit + change, change)
            max_profit = max(max_profit, today_max_profit)
        return max_profit

```
