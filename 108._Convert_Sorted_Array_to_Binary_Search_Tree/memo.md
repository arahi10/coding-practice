# 108. Convert Sorted Array to Binary Search Tree  <!-- omit in toc -->

## 1. 問題

### 1.1. リンク

<https://leetcode.com/problems/convert-sorted-array-to-binary-search-tree/description/>

### 1.2. 問題概要 (閲覧制限のある問題の場合のみ)

## 2. 次に取り組む問題のリンク

<https://leetcode.com/problems/best-time-to-buy-and-sell-stock/description/>

## 3. ステップ1

### 3.1. コード

再帰処理ならこんな感じ；左右の部分木については再帰してお任せ．自分は計算してもらった部分木の根を左右の子供に据えて終わり．

```python
def build_binary_search_tree(array:List[int], begin:int, end:int) -> Optional[TreeNode]:
    if begin >= end:
        return None
    mid = (begin + end) // 2
    left = build_binary_search_tree(array, begin, mid)
    right = build_binary_search_tree(array, mid+1, end)
    return TreeNode(val=array[mid], left=left, right=right)
```

反復処理．
(部分木の根， 対応する部分配列の開始インデックス，終了インデックス) の組を順に処理することだけを考えていたらそれ以外が不自然になった；

- 再帰処理では左右の子供がNoneかどうかをチェックする必要がなかったのに，この実装だと部分木の根を先に作成する都合上，
- 変数のシャドーイングに無頓着 (`begin`, `end`)．
- 再帰処理を思い浮かべた後なのに手癖でBFSしてる．
- 実装が再帰処理に比べてやや強引．

```python
from collections import deque


class Solution:
    def sortedArrayToBST(self, nums: List[int]) -> Optional[TreeNode]:
        if len(nums) == 0:
            return None
        begin = 0
        end = len(nums)
        root = TreeNode(val=nums[( begin + end ) // 2])
        dq = deque([(root, begin, end)])
        while dq:
            sub_root, begin, end = dq.popleft()
            mid = (begin + end) // 2
            if begin < mid:
                sub_mid = (begin + mid) // 2
                sub_root.left = TreeNode(val=nums[sub_mid])
                dq.append((sub_root.left, begin, mid))
            if mid + 1 < end:
                sub_mid = (mid + 1 + end) // 2
                sub_root.right = TreeNode(val=nums[sub_mid])
                dq.append((sub_root.right, mid + 1, end))
        return root

```

### 3.2. 時間・空間計算量

`nums` のサイズを$N$ とする．
`nums`のすべての要素をそれぞれちょうど1回だけ部分木の根として扱うので，$N$回は確定．
さらに，二分探索木の葉の子(Noneになるやつら)に対応する部分配列をdequeに入れる回数は高々二分探索木の葉の2倍で，二分探索木の葉は高々$\lfloor \frac{N+1}{2} \rfloor$なので，全体の反復回数も$O(N)$．
よって，時間計算量$O(N)$．

空間計算量も，以下の2点により$O(N)$；

- 引数の配列 ... $N$個の要素を持つ．
- 新たに作るノード ... ちょうど $N$ 個．
- deque が持ちうる最大の要素数 ... 二分探索木の葉の個数($:=m$)の二倍と一緒なので，$2m\ge 2\lfloor \frac{N+1}{2}\rfloor = N+1$ より$O(N)$個.
  - BFSじゃなくてDFSにすればここは$O(\log N)$になる．(二分探索木の深さを$d$として高々$d+2$個しかスタックに積まないので)

## 4. ステップ2

### 4.1. コード

```python
class Solution:
    def sortedArrayToBST(self, nums: List[int]) -> Optional[TreeNode]:
        if len(nums) == 0:
            return None
        root_idx = len(nums) // 2
        root = TreeNode(val=nums[root_idx])
        stack = [
            (root, False, root_idx + 1, len(nums)),
            (root, True, 0, root_idx),
        ]
        while stack:
            parent, is_left, begin, end = stack.pop()
            if begin >= end:
                continue
            mid = (begin + end) // 2
            child = TreeNode(val=nums[mid])
            if is_left:
                parent.left = child
            else:
                parent.right = child
            stack.append((child, False, mid + 1, end))
            stack.append((child, True, begin, mid))
        return root

```

### 4.2. 講師陣のコメントとして想定されること

### 4.3. 他の人のコードを読んで考えたこと

- [りょう](https://github.com/ryoooooory/LeetCode/pull/27/changes) さん
  - タブサイズ2のときは4の時に比べてブロックの識別性がやや下がる気がする．

- [h1rosaka](https://github.com/h1rosaka/arai60/pull/27/changes#diff-7e1a92af8dc65ffab400b9bf2416693d15f370a5cfb6ac37e009f85a67c03a32) さん
  - `is_left` に相当する変数として文字列の `direction` を使っていた，定数に置くかしたいなぁ → コメントでは「Enum使いましょう」，その通りだ
  - BFSのためのスタック変数名 `stack` にコメントが入っていた，僕はBFSするんだね～とwhile文冒頭でわかる点において，まだ技術ドリブン命名のなかではセーフよりだと考えている．が， `stack` と書いてあとでdfsに直した時にそのままの変数名にして罠作る可能性も0じゃない．

### 4.4. 改善するときに考えたこと

- 変数のシャドーイングをなくす(`begin`, `mid`, `end` は while ループに取っておく．)
  - while より前の `mid` → `mid`というよりかは根の要素をどこに取ってくるか？なのでそういう名前にする．
  - while より前の `begin`, `end`をどうするか？
    - そのままにして，while ループで `b`, `m`, `e` など略称にする→たまに見るけどあんまりしっくり来ない．
    - そのままにして，while ループで `sub_` の prefix をつける("部分木の"の意)→変数名が長い割には意味的にはわかりやすくならないしなぁ．
    - そのままにして，木全体も部分木の一種としてみなせるのでシャドーイング自体をも許す→今回の場合 `root` は返り値に使うためにシャドーイングしてはならないのがちょっと嫌な気持ちになる．
    - ハードコードに変更する(0, `len(nums)` )→まぁその数行下に意味がわかる変数名 `begin`, `end` がいるから許容？
  - うーん，コーディングテスト本番にこんなところまで考えられない気がする．動くコード書いたあと「業務で書くとしたらどんなこと思う？」ときかれたら上の話をするくらい？
- 再帰がDFSするときのコールスタックの挙動に近い形で実装する.
  - 再帰のときの引数に乗っていないコンテキストである左右どちらの子か？を乗せれば楽に再現できる
    - 関数呼び出し時にコールスタックにプログラムカウンタ乗せることと対応する
  - 部分木の根は先に作る（ここだけ再帰処理と挙動が異なるが，些末）．

## 5. ステップ3

ステップ2と同じ．
